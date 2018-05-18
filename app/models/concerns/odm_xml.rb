class OdmXml

  C_CLASS_NAME = self.name

  extend ActiveModel::Naming

  attr_reader   :errors
  attr_reader   :filename
  
  def initialize(filename)
    @filename = filename
    xml = PublicFile.read(filename)
    @doc = Nokogiri::XML(xml)
    @doc.remove_namespaces!
    @errors = ActiveModel::Errors.new(self)
  rescue => e
    msg = "Exception raised opening ODM XML file, filename=#{@filename}."
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
  end

  def list
    results = []
    @doc.xpath("//FormDef").each { |n| results << { identifier: n.attributes["OID"].value, label: n.attributes["Name"].value } }
    return results
  rescue => e
    msg = "Exception raised building form list."
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    return []
  end

  def form(identifier)
    # Get the set of current terminologies
    thesauri = []
    Thesaurus.current_set.each { |uri| thesauri << Thesaurus.find(uri.id, uri.namespace, false) }
    # Process form
    form = OdmForm.new(self.list, identifier)
    form.groups(@doc)
    return form
=begin
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
        question.note = ""
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
=end
    return result
  rescue => e
    msg = "Exception raised building form."
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, msg)
    return nil
  end

  class OdmForm

    extend ActiveModel::Naming

    attr_reader :oid
    attr_reader :form

    def initialize(list, identifier)  
      @oid = identifier
      source_form = list.find { |f| f[:identifier] == identifier }
      if source_form.nil?
        @errors.add(:base, "Failed to find the form, possible identifier mismatch.") 
        return
      else
        @form = Form.new 
        @form.scopedIdentifier.identifier = IsoScopedIdentifier.clean_identifier(identifier) # Make sure we remove anything nasty
        @form.label = source_form[:label]
        return
      end
    end

    def groups(doc)
      results = []
    byebug
      doc.xpath("//FormDef[@OID = '#{@oid}']/ItemGroupRef").each { |n| results << OdmGroup.new(self, doc, n) }
      results.each { |r| @form.children << r.group }
      return results
    end

  end
      
  class OdmGroup

    extend ActiveModel::Naming

    attr_reader :oid
    attr_reader :group

    def initialize(form, doc, node)  
      @oid = node.attributes["ItemGrouoOID"].value
      group = doc.xpath("//ItemGroupDef[@OID = '#{@oid}']")
      @group = Form::Group::Normal.new
      @group.label = group.attributes["Name"].value
      @group.ordinal = node.attributes["OrderNumber"].value
    end

    def items(doc)
      results = []
      doc.xpath("//ItemGroupDef[@OID = '#{@oid}']/ItemRef").each { |n| results << OdmItem.new(self, doc, n) }
      results.each { |r| @group.children << r.item }
      return results
    end

  end

  class OdmItem

    extend ActiveModel::Naming

    attr_reader :oid
    attr_reader :item

    def initialize(form, doc, node)  
      @oid = node.attributes["ItemOID"].value
      item = doc.xpath("//ItemDef[@OID = '#{@oid}']")

      @item = Form::Item::Question.new
      @item.label = group.attributes["Name"].value
        #dt_and_format = get_datatype_and_format(item)
        #question.datatype = dt_and_format[:datatype]
        #question.format = dt_and_format[:format]
      @item.mapping = group.attributes["SDSVarName"].value
      @item.ordinal = node.attributes["OrderNumber"].value
      @item.note = ""
      q_text = node.xpath("//ItemDef[@OID = '#{@oid}']/Question/TranslatedText[@xml:lang = 'en']")
      @item.question_text = q_text.first.text.strip
    end

  end

private
    
=begin

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
=end

end

    