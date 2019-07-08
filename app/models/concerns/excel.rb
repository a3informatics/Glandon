# Excel. Base class for reading and processing excel files
#
# @author Dave Iberson-Hurst
# @since 2.20.3
# @!attribute errors
#   @return [ActiveModel::Errors] Active Model errors class
# @!attribute engine
#   @return [Excel::Engine] the reader engine
# @!attribute full_path
#   @return [Pathname] the pathname for the file being read
class Excel

  C_CLASS_NAME = self.name

  require "roo"
  extend ActiveModel::Naming

  attr_reader :errors
  attr_reader :engine
  attr_reader :full_path

  # Initialize. Opens the workbook ready for processing.
  #
  # @param [Pathname] full_path the Pathname object for the file to be opened.
  # @return [Void] no return value
  def initialize(full_path)
    @errors = ActiveModel::Errors.new(self)
    @full_path = full_path
    @workbook = Roo::Spreadsheet.open(@full_path.to_s, extension: :xlsx) 
    @engine = Excel::Engine.new(self, @workbook) # Needs to be after workbook setup
  rescue => e
    msg = "Exception raised opening Excel workbook filename=#{@full_path}. #{e}"
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    @workbook = nil
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
    @workbook.row(1).each_with_index {|value, i| headers[i] = value}
    if headers.length != info[:columns].length
      @errors.add(:base, 
        "#{info[:selection][:label]} sheet in the excel file, incorrect column count. Expected #{info[:columns].length}, found #{headers.length}.")
      return false
    end
    headers.each_with_index do |header, i|
      next if header == info[:columns][i]
      @errors.add(:base, "#{info[:selection][:label]} sheet in the excel file, incorrect #{(i+1).ordinalize} column name. Expected '#{info[:columns][i]}', found '#{header}'.")
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
      by_first_sheet(info)
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