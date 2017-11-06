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
        c_code = check_cell(workbook, row, 4, errors)
        type = check_cell(workbook, row, 5, errors)
        short_name = check_cell(workbook, row, 6, errors)
        instructions = check_cell(workbook, row, 11, errors, true)
        return if !errors.empty?
      	if !instructions.empty?
      		if type == "CDISC Codelist" 
	      		result[:source_cl_identifier] = c_code
	      		result[:source_cl_notation] = short_name
	        	result[:source_cli_identifier] = ""
	      	else
	      		result[:source_cl_identifier] = ""
	      		result[:source_cl_notation] = short_name
	        	result[:source_cli_identifier] = c_code
	      	end
	      	result[:instructions] = instructions
	      	result[:references] = instructions.scan(/C\d{4,6}/)
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
    	"Change Summary", "Original", "New", "Change Implementation Instructions"]
  	if workbook.nil?
      errors.add(:base, "Missing Main sheet in the excel file.")
      return 
    end
#byebug
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

    