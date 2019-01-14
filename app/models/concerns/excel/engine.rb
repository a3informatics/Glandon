# Excel. Base class for reading and processing excel files
#
# @author Dave Iberson-Hurst
# @since 2.21.0
# @!attribute parent_set
#   @return [Hash] set of parent items created
# @!attribute classification 
#   @return [Pathname] the classifications found
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
            next unless process_action?(action[:condition], row)
            action_object = action[:object].to_sym
            action_method = action[:method].to_sym
            params = action.slice(:map, :klass, :property, :can_be_empty)
            params.merge!({row: row, col: col})
            action_object == :parent ? params[:object] = parent : params[:object] = child
            if action_method == :create_parent
              create_parent(params) {|result| parent = result}
            elsif action_method == :create_child
              create_child(params) {|result| child = result; parent.children << result}
            elsif action_method == :ordinal
              params[:object].send("#{action[:property]}=", parent.children.count)
            elsif action_method == :c_code?
              c_code?(row, col)
            else
              self.send(action[:method], params)
            end
          rescue => e
            @errors.add(:base, "Process error #{e} when processing action '#{action}' on row #{row} column #{col}.")
          end
        end
      end
    end
  end

  # Process Action?
  #
  # @param [Hash] condition the condition
  # @option condition [String] :column the column on which the condition is to be tested
  # @option condition [String] :method the method testing the condition
  # @param [Integer] row the cell row on which the condition is being tested
  # @return [Boolean] true if the condition is met, false otherwise
  def process_action?(condition, row)
    return true if condition.blank?
    return self.send(condition[:method], {row: row, col: condition[:column]})
  end

  # Column Blank?
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @return [Boolean] true if blank/empty, false otherwise
  def column_blank?(params)
    check_params(__method__.to_s, params, [:row, :col])
    return cell_empty?(params[:row], params[:col])
  end

  # Column Not Blank?
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @return [Boolean] true if not blank/empty, false otherwise
  def column_not_blank?(params)
    check_params(__method__.to_s, params, [:row, :col])
    return !column_blank?(params)
  end

  # Create Parent
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object. Not used 
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] klass the class name for the object being created
  # @return [Void] no return
  def create_parent(params)
    check_params(__method__.to_s, params, [:row, :col, :map, :klass])
    identifier = params[:map].any? ? check_mapped(params[:row], params[:col], params[:map]) : check_value(params[:row], params[:col])
    return if identifier.blank?
    result = parent_create(params[:klass].constantize, identifier)
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
  def create_child(params)
    check_params(__method__.to_s, params, [:row, :col, :klass])
    result = params[:klass].constantize.new
    yield(result) if block_given?
  end

  # Set Property
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object in which the property is being set
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] property the name of the property
  # @param [Boolean] can_be_empty if true property can be blank.
  # @return [Void] no return
  def set_property(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :map, :property, :can_be_empty])
    x = params[:map].empty? ? check_value(params[:row], params[:col], params[:can_be_empty]) : check_mapped(params[:row], params[:col], params[:map])
    params[:object].instance_variable_set("@#{params[:property]}", x)
  end

  # Core Classification
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object in which the property is being set
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] property the name of the property
  # @return [Void] no return
  def core_classification(params)
    check_params(__method__.to_s, params, [:row, :col, :property, :object, :map])
    @classifications[:core] = true
    params[:object].instance_variable_set("@#{params[:property]}", object_create(SdtmModelCompliance, 
      check_mapped(params[:row], params[:col], params[:map])))
  end

  # Datatype Classification
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object in which the property is being set
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] property the name of the property
  # @return [Void] no return
  def datatype_classification(params)
    check_params(__method__.to_s, params, [:row, :col, :property, :object, :map])
    @classifications[:datatype] = true
    params[:object].instance_variable_set("@#{params[:property]}", object_create(SdtmModelDatatype, 
      check_mapped(params[:row], params[:col], params[:map])))
  end

  # CT Reference. This takes the form '(NAME)'. The parethesis are stripped
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object in which the property is being set
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] property the name of the property
  # @return [Void] no return
  def ct_reference(params)
    check_params(__method__.to_s, params, [:row, :col, :property, :object])
    params[:object].instance_variable_set("@#{params[:property]}", check_ct(params[:row], params[:col]))
  end

  # CT Other. Return text that is not a CT reference
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Object] object the object in which the property is being set
  # @param [Hash] map the mapping from spreadsheet values to internal values
  # @param [String] property the name of the property
  # @return [Void] no return
  def ct_other(params)
    check_params(__method__.to_s, params, [:row, :col, :property, :object])
    value = check_ct(params[:row], params[:col]).empty? ? check_value(params[:row], params[:col], true) : ""
    params[:object].instance_variable_set("@#{params[:property]}", value)
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

  # Cell Empty
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @return [Boolean] true if blank
  def cell_empty?(row, col)
    return @workbook.cell(row, col).blank?
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

  # Check params
  def check_params(method, params, args)
    missing = false
    args.all? do |a| 
      next if params.key?(a)
      @errors.add(:base, "Argument '#{a}' missing from method #{method} and is required.")
      missing = true
    end
    raise Errors::ApplicationLogicError.new(message) if missing
  end

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

  # Check C Code
  def c_code?(row, col)
    value = check_value(row, col)
    return if NciThesaurusUtility.c_code?(value)
    @errors.add(:base, "C Code '#{value}' error detected in row #{row} column #{col}.")
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

  # Find or build an object and set label
  def parent_create(klass, identifier)
    return @parent_set[identifier] if @parent_set.has_key?(identifier)
    item = klass.new
    item.scopedIdentifier.identifier = identifier if item.is_a? IsoManaged
    @parent_set[identifier] = item
    return item
  end


end    