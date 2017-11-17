require "roo"

module TermChangeExcel

  # Constants
  C_CLASS_NAME = "TermChangeExcel"

  # Reads the excel file for SDTM Model.
  def self.read_changes(params, errors)
  	results = []
    filename = params[:files][0]
    workbook = open_workbook(filename)
    if !workbook.nil?
      worksheets = workbook.sheets
      workbook.default_sheet = workbook.sheets[0]
      check_main(workbook, errors)
      return if !errors.empty?
      ((workbook.first_row + 1) .. workbook.last_row).each do |row|
      	result = {}
        cell = check_cell(workbook, row, 12, errors, true)
        process = cell.blank? ? false : cell.to_bool
        if process
      		prev_cl = check_cell(workbook, row, 13, errors)
        	prev_cli = check_cell(workbook, row, 14, errors, true)
        	new_cl = check_cell(workbook, row, 15, errors)
        	new_cli = check_cell(workbook, row, 16, errors, true)
        	instructions = check_cell(workbook, row, 17, errors)
        	return if !errors.empty?
      		result[:previous_cl] = prev_cl.scan(/C\d{1,}/).first
	      	result[:previous_cli] = prev_cli.scan(/C\d{1,}/)
	      	result[:new_cl] = new_cl.scan(/C\d{1,}/)
	      	result[:new_cli] = new_cli.scan(/C\d{1,}/)
	      	result[:instructions] = instructions
	      	errors.add(:base, "Multiple new Code Lists with Code List Items.") if result[:new_cl].count > 1 && result[:new_cli].count > 0
    			errors.add(:base, "Multiple previous to new mappings.") if result[:previous_cli].count > 1 && result[:new_cl].count > 1
    			errors.add(:base, "Multiple previous to new mappings.") if result[:previous_cli].count > 1 && result[:new_cli].count > 1
    			return if !errors.empty?
      		results << result
	      end
      end
    else
    	errors.add(:base, "Could not open the import file.")
    	return
    end
    return results
  end

private

  def self.open_workbook(filename)
    workbook = Roo::Spreadsheet.open(filename, extension: :xlsx) 
  rescue => e
    workbook = nil
  end

  def self.check_cell(workbook, row, col, errors, allow_blank=false)
    value = workbook.cell(row, col)
    if value.blank? and allow_blank
      value = ""
    elsif value.blank?
      errors.add(:base, "Empty cell detected in row #{row}, column #{col}.")
    end
    # Return value as string, strip leading and trailing spaces.
    return "#{value}".strip
  end
              
  def self.check_main(workbook, errors)
    columns = ["Release Date", "Request Code", "Change Type", "NCI Code", "CDISC Term Type", "CDISC Codelist (Short Name)", "CDISC Codelist (Long Name)", 
    	"Change Summary", "Original", "New", "Change Implementation Instructions", "Use", "Prev Codelist", "Prev Term", "New Codelists", "New Terms", "Comment"]
  	if workbook.nil?
      errors.add(:base, "Missing Main sheet in the excel file.")
      return 
    end
    if workbook.row(1).count != columns.count
      errors.add(:base, "Main sheet in the excel file, incorrect column count, indicates format error.")
      return 
    end
    columns.each_with_index do |column, index|
    	if column != workbook.row(1)[index]
        errors.add(:base, "Main sheet in the excel file, incorrect column name for col #{index+1}, indicates format error.")
        return 
      end
    end 
  rescue => e
    errors.add(:base, "Unexpected exception. Possibly an empty Main sheet.")
  end

end

    