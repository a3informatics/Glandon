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

  attr_reader   :errors
  attr_reader   :full_path

  # Initialize. Opens the workbook ready for processing.
  #
  # @param [Pathname] full_path the Pathname object for the file to be opened.
  # @return [Void] no return value
  def initialize(full_path)
    @errors = ActiveModel::Errors.new(self)
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
  #  {name: <sheet name>, columns: ["<column_name>", "<column_name>"]}
  # @return [Boolean] retruns true if sheet check pass, false otherwise with errors added.
  def check_sheet(sheet_info)
    headers = []
    @workbook.row(1).each_with_index {|value, i| headers[i] = value}
    if headers.length != sheet_info[:columns].length
      @errors.add(:base, "#{sheet_info[:name]} sheet in the excel file, incorrect column count, indicates format error.")
      return false
    end
    headers.each_with_index do |header, i|
      next if header == sheet_info[:columns][i]
      @errors.add(:base, "#{sheet_info[:name]} sheet in the excel file, incorrect #{(i+1).ordinalize} column name, indicates format error.")
      return false
    end 
    return true
  rescue => e
    @errors.add(:base, "Unexpected exception. Possibly an empty #{sheet_info[:name]} sheet.")
    return false
  end

private

  # Check the allow empty array for the flag.
  def check_allow_empty(allow_empty, index)
    return false if allow_empty.nil?
    return allow_empty[index]
  end

end    