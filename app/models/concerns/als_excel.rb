# ALS Excel Reader
#
# @author Dave Iberson-Hurst
# @since 2.19.0
class AlsExcel

  C_CLASS_NAME = self.name

  require "roo"
  extend ActiveModel::Naming

  attr_reader   :errors
  attr_reader   :filename
  
  @@sheet_info =
  {
    forms: { length: 18, name: "Forms", first_column_name: "OID"},
    fields: { length: 51, name: "Fields", first_column_name: "FormOID"},
    data_dictionary_entries: { length: 5, name: "", first_column_name: "DataDictionaryName"}
  }
    
  # Initialize
  #
  # @param [String] filename full path to excel file
  # @return [AlsExcel] the object
  def initialize(filename)
    @blank = false
    @errors = ActiveModel::Errors.new(self)
    @filename = filename
    open_workbook
  rescue => e
    msg = "Exception raised opening Excel workbook filename=#{@filename}."
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    @workbook = nil
  end

  # List. List forms within file
  #
  # @return [Array] Array of hash form info
  def list
    results = []
    worksheets = @workbook.sheets
    return read_forms_sheet
  rescue => e
    msg = "Exception raised building form list."
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    @workbook = nil
    return []
  end

  # Form. Read a specified form
  #
  # @param [String] identifier the identifier of the desired form
  # @return [Array] Array of hash form info
  def form(identifier)
    # Get the set of current terminologies
    thesauri = []
    Thesaurus.current_set.each { |uri| thesauri << Thesaurus.find(uri.id, uri.namespace, false) }
    # Process form
    label = get_label(identifier)
    return self if !@errors.empty?
    result = new_form(identifier, label)
    read_fields_sheet(identifier).each do |item|
      if item[:mapping].empty?
        label = Form::Item::TextLabel.new
        label.label = item[:label] 
        label.ordinal = item[:ordinal]
        label.label_text = item[:question_text] 
        result.children.first.children << label
      else
        question = Form::Item::Question.new
        question.label = item[:label]
        dt_and_format = get_datatype_and_format(item)
        question.datatype = dt_and_format[:datatype]
        question.format = dt_and_format[:format]
        question.mapping = item[:mapping]
        question.question_text = item[:question_text]
        question.ordinal = item[:ordinal]
        question.note = item[:note]
        if !item[:code_list].empty? 
          cl_result = get_cl(item[:code_list], thesauri)
          if !cl_result[:cl].nil?
            read_data_dictionary_entries_sheet(item[:code_list]).each do |entry|
              cli = cl_result[:cl].children.find { |x| x.notation == entry[:code]}
              if !cli.nil?
                ref = OperationalReferenceV2.new
                ref.ordinal = entry[:ordinal]
                ref.subject_ref = cli.uri
                question.tc_refs << ref
              else
                question.note += "* Failed to find item with \n" if !cl_result[:note].empty?
              end
            end
          else
            question.note += "* #{cl_result[:note]}\n" if !cl_result[:note].empty?
          end
        end
        result.children.first.children << question
      end
    end
    return result
  rescue => e
    msg = "Exception raised building form."
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    @workbook = nil
    return self
  end

private

  # Find label
  def get_label(identifier)
    forms = self.list
    form = forms.find { |f| f[:identifier] == identifier }
    return form[:label] if !form.nil?
    @errors.add(:base, "Failed to find the form label, possible identifier mismatch")
    return ""
  end

  # New form
  def new_form(identifier, label)
    object = Form.new 
    object.scopedIdentifier.identifier = IsoScopedIdentifier.clean_identifier(identifier) # Make sure we remove anything nasty
    object.label = label
    group = Form::Group::Normal.new
    group.label = "Main Group"
    group.ordinal = 1
    object.children << group
    return object
  end
    
  # Open the workbook
  def open_workbook
    @workbook = Roo::Spreadsheet.open(@filename, extension: :xlsx) 
  end

  # Blanks row
  def blank_row?(row)
    value = @workbook.cell(row, 1) # Will always check column 1
    if !value.blank? and @blank
      @errors.add(:base, "Blank line detected before row #{row}, row ignored")
      return true
    elsif value.blank? and @blank
      return true
    elsif !value.blank? and !@blank
      return false
    else
      @blank = true
      return true
    end
  end
  
  # Check a cell
  def check_cell(row, col, allow_blank=false)
    value = @workbook.cell(row, col)
    if value.blank? and allow_blank
      value = ""
    elsif value.blank?
      @errors.add(:base, "Empty cell detected in row #{row}, column #{col}")
    end
    # Return value as string, strip leading and trailing spaces.
    return "#{value}".strip
  end
  
  # Check a sheet      
  def check_sheet(sheet_name)
    headers = {}
    @workbook.row(1).each_with_index { |header, i| headers[header] = i }
    if headers.length < @@sheet_info[sheet_name][:length]
      @errors.add(:base, "#{@@sheet_info[sheet_name][:name]} sheet in the excel file, incorrect column count, indicates format error")
      return 
    end
    if !headers.has_key?(@@sheet_info[sheet_name][:first_column_name]) 
      @errors.add(:base, "#{@@sheet_info[sheet_name][:name]} sheet in the excel file, incorrect 1st column name, indicates format error")
      return 
    end 
  rescue => e
    @errors.add(:base, "Unexpected exception. Possibly an empty #{@@sheet_info[sheet_name][:name]} sheet")
  end

  def read_forms_sheet
    @blank = false
    results = []
    @workbook.default_sheet = @workbook.sheets[1]
    check_sheet(:forms)
    return [] if !@errors.empty?
    ((@workbook.first_row + 1) .. @workbook.last_row).each do |row| 
      next if blank_row?(row)
      results << { identifier: check_cell(row, 1), label: check_cell(row, 3) }
    end
    return results
  end

  def read_fields_sheet(identifier)
    @blank = false
    results = []
    @workbook.default_sheet = @workbook.sheets[2]
    check_sheet(:fields)
    return results if !@errors.empty?
    ((@workbook.first_row + 1) .. @workbook.last_row).each do |row|
      next if blank_row?(row)
      next if check_cell(row, 1) != identifier
      ordinal = check_cell(row, 3).to_i
      label = check_cell(row, 5)            
      mapping = check_cell(row, 7, true)            
      data_format = check_cell(row, 8, true)            
      code_list = check_cell(row, 9, true)            
      control_type = check_cell(row, 12)            
      question_text = check_cell(row, 15, true)
      note = question_text.blank? ? "* No question text found *" : ""
      results << {label: label, ordinal: ordinal, mapping: mapping, data_format: data_format, 
        control_type: control_type, code_list: code_list, question_text: question_text, note: note}
    end
    return results
  end
    
  def read_data_dictionary_entries_sheet(identifier)
    @blank = false
    results = []
    @workbook.default_sheet = @workbook.sheets[5]
    check_sheet(:data_dictionary_entries)
    return results if !@errors.empty?
    ((@workbook.first_row + 1) .. @workbook.last_row).each do |row|
      next if blank_row?(row)
      next if check_cell(row, 1) != identifier
      code = check_cell(row, 2)            
      ordinal = check_cell(row, 3).to_i            
      decode = check_cell(row, 4)            
      results << {identifier: identifier, ordinal: ordinal, code: code, decode: decode}
    end
    return results
  end
  
  def get_cl(notation, thesauri)   
    thcs = []
    thesauri.each { |th| thcs += th.find_by_property({notation: notation}) }
    if thcs.empty?
      return {cl: nil, note: "No entries found for code list #{notation}."}
    elsif thcs.count == 1
      return {cl: thcs.first, note: ""}
    else
      entries = thcs.map { |tc| tc.identifier }.join(',')
      return {cl: nil, note: "Multiple entries [#{entries}] found for code list #{notation}, ignored." }
    end
  end

  def get_datatype_and_format(params)
    length = get_length(params)
    return {datatype: BaseDatatype::C_STRING, format: length} if !params[:code_list].blank?
    return {datatype: BaseDatatype::C_BOOLEAN, format: ""} if params[:control_type] == "CheckBox"
    return {datatype: BaseDatatype::C_TIME, format: ""} if time_format?(params[:data_format])
    return {datatype: BaseDatatype::C_DATE, format: ""} if date_format?(params[:data_format])
    return {datatype: BaseDatatype::C_INTEGER, format: length} if integer_format?(params[:data_format])
    return {datatype: BaseDatatype::C_FLOAT, format: params[:data_format]} if float_format?(params[:data_format])
    return {datatype: BaseDatatype::C_STRING, format: length} if string_format?(params[:data_format])
    return {datatype: BaseDatatype::C_STRING, format: length}
  end

  def integer_format?(format)
    return get_format(format) == :integer
  end

  def float_format?(format)
    return get_format(format) == :float
  end

  def string_format?(format)
    return get_format(format) == :string
  end

  def date_format?(format)
    return get_format(format.delete(' ')) == :date
  end

  def time_format?(format)
    return get_format(format) == :time
  end

  def get_format(format)
    return :time if format == "HH:nn"
    return :date if format == "dd-MMM-yyyy" || format == "ddMMMyyyy" 
    return :string if format.start_with?('$')
    return :float if format.include?('.')
    return :integer
  end

  def get_length(params)
    return "" if params[:data_format].empty?
    length = params[:data_format].dup
    return length.delete("^0-9")
  end

end

    