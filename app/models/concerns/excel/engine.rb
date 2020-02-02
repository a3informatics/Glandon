# Excel. Base class for reading and processing excel files
#
# @author Dave Iberson-Hurst
# @since 2.21.0
# @attr_reader [Hash] parent_set set of parent items created
# @attr_reader [Pathname] classification the classifications found
class Excel::Engine

  C_CLASS_NAME = self.name

  extend ActiveModel::Naming

  attr_reader :parent_set, :classifications, :tags

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
    @classifications = {}
    @tags = []
    @tag_set = {}
  end

  # Process. Process a sheet according to the configuration
  #
  # @param [Symbol] import the import type
  # @param [Symbol] sheet the import sheet
  # @return [Void] no return
  def process(import, sheet)
    parent = nil
    child = nil
    sheet_logic = Rails.configuration.imports[:processing][import][:sheets][sheet]
    process_sheet(sheet_logic)  
    ((@workbook.first_row + 1) .. @workbook.last_row).each do |row|
      next unless process_row?(sheet_logic, row)
      sheet_logic[:columns].each do |column|
        col = find_column(column, sheet_logic)
        column[:actions].each do |action| 
          begin
            next unless process_action?(action[:condition], row)
            action_object = action[:object].to_sym
            action_method = action[:method].to_sym
            params = action.slice(:map, :klass, :property, :can_be_empty, :additional)
            params.merge!({row: row, col: col})
            action_object == :parent ? params[:object] = parent : params[:object] = child
            if action_method == :create_parent
              create_parent(params) {|result| parent = result}
            elsif action_method == :create_child
              create_child(params) {|result| child = result; parent.children << result}
            elsif action_method == :create_item
              create_item(params) {|result| parent = result}
            elsif action_method == :ordinal
              params[:object].send("#{action[:property]}=", parent.children.count)
            else
              self.send(action[:method], params)
            end
          rescue => e
            msg = "Exception raised when processing action '#{action}' on row #{row} column #{col}."
            ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
            @errors.add(:base, msg)
          end
        end
      end
    end
  end

  # Process Sheet
  #
  # @param sheet_logic [Hash] hash containing the sheet logic. May not be present
  # @return [Boolean] true if the condition is met, false otherwise
  def process_sheet(sheet_logic)
    actions = sheet_logic.dig(:sheet, :actions) 
    return true if actions.nil? # No conditions present
    return true if actions.empty? # No conditions present
    actions.each {|action| self.send(action[:method], action.slice(:map, :can_be_empty, :additional))}
  end

  # Process Row?
  #
  # @param sheet_logic [Hash] hash containing the row logic. May not be present
  # @param row [Integer] the cell row on which the condition is being tested
  # @return [Boolean] true if the condition is met, false otherwise
  def process_row?(sheet_logic, row)
    condition = sheet_logic.dig(:row, :condition) 
    return true if condition.nil? # No condition present
    return self.send(condition[:method], {row: row, col: condition[:column]})
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
  # @param [Hash] params the params hash
  # @param params [Integer] :row row the cell row
  # @param params [Integer|Array] :col the cell column(s), can be single or an array
  # @return [Boolean] true if blank/empty, false otherwise
  def column_blank?(params)
    check_params(__method__.to_s, params, [:row, :col])
    cols = params[:col].is_a?(Array) ? params[:col] : [params[:col]]
    cols.each do |col|
      return false if !cell_empty?(params[:row], col)
    end
    true
  end

  # Column Not Blank?
  #
  # @param [Hash] params the parameters
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @return [Boolean] true if not blank/empty, false otherwise
  def column_not_blank?(params)
    check_params(__method__.to_s, params, [:row, :col])
    return !column_blank?(params)
  end

  # Column Affirmative?
  #
  # @param [Hash] params the parameters
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @return [Boolean] true if affirmative (boolean true), false otherwise
  def column_affirmative?(params)
    check_params(__method__.to_s, params, [:row, :col])
    return check_value(params[:row], params[:col], true).to_bool # Can be empty, convert to boolean
  end

  # Tag From Sheet Name
  #
  # @param [Hash] params the parameters hash
  # @option params [Hash] :map the mapping from spreadsheet values to internal values
  # @return [Array] the tags, an array of tags
  def tag_from_sheet_name(params)
    @tags = []
    tags = []
    check_params(__method__.to_s, params, [:map])
    params[:map].each do |word, tag_set| 
      next if !@workbook.default_sheet.include?(word.to_s)
      tags = tag_set
      break
    end
    tags.each do |tag|
      @tags << IsoConceptSystem.path(["CDISC"] + [tag])
    end
    @tags
  end
    
  # Create Parent
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :map the mapping from spreadsheet values to internal values
  # @option params [String] :klass the class name for the object being created
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
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :map the mapping from spreadsheet values to internal values
  # @option params [String] :klass the class name for the object being created
  # @return [Void] no return
  def create_child(params)
    check_params(__method__.to_s, params, [:row, :col, :klass])
    result = params[:klass].constantize.new
    yield(result) if block_given?
  end

  # Create Item. Create an item identifier by the row number
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :map the mapping from spreadsheet values to internal values
  # @option params [String] :klass the class name for the object being created
  # @return [Void] no return
  def create_item(params)
    check_params(__method__.to_s, params, [:row, :col, :map, :klass])
    result = params[:klass].constantize.new
    @parent_set[params[:row]] = result
    yield(result) if block_given?
  end

  # Check Valid. Checks if the object is valid. 
  #
  # @param [Hash] params the parameters hash
  # @option params [Object] :object the object to check for validity
  # @return [Void] no return
  def check_valid(params)
    check_params(__method__.to_s, params, [:object])
    params[:object].errors.each {|k, e| @errors.add(:base, "Row #{params[:row]}. #{e}")} if !params[:object].valid?
  end

  # Set Tags
  #
  # @param [Hash] params the parameters hash
  # @option params [Object] :object the object to tag
  # @return [Void] no return
  def set_tags(params)
    check_params(__method__.to_s, params, [:object])
    params[:object].tagged = @tags
  end

  # Set Column Tag
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :map the mapping from spreadsheet values to internal values
  # @option params [Hash] :additonal hash containing the tag path
  # @return [Void] no return
  def set_column_tag(params)
    check_params(__method__.to_s, params, [:row, :col, :map, :object, :can_be_empty, :additional])
    value = check_value(params[:row], params[:col], params[:can_be_empty])
    return if value.blank? && params[:can_be_empty]
    value = check_mapped(params[:row], params[:col], params[:map])
    return if value.blank?
    tag = find_tag(params[:additional][:path], value)
    return if tag.nil?
    params[:object].add_tag_no_save(tag)
  end

  # Set Property
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] o"bject the object in which the property is being set
  # @option params [Hash] :map the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property
  # @option params [Boolean] :can_be_empty if true property can be blank.
  # @return [Void] no return
  def set_property(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :map, :property, :can_be_empty])
    x = params[:map].empty? ? check_value(params[:row], params[:col], params[:can_be_empty]) : check_mapped(params[:row], params[:col], params[:map])
    params[:object].instance_variable_set("@#{params[:property]}", x)
  end

  # Set Property With Default
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :map the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property
  # @option params [Boolean] :can_be_empty if true property can be blank
  # @option params [Hash] :additional a hash containing additional parameters, in this case the default string
  # @return [Void] no return
  def set_property_with_default(params)
    params[:can_be_empty] = true
    check_params(__method__.to_s, params, [:row, :col, :object, :map, :property, :can_be_empty, :additional])
    x = params[:map].empty? ? check_value(params[:row], params[:col], params[:can_be_empty]) : check_mapped(params[:row], params[:col], params[:map])
    x = x.blank? ? params[:additional][:default] : x
    params[:object].instance_variable_set("@#{params[:property]}", x)
  end

  # Tokenize And Set Property
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [String] :property the name of the property
  # @option params [Boolean] :can_be_empty if true property can be blank.
  # @option params [Hash] :additonal hash containing the tokenize separator character
  # @return [Void] no return
  def tokenize_and_set_property(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :property, :can_be_empty, :additional])
    x = check_value(params[:row], params[:col], params[:can_be_empty])
    return if x.empty?
    parts = x.split(params[:additional][:token]).uniq # Make the array a set of unique entries
    property = params[:object].instance_variable_get("@#{params[:property]}")
    parts.each {|p| property << p.strip}
  end

  # C Codes. Check cell is a series of C Codes
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Hash] :additonal hash containing the tokenize separator character
  # @return [Void] no return
  def c_codes?(params)
    result = true
    check_params(__method__.to_s, params, [:row, :col, :object, :property, :can_be_empty, :additional])
    x = check_value(params[:row], params[:col], params[:can_be_empty])
    return false if x.empty?
    parts = x.split(params[:additional][:token]).uniq # Make the array a set of unique entries
    parts.each do |value| 
      next if NciThesaurusUtility.c_code?(value.strip)
      @errors.add(:base, "C Code '#{value}' error detected in row #{params[:row]} column #{params[:col]}.") 
      result = false
    end
    result
  end

  # Tokenize And Create Shared
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [String] :property the name of the property
  # @option params [Boolean] :can_be_empty if true property can be blank.
  # @option params [Hash] :additonal hash containing the tokenize separator character
  # @return [Void] no return
  def tokenize_and_create_shared(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :property, :can_be_empty, :additional])
    x = check_value(params[:row], params[:col], params[:can_be_empty])
    return if x.empty?
    parts = x.split(params[:additional][:token]).uniq # Make the array a set of unique entries
    parts.each {|p| create_definition(params[:object], params[:property], p.strip)}
  end

  # Create Shared
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [String] :property the name of the property
  # @option params [Boolean] :can_be_empty if true property can be blank.
  # @return [Void] no return
  def create_shared(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :property, :can_be_empty])
    x = check_value(params[:row], params[:col], params[:can_be_empty])
    return if x.empty?
    create_definition(params[:object], params[:property], x)
  end

  # Create Classification
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :map the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property to be set
  # @return [Void] no return
  def create_classification(params)
    check_params(__method__.to_s, params, [:row, :col, :property, :object, :map])
    create_definition(params[:object], params[:property], check_mapped(params[:row], params[:col], params[:map]))
  end

  # Create Definition
  #
  # @param parent [Object] the parent instance
  # @param property_name [String] the property name
  # @param label [String] the label for the definition
  # @return [Void] no return
  def create_definition(parent, property_name, label)
    return if label.blank?
    return if duplicate_label?(parent, property_name, label)
    property = parent.properties.property(property_name.to_sym)
    klass = property.klass
    results = klass.where(label: label)
    object = results.any? ? results.first : object_create(klass, label)
    property.set(object)
  end

  # CT Reference. This takes the form '(NAME)'. The parethesis are stripped
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :map the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property to be set
  # @return [Void] no return
  def ct_reference(params)
    check_params(__method__.to_s, params, [:row, :col, :property, :object])
    params[:object].instance_variable_set("@#{params[:property]}", check_ct(params[:row], params[:col]))
  end

  # CT Other. Return text that is not a CT reference
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :map the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property to be set
  # @return [Void] no return
  def ct_other(params)
    check_params(__method__.to_s, params, [:row, :col, :property, :object])
    value = check_ct(params[:row], params[:col]).empty? ? check_value(params[:row], params[:col], true) : ""
    params[:object].instance_variable_set("@#{params[:property]}", value)
  end

  # C Code? Valid C Code?
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @return [boolean] true if valid, false otherwise
  def c_code?(params)
    check_params(__method__.to_s, params, [:row, :col])
    value = check_value(params[:row], params[:col])
    return true if NciThesaurusUtility.c_code?(value)
    @errors.add(:base, "C Code '#{value}' error detected in row #{params[:row]} column #{params[:col]}.")
    false
  end

  # Regex? Valid Regular expression?
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Hash] :additonal hash containing the regular expression
  # @return [boolean] true if valid, false otherwise
  def regex?(params)
    check_params(__method__.to_s, params, [:row, :col, :additional])
    regex = Regexp.new(params[:additional][:regex])
    value = check_value(params[:row], params[:col])
    result = regex.match value
    return true if !result.nil?
    @errors.add(:base, "Format of '#{value}' error detected in row #{params[:row]} column #{params[:col]}.")
    false
  end

  # Check Value
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Boolean] allow_empty allow the cell to be blank. Defaulted to false.
  # @return [String] the cell value. Will be empty if allowed to be. Error logged if not.
  def check_value(row, col, allow_empty=false)
    value = @workbook.cell(row, col).to_s # Ensure all inputs are strings
    value = value.blank? ? "" : remove_unicode_chars(value)
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
    info = Rails.configuration.imports[:processing][import][:sheets][sheet]
    {selection: info[:selection], columns: info[:sheet][:header_row]}
  end
 
private

  # Find Tag From Path
  def find_tag(path, tag)
    key = "#{path.join(".")}.#{tag}"
    return @tag_set[key] if @tag_set.key?(key)
    tag = IsoConceptSystem.path(path + [tag])
    @tag_set[key] = tag
    tag
  rescue Errors::ApplicationLogicError => e
    return nil
  end

  # Find Columns
  def find_column(column, sheet)
    header_row = sheet.dig(:sheet, :header_row)
    index = header_row.index(column[:label])
    return index + 1 if !index.nil?
    raise Errors::ApplicationLogicError.new("Failed to find column #{column[:label]} in header row definition.")
  end
 
  # Remove smart quotes
  def remove_unicode_chars(text)
    text = text.gsub(/[\u2013]/, "-")
    text = text.gsub(/[\u003E]/, ">")
    text = text.gsub(/[\u003C]/, "<")
    text = text.gsub(/[\u2018\u2019\u0092]/, "'")
    text.gsub(/[\u201C\u201D]/, '"')
  end

  # Check for a duplicate label.
  def duplicate_label?(parent, property, label)
    collection = parent.send(property)
    return false if collection.nil?
    return false if !collection.is_a?(Array)
    !collection.detect{|x| x.label == label}.nil?
  end

  # Check params
  def check_params(method, params, args)
    missing = false
    args.all? do |a| 
      next if params.key?(a)
      @errors.add(:base, "Argument '#{a}' missing from method #{method} and is required.")
      missing = true
    end
    raise Errors::ApplicationLogicError.new("Missing arguments detected.") if missing
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
    @classifications[klass.name] = {} if !@classifications.key?(klass.name)
    return @classifications[klass.name][value] if @classifications[klass.name].key?(value)
    item = klass.new
    item.label = value
    @classifications[klass.name][value] = item
    return item
  end

  # Find or build an object and set label
  def parent_create(klass, identifier)
    return @parent_set[identifier] if @parent_set.has_key?(identifier)
    item = klass.new
    item.has_identifier = IsoScopedIdentifierV2.new
    item.has_identifier.identifier = identifier if item.is_a? IsoManagedV2
    @parent_set[identifier] = item
    return item
  end

end    