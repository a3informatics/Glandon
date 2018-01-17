class AlsExcel

  C_CLASS_NAME = self.name

  require "roo"
  extend ActiveModel::Naming

  attr_reader   :errors
  attr_reader   :filename
  
  @@sheet_info =
  {
    forms: { length: 19, name: "Forms", first_column_name: "OID"},
    fields: { length: 53, name: "Fields", first_column_name: "FormOID"},
    data_dictionary_entries: { length: 6, name: "", first_column_name: "DataDictionaryName"}
  }
    
  def initialize(filename)
    @errors = ActiveModel::Errors.new(self)
    @filename = filename
    open_workbook
  rescue => e
    msg = "Exception raised opening Excel workbook filename=#{@filename}."
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    @workbook = nil
  end

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

  def form(identifier)
    label = get_label(identifier)
    return if !@errors.empty?
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
        dt_and_l = get_datatype_and_length(item)
        question.datatype = dt_and_l[:datatype]
        question.format = dt_and_l[:length]
        question.mapping = item[:mapping]
        question.question_text = item[:question_text]
        question.ordinal = item[:ordinal]
        question.note = ""
        if !item[:code_list].empty? 
          cl_result = get_cl(item[:code_list])
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
    return nil
  end

private

  # Find label
  def get_label(identifier)
    forms = self.list
    form = forms.find { |f| f[:identifier] == identifier }
    return form[:label] if !form.nil?
    @errors.add(:base, "Failed to find the form label.")
    return ""
  end

  # New form
  def new_form(identifier, label)
    #new_identifier = identifier.dup
    object = Form.new 
    #object.scopedIdentifier.identifier = new_identifier.gsub(/[^0-9a-z ]/i, ' ') # Make sure we remove anything nasty
    object.scopedIdentifier.identifier = identifier.gsub(/[^0-9a-z ]/i, ' ') # Make sure we remove anything nasty
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

  def read_forms_sheet
    results = []
    @workbook.default_sheet = @workbook.sheets[1]
    check_sheet(:forms)
    return [] if !@errors.empty?
    ((@workbook.first_row + 1) .. @workbook.last_row).each { |row| results << { identifier: check_cell(row, 1), label: check_cell(row, 3) } }
    return results
  end

  def read_fields_sheet(identifier)
    results = []
    @workbook.default_sheet = @workbook.sheets[2]
    check_sheet(:fields)
    return results if !@errors.empty?
    ((@workbook.first_row + 1) .. @workbook.last_row).each do |row|
      next if check_cell(row, 1) != identifier
      ordinal = check_cell(row, 3).to_i
      label = check_cell(row, 5)            
      mapping = check_cell(row, 7, true)            
      data_format = check_cell(row, 8, true)            
      code_list = check_cell(row, 9, true)            
      control_type = check_cell(row, 12)            
      question_text = check_cell(row, 15)            
      results << {label: label, ordinal: ordinal, mapping: mapping, data_format: data_format, 
        control_type: control_type, code_list: code_list, question_text: question_text}
    end
    return results
  end
    
  def read_data_dictionary_entries_sheet(identifier)
    results = []
    @workbook.default_sheet = @workbook.sheets[5]
    check_sheet(:data_dictionary_entries)
    return results if !@errors.empty?
    ((@workbook.first_row + 1) .. @workbook.last_row).each do |row|
      next if check_cell(row, 1) != identifier
      code = check_cell(row, 2)            
      ordinal = check_cell(row, 3).to_i            
      decode = check_cell(row, 4)            
      results << {identifier: identifier, ordinal: ordinal, code: code, decode: decode}
    end
    return results
  end
  
  def get_cl(notation)
    thcs = []
    ths ||= Thesaurus.current_set
    ths.each { |th| thcs += ThesaurusConcept.find_by_property({notation: notation}, th.namespace) }
byebug
    if thcs.empty?
      return {cl: nil, note: "No entries found for code list #{notation}."}
    elsif thcs.count == 1
      return {cl: thcs.first, note: ""}
    else
      entries = thcs.map { |tc| tc.identifier }.join(',')
      return {cl: nil, note: "Multiple entries [#{entries}] found for code list #{notation}, ignored." }
    end
  end

  def get_datatype_and_length(params)
    length = get_length(params)
    return {datatype: BaseDatatype::C_STRING, length: length} if !params[:code_list].blank?
    return {datatype: BaseDatatype::C_BOOLEAN, length: ""} if params[:control_type] == "CheckBox"
    return {datatype: BaseDatatype::C_TIME, length: ""} if params[:data_format] == "HH:nn"
    return {datatype: BaseDatatype::C_DATE, length: ""} if params[:data_format].delete(' ') == "dd-MMM-yyyy"
    return {datatype: BaseDatatype::C_STRING, length: length} if params[:control_type] == "Text"
    return {datatype: BaseDatatype::C_STRING, length: length}
  end

  def get_length(params)
    return "" if params[:data_format].empty?
    length = params[:data_format].dup
    return length.delete("^0-9")
  end

end

    