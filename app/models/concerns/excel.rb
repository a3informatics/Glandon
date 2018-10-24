# Excel. Base class for reading and processing excel files
#
# @author Dave Iberson-Hurst
# @since 2.20.3
# @!attribute errors
#   @return [ActiveModel::Errors] Active Model errors class
# @!attribute full_path
#   @return [Pathname] the pathname for the file being read
class Excel

  C_CLASS_NAME = self.name

  require "roo"
  extend ActiveModel::Naming

  attr_reader :errors
  attr_reader :full_path
  attr_reader :compliance_set
  attr_reader :datatype_set
  attr_reader :parent_set

  # Initialize. Opens the workbook ready for processing.
  #
  # @param [Pathname] full_path the Pathname object for the file to be opened.
  # @return [Void] no return value
  def initialize(full_path)
    @errors = ActiveModel::Errors.new(self)
    @compliance_set = {}
    @datatype_set = {}
    @full_path = full_path
    @workbook = Roo::Spreadsheet.open(@full_path.to_s, extension: :xlsx) 
  rescue => e
    msg = "Exception raised opening Excel workbook filename=#{@full_path}."
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    @workbook = nil
  end

  # Check Row
  #
  # @param [Integer] row the cell row
  # @param [Array] allow_empty array of booleans to allow the cell to be blank. Defaulted to nil.
  # @return [Array] the cell values. Will be empty if allowed to be. Error logged if not.
  def check_row(row, allow_empty=nil)
    result = []
    @workbook.row(row).each_with_index do |value, i|
      result[i] = "" if value.blank? 
      @errors.add(:base, "Empty cell detected in row #{row}, column #{i}.") if value.blank? && !check_allow_empty(allow_empty, i)
      result[i] = "#{value}".strip
    end
    return result
  end
  
  # Cell Value
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Boolean] allow_empty allow the cell to be blank. Defaulted to false.
  # @return [String] the cell value. Will be empty if allowed to be. Error logged if not.
  def check_value(row, col, allow_empty=false)
    value = @workbook.cell(row, col)
    value = "" if value.blank? 
    @errors.add(:base, "Empty cell detected in row #{row}, column #{col}.") if value.blank? && !allow_empty
    return "#{value}".strip
  end
  
  # Check Sheet
  #
  # @param [Hash] sheet_info hash containing the information to be checked.
  # @option sheet_info [String] :label the sheet label
  # @option sheet_info [Array] :columns array of column names
  # @return [Boolean] true if sheet check pass, false otherwise with errors added.
  def check_sheet(sheet_info)
    headers = []
    @workbook.row(1).each_with_index {|value, i| headers[i] = value}
    if headers.length != sheet_info[:columns].length
      @errors.add(:base, "#{sheet_info[:label]} sheet in the excel file, incorrect column count, indicates format error.")
      return false
    end
    headers.each_with_index do |header, i|
      next if header == sheet_info[:columns][i]
      @errors.add(:base, "#{sheet_info[:label]} sheet in the excel file, incorrect #{(i+1).ordinalize} column name, indicates format error.")
      return false
    end 
    return true
  rescue => e
    @errors.add(:base, "Unexpected exception. Possibly an empty #{sheet_info[:label]} sheet.")
    return false
  end

  # Sheet Info
  #
  # @param [Symbol] import the import
  # @param [Symbol] sheet the sheet key as a symbol used in the configuration file
  # @return [Hash] the sheet info hash
  def sheet_info(import, sheet)
    result = {label: Rails.configuration.imports[:processing][import][:sheets][sheet][:label], columns: []}
    result[:columns] = Rails.configuration.imports[:processing][import][:sheets][sheet][:columns].map {|x| x[:label]}
    return result
  end

  # Map Info
  #
  # @param [Symbol] import the import
  # @param [Symbol] sheet the sheet key as a symbol used in the configuration file
  # @return [Array] the array of maps
  def map_info(import, sheet)
    return Rails.configuration.imports[:processing][import][:sheets][sheet][:columns].map {|x| x[:map]}
  end

  # Operation Hash. Builds a managed item operaitonal hash
  #
  # @param [Object] object the object for which the hash will be created.
  # @param [Hash] params the params hash
  # @option params [String] :label the items's label
  # @option params [String] :identifier the items's identifier
  # @option params [String] :version_label the items's version label
  # @option params [String] :semantic_version the items's semantic version
  # @option params [String] :version the items's version (integer as a string)
  # @option params [String] :date the items's release date
  # @option params [Integer] :ordinal the ordinal for the item
  # @return [Boolean] retruns true if sheet check pass, false otherwise with errors added.
  def operation_hash(object, params)
    object.label = params[:label] if object.label.blank?
    object.scopedIdentifier.identifier = params[:identifier]
    object.scopedIdentifier.versionLabel = params[:version_label]
    operation = object.to_operation
    operation[:operation][:new_version] = params[:version]
    operation[:operation][:new_semantic_version] = SemanticVersion.from_s(params[:semantic_version]).to_s
    operation[:operation][:new_state] = IsoRegistrationState.releasedState
    operation[:managed_item][:creation_date] = params[:date]
    operation[:managed_item][:ordinal] = params[:ordinal]
    return operation
  end        

  # Parent
  #
  # @param [Class] klass the class name for the parents
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Hash] map the mapping from spreadsheet values to internal values
  def parent(row, col, klass, map)
    return object_create(klass, parent_set, check_mapped(row, col, map))
  end

  # Core Classification
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Hash] map the mapping from spreadsheet values to internal values
  def core_classification(row, col, map)
    return object_create(SdtmModelCompliance, compliance_set, check_mapped(row, col, map))
  end

  # Datatype Classification
  #
  # @param [Integer] row the cell row
  # @param [Integer] col the cell column
  # @param [Hash] map the mapping from spreadsheet values to internal values
  def datatype_classification(row, col, map)
    return object_create(SdtmModelDatatype, datatype_set, check_mapped(row, col, map))
  end

  # CT Reference. This takes the form '(NAME)'. The parethesis are stripped
  #
  # @return [String] the CT reference
  def ct_reference(row, col)
    ct(row, col)
  end

  # CT Other. Return text that is not a CT reference
  #
  # @return [String] the CT reference
  def ct_other(row, col)
    return "" if !ct(row, col).empty?
    return check_value(row, col, false)
  end

private

  # CT
  def ct(row, col)
    temp = check_value(row, col, false)
    return "" if temp.blank?
    temp = temp.scan(/\(([^\)]+)\)/).last.first
    temp = temp.gsub(/[()]/, "")
    return temp
  rescue => e 
    return ""
  end

  def check_mapped(row, col, map)
    value = check_value(row, col)
    mapped = map[value.to_sym]
    return mapped if !mapped.nil?
    @errors.add(:base, "Mapping error. '#{value}' detected in row #{row} column: #{col}.")
    return nil
  end

  # Find or build the compliance value
  def object_create(klass, set, value)
    return nil if value.blank?
    return set[value] if set.has_key?(value)
    item = klass.new
    item.label = value
    set[value] = item
    return item
  end

  # Check the allow empty array for the flag.
  def check_allow_empty(allow_empty, index)
    return false if allow_empty.nil?
    return allow_empty[index]
  end

end    