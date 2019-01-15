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
    msg = "Exception raised opening Excel workbook filename=#{@full_path}."
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    @workbook = nil
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
      @errors.add(:base, "#{info[:label]} sheet in the excel file, incorrect column count, indicates format error.")
      return false
    end
    headers.each_with_index do |header, i|
      next if header == info[:columns][i]
      @errors.add(:base, "#{info[:label]} sheet in the excel file, incorrect #{(i+1).ordinalize} column name, indicates format error.")
      return false
    end 
    return true
  rescue => e
    msg = "Exception raised checking worksheet for import #{:import} using sheet #{:sheet}."
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
    check_sheet(import, sheet)
    @engine.process(import, sheet)
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
    @workbook.sheets.each {|s| @workbook.default_sheet = s if s.include?(info[:label])}
    return info
  end

end    