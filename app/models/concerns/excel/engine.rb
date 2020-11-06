# Excel. Base class for reading and processing excel files
#
# @author Dave Iberson-Hurst
# @since 2.21.0
# @attr_reader [Hash] parent_set set of parent items created
# @attr_reader [Pathname] classification the classifications found
class Excel::Engine

  extend ActiveModel::Naming

  attr_reader :parent_set, :classifications, :sheet_tags

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
    @sheet_tags = []
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
            params = action.slice(:mapping, :klass, :property, :can_be_empty, :additional)
            params.merge!({row: row, col: col})
            params[:mapping] ||= {map: {}, exact: true}
            params[:can_be_empty] ||= false
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
            ConsoleLogger::log(self.class.name, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
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
    actions.each {|action| self.send(action[:method], action.slice(:mapping, :can_be_empty, :additional))}
  end

  # Process Row?
  #
  # @param sheet_logic [Hash] hash containing the row logic. May not be present
  # @param row [Integer] the cell row on which the condition is being tested
  # @return [Boolean] true if the condition is met, false otherwise
  def process_row?(sheet_logic, row)
    conditions = sheet_logic.dig(:row, :conditions) 
    return true if conditions.blank? # No conditions present
    conditions.each do |condition|
      result = true
      condition.each do |element|
        if element.key?(:method)
          result = result && self.send(element[:method], {row: row, col: element[:column]})
        elsif element.key?(:value_in_set)
          result = result && element[:value_in_set].include?(check_value(row, element[:column]))
        elsif element.key?(:value)
          result = result && check_value(row, element[:column]) == element[:value]
        else
          raise Errors::ApplicationLogicError.new("Unexpected condition element #{element} in process row definition.")
        end
      end
      return true if result
    end
    false
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
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [Hash] :additional hash containing the tag path
  # @return [Array] the tags, an array of tags
  def tag_from_sheet_name(params)
    @sheet_tags = []
    tags = []
    check_params(__method__.to_s, params, [:mapping])
    params[:mapping][:map].each do |word, tag_set| 
      next if !@workbook.default_sheet.include?(word.to_s)
      tags = tag_set
      break
    end
    tags.each do |tag|
      @sheet_tags << IsoConceptSystem.path(params[:additional][:path] + [tag])
    end
    @sheet_tags
  end
    
  # Create Parent
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :klass the class name for the object being created
  # @return [Void] no return
  def create_parent(params)
    check_params(__method__.to_s, params, [:row, :col, :mapping, :klass])
    identifier = params[:mapping][:map].any? ? check_mapped(params[:row], params[:col], params[:mapping][:map]) : check_value(params[:row], params[:col])
    return if identifier.blank?
    prefix = params.dig(:additional, :prefix)
    identifier = prefix.nil? ? identifier : "#{prefix} #{identifier}"
    result = parent_create(params[:klass].constantize, identifier)
    yield(result) if block_given?
  end

  # Create Child
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
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
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :klass the class name for the object being created
  # @return [Void] no return
  def create_item(params)
    check_params(__method__.to_s, params, [:row, :col, :mapping, :klass])
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

  # Set Property To Sheet Tags
  #
  # @param [Hash] params the parameters hash
  # @option params [Object] :object the object to tag
  # @option params [String] :property the name of the property
  # @return [Void] no return
  def set_property_to_sheet_tags(params)
    check_params(__method__.to_s, params, [:object, :property])
    add_tags(params[:object], params[:property], @sheet_tags)
  end

  # Set Property
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] object the object in which the property is being set
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property
  # @option params [Boolean] :can_be_empty if true property can be blank.
  # @return [Void] no return
  def set_property(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :mapping, :property, :can_be_empty])
    x = params[:mapping][:map].blank? ? check_value(params[:row], params[:col], params[:can_be_empty]) : check_mapped(params[:row], params[:col], params[:mapping][:map])
    property_set_value(params[:object], params[:property], x)
  end

  # Set Property With Default
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property
  # @option params [Boolean] :can_be_empty if true property can be blank
  # @option params [Hash] :additional a hash containing additional parameters, in this case the default string
  # @return [Void] no return
  def set_property_with_default(params)
    params[:can_be_empty] = true
    check_params(__method__.to_s, params, [:row, :col, :object, :mapping, :property, :can_be_empty, :additional])
    x = params[:mapping][:map].blank? ? check_value(params[:row], params[:col], params[:can_be_empty]) : check_mapped(params[:row], params[:col], params[:mapping][:map])
    x = x.blank? ? params[:additional][:default] : x
    property_set_value(params[:object], params[:property], x)
  end

  # Set Property With Regex. Set a property based on a regrx evaluation of the cell content
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property
  # @option params [Boolean] :can_be_empty if true property can be blank
  # @option params [Hash] :additional a hash containing additional parameters, in this case the regex
  # @return [Void] no return
  def set_property_with_regex(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :mapping, :property, :can_be_empty, :additional])
    regex = Regexp.new(params[:additional][:regex])
    x = check_value(params[:row], params[:col], false)
    return if x.empty?
    x = regex.match(x).nil? ? false : true
    property_set_value(params[:object], params[:property], x)
  end

  # Set Property With Custom. Set a property to a custom value
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property holding the set of custom values
  # @option params [Boolean] :can_be_empty if true property can be blank.
  # @option params [Hash] :additonal hash containing the tag path and custom name
  # @return [Void] no return
  def set_property_with_custom(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :mapping, :property, :can_be_empty, :additional])
    value = check_value(params[:row], params[:col], params[:can_be_empty])
    return if value.blank? && params[:can_be_empty]
    value = check_mapped(params[:row], params[:col], params[:mapping][:map])
    return if value.blank?
    add_custom(params[:object], params[:property], params[:additional][:name], value)
  end

  # Set Property With Tag. Set a property to a tag
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property
  # @option params [Boolean] :can_be_empty if true property can be blank.
  # @option params [Hash] :additonal hash containing the tag path
  # @return [Void] no return
  def set_property_with_tag(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :mapping, :property, :can_be_empty, :additional])
    value = check_value(params[:row], params[:col], params[:can_be_empty])
    return if value.blank? && params[:can_be_empty]
    value = check_mapped(params[:row], params[:col], params[:mapping][:map])
    return if value.blank?
    tag = find_tag(params[:additional][:path], value)
    return if tag.blank?
    add_tag(params[:object], params[:property], tag)
  end

  # Set Property With Reference. Set a property to a canonical reference
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property
  # @option params [Hash] :additonal hash containing the reference field to search on 
  # @return [Void] no return
  def set_property_with_reference(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :mapping, :property, :additional])
    value = params[:mapping][:map].blank? ? check_value(params[:row], params[:col], false) : check_mapped(params[:row], params[:col], params[:mapping][:map])
    return if value.blank?
    ref = CanonicalReference.where({params[:additional][:search] => value})
    return if ref.blank?
    property_set_value(params[:object], params[:property], ref.first)
  end

  # Set Property With Lookup. Set a property to a lookup from another sheet
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property
  # @option params [Hash] :additonal hash containing the reference field to search on 
  # @return [Void] no return
  def set_property_with_lookup(params)
    check_params(__method__.to_s, params, [:row, :col, :object, :property, :additional])
    value = check_value(params[:row], params[:col], false)
    return if value.blank?
    sheet_index = find_sheet_index(params[:additional][:sheet_name])
    key_col = find_sheet_column_index(sheet_index, params[:additional][:key_column])
    value_col = find_sheet_column_index(sheet_index, params[:additional][:value_column])
    row = sheet_column(sheet_index, key_col).index(value)
    return if row.nil?
    property_set_value(params[:object], params[:property], sheet_cell(sheet_index, row + 1, value_col))
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
    check_params(__method__.to_s, params, [:row, :col, :object, :can_be_empty, :additional])
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
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property to be set
  # @return [Void] no return
  def create_classification(params)
    check_params(__method__.to_s, params, [:row, :col, :property, :object, :mapping])
    create_definition(params[:object], params[:property], check_mapped(params[:row], params[:col], params[:mapping][:map]))
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
  # @option params [String] :property the name of the property to be set
  # @return [Void] no return
  def ct_reference(params)
    check_params(__method__.to_s, params, [:row, :col, :property, :object])
    ref = check_ct(params[:row], params[:col])
    property_set_value(params[:object], params[:property], ref)
  end

  # CT Other. Return text that is not a CT reference
  #
  # @param [Hash] params the parameters hash
  # @option params [Integer] :row the cell row
  # @option params [Integer] :col the cell column
  # @option params [Object] :object the object in which the property is being set
  # @option params [Hash] :mapping the mapping from spreadsheet values to internal values
  # @option params [String] :property the name of the property to be set
  # @return [Void] no return
  def ct_other(params)
    check_params(__method__.to_s, params, [:row, :col, :property, :object])
    value = check_ct(params[:row], params[:col]).empty? ? check_value(params[:row], params[:col], true) : ""
    property_set_value(params[:object], params[:property], value)
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
    info = Rails.configuration.imports[:processing].dig(import, :sheets, sheet)
    return {selection: info[:selection], columns: info[:sheet][:header_row]} unless info.nil?
    raise Errors::ApplicationLogicError.new("Exception when finding sheet definition for import type: '#{import}'' and sheet: '#{sheet}'.") if info.nil?
  end
 
  #----------
  # Test Only
  #----------
  
  if Rails.env.test?
  
    def check_mapped_test(row, col, map)
      check_mapped(row, col, map)
    end

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
 
  # Find Sheet Index
  def find_sheet_index(name)
    index = @workbook.sheets.index {|sheet| sheet.include?(name)}
    return index unless index.nil?
    Errors::ApplicationLogicError.new("Failed to find sheet name that includes #{name} in workbook.")
  end

  # Find Sheet Column Index
  def find_sheet_column_index(sheet_index, name)
    index = sheet_row(sheet_index, 1).index(name.to_s)
    return index + 1 unless index.nil?
    raise Errors::ApplicationLogicError.new("Failed to find column #{name} in header row.")
  end

  # Sheet Row
  def sheet_row(sheet_index, row)
    preserve = @workbook.default_sheet 
    result = @workbook.sheet(sheet_index).row(row)
    @workbook.default_sheet = preserve
    result
  end
  
  # Sheet Column
  def sheet_column(sheet_index, col)
    preserve = @workbook.default_sheet 
    result = @workbook.sheet(sheet_index).column(col)
    @workbook.default_sheet = preserve
    result
  end
  
  # Sheet Cell
  def sheet_cell(sheet_index, row, col)
    preserve = @workbook.default_sheet 
    result = @workbook.sheet(sheet_index).cell(row, col)
    @workbook.default_sheet = preserve
    result
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
    args.each do |a| 
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

  # Check mapped cell. Will match key exactly or value starts with the key
  def check_mapped(row, col, map, exact=false)
    value = check_value(row, col, true)
    mapped = check_mapped_exact(row, col, map, value)
    return mapped unless mapped.nil?
    if !exact
      mapped = check_mapped_inexact(row, col, map, value)
      return mapped unless mapped.nil?
    end
    @errors.add(:base, "Error mapping '#{value}' using map #{map} detected in row #{row} column #{col}.")
    return nil
  end

  # Check mapped cell exact. Will match value exactly
  def check_mapped_exact(row, col, map, value)
    map[value.to_sym]
  end

  # Check mapped cell inexact. Will match value if it starts with the key
  def check_mapped_inexact(row, col, map, value)
    mapped = map.select{|k,v| value.start_with? k.to_s}
    mapped.empty? ? nil : mapped.values.first 
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

  # Add tag
  def add_tag(object, name, tag)
    add_tags(object, name, [tag])
  end

  # Add tags
  def add_tags(object, name, tags)
    current_tags = get_temporary(object, name)
    current_tags ||= []
    tags.each {|tag| current_tags << tag unless current_tags.map{|x| x.uri}.include?(tag.uri)}
    property_set_value(object, name, current_tags)
  end

  # Add custom
  def add_custom(object, property, name, value)
    custom_set = get_temporary(object, property)
    custom_set ||= {}
    custom_set[name] = value
    property_set_value(object, property, custom_set)
  end

  # Set a property value
  def property_set_value(object, name, value)
    return if only_temporary?(object, name, value)
    object.properties.ignore?(name.to_sym) ? set_temporary(object, name, value) : set_defined(object, name, value) 
  end

  # Set a temporary property
  def only_temporary?(object, name, value)
    return false if object.respond_to?(:properties) # This checks if there is a properties method for the object defined
    set_temporary(object, name, value)              # Method not defined, therefore must be non-schema variable
    true
  end

  # Set a defined property
  def set_defined(object, name, value)
    object.properties.property(name.to_sym).set_value(value)
  end

  # Set a temporary property
  def set_temporary(object, name, value)
    object.instance_variable_set("@#{name}", value)
  end

  # Set a temporary property
  def get_temporary(object, name)
    object.instance_variable_get("@#{name}")
  end

end    