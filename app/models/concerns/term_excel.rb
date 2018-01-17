class TermExcel

  C_CLASS_NAME = self.name
  C_NOT_SET = "-"
    
  require "roo"
  extend ActiveModel::Naming

  attr_reader   :errors
  attr_reader   :filename
  
  @@sheet_info =
  {
    harmonized_terminology_listing: { length: 31, name: "Harmonized_Terminology_Listing", first_column_name: "CODELIST_LONG_NAME"}
  }
    
  def initialize(filename)
    @errors = ActiveModel::Errors.new(self)
    @filename = filename
    open_workbook
  rescue => e
    exception(e, "Exception raised opening Excel workbook filename=#{@filename}.")
  end

  def list(prefix)
    return read_term_list(prefix)
  rescue => e
    exception(e, "Exception raised building terminology list.")
    return []
  end

  def code_list(identifier)
    return read_code_list(identifier)
  rescue => e
    exception(e, "Exception raised building code list.")
    return nil
  end

private

  # Exception
  def exception(e, msg)
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    @workbook = nil
  end

  # Open the workbook
  def open_workbook
    @workbook = Roo::Spreadsheet.open(@filename, extension: :xlsx) 
  end

  # Check a cell
  def check_cell(row, col, allow_blank=false)
    value = @workbook.cell(row, col)
    if value.blank? and allow_blank
      value = ""
    elsif value.blank?
      @errors.add(:base, "Empty cell detected in row #{row}, column #{col}.")
    end
    # Return value as string, strip leading and trailing spaces.
    return "#{value}".strip
  end
  
  # Check a sheet      
  def check_sheet(sheet_name)
    headers = {}
    @workbook.row(1).each_with_index { |header, i| headers[header] = i }
    if headers.length != @@sheet_info[sheet_name][:length]
      @errors.add(:base, "#{@@sheet_info[sheet_name][:name]} sheet in the excel file, incorrect column count, indicates format error.")
      return 
    end
    if !headers.has_key?(@@sheet_info[sheet_name][:first_column_name]) 
      @errors.add(:base, "#{@@sheet_info[sheet_name][:name]} sheet in the excel file, incorrect 1st column name, indicates format error.")
      return 
    end 
  rescue => e
    @errors.add(:base, "Unexpected exception. Possibly an empty #{@@sheet_info[sheet_name][:name]} sheet.")
  end

  def read_term_list(prefix)
    check = {}
    results = []
    @workbook.default_sheet = @workbook.sheets[1]
    check_sheet(:harmonized_terminology_listing)
    return [] if !@errors.empty?
    ((@workbook.first_row + 1) .. @workbook.last_row).each do |row|
      identifier = check_cell(row, 9)
      next if !identifier.start_with?(prefix)
      next if check.has_key?(identifier)
      results << { identifier: identifier, label: check_cell(row, 1), notation: check_cell(row, 2) } 
      check[identifier] = true
    end
    return results
  end

  # Read a specified code list
  def read_code_list(identifier)
    cl_set = false
    items = []
    code_list = {}
    @workbook.default_sheet = @workbook.sheets[1]
    check_sheet(:harmonized_terminology_listing)
    return {code_list: {}, code_list_items: []} if !@errors.empty?
    ((@workbook.first_row + 1) .. @workbook.last_row).each do |row|
      cl_identifier = check_cell(row, 9)
      next if cl_identifier != identifier
      code_list = { label: check_cell(row, 1), synonym: "", identifier: identifier, definition: check_cell(row, 8), 
        notation: check_cell(row, 2), preferredTerm: C_NOT_SET } if !cl_set
      items << { label: C_NOT_SET, synonym: "", identifier: check_cell(row, 10), definition: check_cell(row, 11), 
        notation: check_cell(row, 12), preferredTerm: preferred_term(row) }
      cl_set = true
    end
    return {code_list: code_list, items: items}
  end

  # Handle empty CRF text & preferred term
  def preferred_term(row)
    result = []
    result << check_cell(row, 15, true)
    result << check_cell(row, 14, true)
    result << C_NOT_SET
    return result.find { |x| !x.blank? }
  end

end