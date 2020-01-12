# CDISC Library API Reader. Reads a single url content
#
# @author Dave Iberson-Hurst
# @since 2.27.0
# @!attribute errors
#   @return [ActiveModel::Errors] Active Model errors class
class cdisc_library_api_reader

  extend ActiveModel::Naming

  attr_reader :errors

  # Initialize. Opens the workbook ready for processing.
  #
  # @param [String] url the url to the API endpoint
  # @return [Void] no return value
  def initialize(url)
    @errors = ActiveModel::Errors.new(self)
    @url = url
  end

  # Label
  #
  # @return [String] class label based on the inpout file name.
  def label
    File.basename(@full_path)
  end

  # Check Sheet
  #
  # @param [Symbol] import the import
  # @param [Symbol] sheet the sheet key as a symbol used in the configuration file
  # @return [Boolean] true if sheet check pass, false otherwise with errors added.
  def check_sheet(import, sheet)
    headers = []
    info = select_sheet(import, sheet)
    columns = info.dig(:columns)
    if columns.nil?
      @errors.add(:base, 
        "#{info[:selection][:label]} sheet in the excel file, no column list found.")
      return false
    end
    @workbook.row(1).each_with_index {|value, i| headers[i] = value}
    if headers.length != columns.length
      @errors.add(:base, 
        "#{info[:selection][:label]} sheet in the excel file, incorrect column count. Expected #{columns.length}, found #{headers.length}.")
      return false
    end
    headers.each_with_index do |header, i|
      next if header == columns[i]
      @errors.add(:base, "#{info[:selection][:label]} sheet in the excel file, incorrect #{(i+1).ordinalize} column name. Expected '#{columns[i]}', found '#{header}'.")
      return false
    end 
    return true
  rescue => e
    msg = "Exception raised '#{e}' checking worksheet for import '#{:import}' using sheet '#{:sheet}'."
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    return false
  end       

  # Check and Process Sheet
  #
  # @param [Symbol] import the import
  # @param [Symbol] sheet the sheet key as a symbol used in the configuration file
  # @return [Void] no return  
  def check_and_process_sheet(import, sheet)
    @engine.process(import, sheet) if check_sheet(import, sheet)
  end

  # Process Sheet
  #
  # @param [Symbol] import the import
  # @param [Symbol] sheet the sheet key as a symbol used in the configuration file
  # @return [Void] no return
  def process_sheet(import, sheet)
    @engine.process(import, sheet)
  end

private

  # Select a sheet and return the sheet info
  def select_sheet(import, sheet)
    info = @engine.sheet_info(import, sheet)
    if info[:selection].key?(:date)
      return by_date(info)
    elsif info[:selection].key?(:label)
      return by_label(info)
    elsif info[:selection].key?(:first)
      return by_first_sheet(info)
    end
    Errors.application_error(C_CLASS_NAME, __method__.to_s, "Invalid mechanism to find sheet.")
  end

  # Find the first sheet
  def by_first_sheet(info)
    @workbook.default_sheet = @workbook.sheets.first
    return info
  rescue => e
    Errors.application_error(C_CLASS_NAME, __method__.to_s, "Failed to find the first sheet.")
  end

  # Find the sheet by name contains string
  def by_label(info)
    @workbook.sheets.each do |s| 
      if s.include?(info[:selection][:label])
        @workbook.default_sheet = s 
        return info
      end
    end
    Errors.application_error(C_CLASS_NAME, __method__.to_s, "Failed to find sheet with name containing '#{info[:selection][:label]}'.")
  end

  # Find the sheet by name contains date
  def by_date(info)
    @workbook.sheets.each do |s| 
      if s =~ /\d\d\d\d-\d\d-\d\d/
        @workbook.default_sheet = s 
        return info
      end
    end
    Errors.application_error(C_CLASS_NAME, __method__.to_s, "Failed to find sheet with name including a date.")
  end

end    