# Excel. Base class for reading and processing excel files
#
# @author Dave Iberson-Hurst
# @since 2.21.0
# @!attribute errors
#   @return [ActiveModel::Errors] Active Model errors class
# @!attribute full_path
#   @return [Pathname] the pathname for the file being read
class Excel::Engine

  C_CLASS_NAME = self.name

  extend ActiveModel::Naming

  attr_reader :parent_set, :classifications

  # Initialize. Opens the workbook ready for processing.
  #
  # @param [Excel] owner the owning Excel object
  # @param [Object] workbook the workbook object
  # @return [Void] no return value
  def initialize(owner, workbook)
    @owner = owner
    @workbook = workbook
    @errors = owner.errors
    @parent_set = {}
    @classifications = {datatype: false, core: false, compliance: false}
  end

  # Process. Process a sheet according to the configuration
  #
  # @param [Symbol] import the import type
  # @param [Symbol] sheet the import sheet
  # @return [Void] no return
  def process(import, sheet)
    parent = nil
    child = nil
    ((@workbook.first_row + 1) .. @workbook.last_row).each do |row|
      Rails.configuration.imports[:processing][import][:sheets][sheet][:columns].each_with_index do |column, col_index|
        col = col_index + 1
        column[:actions].each do |action| 
          begin
            action_object = action[:object].to_sym
            action_method = action[:method].to_sym
            params = [row, col]
            action_object == :parent ? params << parent : params << child
            params << action[:map]
            params << action[:klass] if !action[:klass].blank?
            params << action[:property] if !action[:property].blank?
            if action_method == :create_parent
              self.send(action[:method], *params) {|result| parent = result}
            elsif action_method == :create_child
              self.send(action[:method], *params) {|result| child = result; parent.children << result}
            elsif action_method == :ordinal
              params[2].send("#{action[:property]}=", parent.children.count)
            else
              self.send(action[:method], *params)
            end
          rescue => e
            @errors.add(:base, "Process error #{e} when processing action '#{action}' on row #{row} column #{col}.")
          end
        end
      end
    end
  end

  # Create Parent
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object. Not used 
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] klass the class name for the object being created
  # @return [Void] no return
  def create_parent(row, col, object, map, klass)
    return if !check_create_map(row, col, map)
    identifier = check_mapped(row, col, map)
    return if identifier.blank?
    result = parent_create(klass.constantize, identifier)
    yield(result) if block_given?
  end

  # Create Child
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object. Not used 
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] klass the class name for the object being created
  # @return [Void] no return
  def create_child(row, col, object, map, klass)
    result = klass.constantize.new
    yield(result) if block_given?
  end

  # Set Property
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object in which the property is being set
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] property the name of the property
  # @return [Void] no return
  def set_property(row, col, object, map, property)
    x = map.empty? ? check_value(row, col) : check_mapped(row, col, map)
    object.instance_variable_set("@#{property}", x)
  end

  # Core Classification
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object in which the property is being set
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] property the name of the property
  # @return [Void] no return
  def core_classification(row, col, object, map, property)
    @classifications[:core] = true
   object.instance_variable_set("@#{property}", object_create(SdtmModelCompliance, check_mapped(row, col, map)))
  end

  # Datatype Classification
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object in which the property is being set
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] property the name of the property
  # @return [Void] no return
  def datatype_classification(row, col, object, map, property)
    @classifications[:datatype] = true
    object.instance_variable_set("@#{property}", object_create(SdtmModelDatatype, check_mapped(row, col, map)))
  end

  # CT Reference. This takes the form '(NAME)'. The parethesis are stripped
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object in which the property is being set
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] property the name of the property
  # @return [Void] no return
  def ct_reference(row, col, object, map, property)
    object.instance_variable_set("@#{property}", check_ct(row, col))
  end

  # CT Other. Return text that is not a CT reference
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object in which the property is being set
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] property the name of the property
  # @return [Void] no return
  def ct_other(row, col, object, map, property)
    value = check_ct(row, col).empty? ? check_value(row, col, true) : ""
    object.instance_variable_set("@#{property}", value)
  end

  # Check Value
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Boolean] allow_empty allow the cell to be blank. Defaulted to false.
  # @return [String] the cell value. Will be empty if allowed to be. Error logged if not.
  def check_value(row, col, allow_empty=false)
    value = @workbook.cell(row, col)
    value = "" if value.blank? 
    @errors.add(:base, "Empty cell detected in row #{row} column #{col}.") if value.blank? && !allow_empty
    return "#{value}".strip
  end

  # Sheet Info
  #
  # @param [Symbol] import the import type
  # @param [Symbol] sheet the import sheet
  # @return [Hash] the sheet info in a hash
  def sheet_info(import, sheet)
    result = {label: Rails.configuration.imports[:processing][import][:sheets][sheet][:label], columns: []}
    result[:columns] = Rails.configuration.imports[:processing][import][:sheets][sheet][:columns].map {|x| x[:label]}
    return result
  end
 
private

  # Check CT cell
  def check_ct(row, col)
    temp = check_value(row, col, true)
    return "" if temp.blank?
    temp = temp.scan(/\(([^\)]+)\)/).last.first
    temp = temp.gsub(/[()]/, "")
    return temp
  rescue => e 
    return ""
  end

  # Check mapped cell
  def check_mapped(row, col, map)
    value = check_value(row, col)
    mapped = map[value.to_sym]
    return mapped if !mapped.nil?
    @errors.add(:base, "Mapping of '#{value}' error detected in row #{row} column #{col}.")
    return nil
  end

  # Find or build an object and set label
  def object_create(klass, value)
    return nil if value.blank?
    item = klass.new
    item.label = value
    return item
  end

  # Check create map
  def check_create_map(row, col, map)
    return true if map.any?
    @errors.add(:base, "No create map detected in row #{row} column #{col}.")
    return false
  end

  # Find or build an object and set label
  def parent_create(klass, identifier)
    return @parent_set[identifier] if @parent_set.has_key?(identifier)
    item = klass.new
    item.scopedIdentifier.identifier = identifier
    @parent_set[identifier] = item
    return item
  end


end    