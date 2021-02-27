require 'cgi'

class OdmXml::Forms < OdmXml

  C_CLASS_NAME = self.name
  C_NO_MAPPING = "[NO MAPPING]"
  C_NO_Q_TEXT = "*** Set Question Text ***"
  
  extend ActiveModel::Naming

  # List. List all forms present in the file.
  #
  # @return [Array] array of hash entries containing the list of code lists (:identifier and :label).
  def list
    results = []
    @doc.xpath("//xmlns:FormDef").each { |n| results << { identifier: n.attributes["OID"].value, label: n.attributes["Name"].value } }
    return results
  rescue => e
    exception(C_CLASS_NAME, __method__.to_s, e, "Exception raised building form list.")
    return []
  end

  # Form. Return the details for the specificed form.
  #
  # @param [String] identifier the identifier of the code list required. Form OID is used.
  # @return [Form] object containing the form.
  def form(identifier)
    odm_form = OdmForm.new(self.list, identifier, self)
    return self if self.errors.any?
    odm_form.groups(@doc)
    return odm_form.form
  rescue => e
    exception(C_CLASS_NAME, __method__.to_s, e, "Exception raised building form.")
    return self
  end

  class Ordinal

    def initialize
      @counter = 1
    end

    def increment
      @counter += 1
    end

    def value
      return @counter
    end

  end

  class OdmForm

    extend ActiveModel::Naming

    attr_reader :oid
    attr_reader :form

    def initialize(list, identifier, parent)
      @oid = identifier
      source_form = list.find { |f| f[:identifier] == identifier }
      if source_form.nil?
        parent.error(self.class.name, __method__.to_s, "Failed to find the form, possible identifier mismatch.") 
      else
        @form = Form.new 
        @form.set_initial(IsoScopedIdentifierV2.clean_identifier(identifier)) # Make sure we remove anything nasty
        @form.label = source_form[:label]
      end
    end

    def groups(doc)
      results = []
      doc.xpath("//xmlns:FormDef[@OID = '#{@oid}']/xmlns:ItemGroupRef").each { |n| results << OdmGroup.new(doc, n) }
      results.sort_by! {|r| r.group.ordinal}
      ordinal = 1
      results.each do |r| 
        r.group.ordinal = ordinal
        @form.children << r.group 
        r.items(doc)
        ordinal += 1
      end
      return results
    end

  end
      
  class OdmGroup

    extend ActiveModel::Naming

    attr_reader :oid
    attr_reader :group

    def initialize(doc, node)
      @oid = node.attributes["ItemGroupOID"].value
      group_node = doc.xpath("//xmlns:ItemGroupDef[@OID = '#{@oid}']")
      @group = Form::Group::Normal.new
      @group.label = group_node.first.attributes["Name"].value
      @group.ordinal = node.attributes["OrderNumber"].nil? ? 1 : node.attributes["OrderNumber"].value.to_i
    end

    def items(doc)
      results = []
      doc.xpath("//xmlns:ItemGroupDef[@OID = '#{@oid}']/xmlns:ItemRef").each { |n| results << OdmItem.new(doc, n) }
      results.sort_by! {|r| r.items.first.ordinal}
      ordinal = 1
      results.each do |result|
        result.items.each do |item| 
          item.ordinal = ordinal
          @group.children << item
          ordinal += 1
        end
      end
      return results
    end

  end

  class OdmItem

    extend ActiveModel::Naming

    attr_reader :oid
    attr_reader :items

    def initialize(doc, node)  
      @items = []
      @oid = node.attributes["ItemOID"].value
      item_node = doc.xpath("//xmlns:ItemDef[@OID = '#{@oid}']")
      item = Form::Item::Question.new
      item.label = item_node.first.attributes["Name"].value
      impl_notes = item_node.xpath("xmlns:Alias[@Context='implementationNotes']")
      item.note = impl_notes.empty? ? "" : impl_notes.first.attributes["Name"].value
      compl_inst = item_node.xpath("xmlns:Alias[@Context='completionInstructions']")
      item.completion = compl_inst.empty? ? "" : compl_inst.first.attributes["Name"].value
      dt_and_format = get_datatype_and_format(item_node)
      item.datatype = dt_and_format[:datatype]
      item.format = dt_and_format[:format]
      item.mapping = item_node.first.attributes["SDSVarName"].nil? ? "#{C_NO_MAPPING}" : item_node.first.attributes["SDSVarName"].value
      item.ordinal = node.attributes["OrderNumber"].nil? ? 1 : node.attributes["OrderNumber"].value.to_i
      add_question(item_node.first, item)      
      cl_ref_node = item_node.xpath("CodeListRef")
      if !cl_ref_node.empty?
        item.datatype = BaseDatatype::C_STRING
        cl_oid = cl_ref_node.first.attributes["CodeListOID"].value
        cl_node = node.xpath("//xmlns:CodeList[@OID = '#{cl_oid}']")
        add_cl(cl_node.first, item)
      end
      @items << item
      mu_nodes = item_node.xpath("xmlns:MeasurementUnitRef")
      if !mu_nodes.empty?
        mu_item = Form::Item::Question.new
        mu_item.note = ""
        mu_item.label = "#{item.label} units"
        mu_item.datatype = BaseDatatype::C_STRING
        mu_item.format = "20"
        mu_item.mapping = "#{C_NO_MAPPING}"
        mu_item.ordinal = item.ordinal
        mu_item.question_text = "#{item.question_text} units"
        add_mu(doc, mu_nodes, mu_item)
        @items << mu_item
      end
    end

  private

    def remove_trailing_special(text)
      return text.gsub(/[^0-9A-Za-z ._\\\-\/\\]/, "")
    end

    def parse_special(text)
      temp = CGI.unescapeHTML(text)
      temp = Nokogiri::HTML.parse(temp).text
      # @todo Better filtering and understand the issue a little more.
      temp = temp.gsub(/[^0-9A-Za-z .!?,'"_\\\-\/\\ ()[\\]~#*+@=:;&|<>]/, "-removed-")
      return temp.gsub("\n", " ")
    end

    def get_datatype_and_format(node)
      l_attrib = node.first.attributes["Length"]
      dt_attrib = node.first.attributes["DataType"]
      sd_attrib = node.first.attributes["SignificantDigits"]
      length = l_attrib.nil? ? "20" : l_attrib.value
      datatype = dt_attrib.nil? ? BaseDatatype::C_STRING : BaseDatatype.from_xsd_fragment(dt_attrib.value)
      sig_digits = sd_attrib.nil? ? "0" : sd_attrib.value
      case datatype
        when BaseDatatype::C_DATE, BaseDatatype::C_TIME, BaseDatatype::C_DATETIME, BaseDatatype::C_BOOLEAN
          return {datatype: datatype, format: ""}
        when BaseDatatype::C_FLOAT
          return {datatype: datatype, format: "#{length}.#{sig_digits}"}        
        when BaseDatatype::C_INTEGER
          return {datatype: datatype, format: "#{length}"}        
        else
          return {datatype: BaseDatatype::C_STRING, format: length}
      end
    end

    def add_question(node, question)
      question.question_text = "#{C_NO_Q_TEXT}"
      q_node = node.xpath("xmlns:Question")
      q_text_node = translated_text_node(q_node)
      return if question_normal(q_text_node, question)
      return if question_name(node, question)
    end

    def question_normal(node, question)
      return false if node.nil?
      question.question_text = parse_special(node.text.strip)
      return true
    end

    def question_name(node, question)
      return false if node.nil?
      return false if node.attributes["Name"].blank?
      question.question_text = node.attributes["Name"].value
      return true
    end

    def add_cl(node, question)
      cli_nodes = node.xpath("xmlns:CodeListItem")
      return if cli_nodes.empty?
      return if alias_cl(node, question, cli_nodes)
      return if sas_format_cl(node, question, cli_nodes)
      return if oid_cl(node, question, cli_nodes)
    end

    def alias_cl(node, question, cli_nodes)
      alias_nodes = node.xpath("xmlns:Alias[@Context='nci:ExtCodeID']")
      return false if alias_nodes.empty?
      return find_cl({identifier: alias_nodes.first.attributes["Name"].value}, question, cli_nodes)
    end

    def sas_format_cl(node, question, cli_nodes)
      return false if node.attributes["SASFormatName"].nil?
      text = node.attributes["SASFormatName"].value
      text = text.gsub(/[^0-9A-Za-z]/, "") # Remove any non-alphanumeric, e.g. $
      text = text.upcase # Make sure it has a chance of matching 
      return find_cl({identifier: text}, question, cli_nodes) if NciThesaurusUtility.c_code?(text)      
      return find_cl({notation: text}, question, cli_nodes)
    end

    def oid_cl(node, question, cli_nodes)
      return find_cl({notation: OdmXml.clean_identifier(node.attributes["OID"].value)}, question, cli_nodes)
    end

    def find_cl(params, question, cli_nodes)
      result = get_tc(params)
      if !result[:tc].nil?
        ordinal = Ordinal.new
        cli_nodes.each do |cli_node|
          info = {notation: "", preferred_term: ""}
          next if notation_cli(result, cli_node, question, ordinal, info)
          next if preferred_term_cli(result, cli_node, question, ordinal, info)
          question.note += "* No entries found in code list '#{result[:tc].identifier}' for item with submission value: '#{info[:notation]}' or preferred term: '#{info[:preferred_term]}'.\n"
        end
        return true
      else
        question.note += "* No entries found for code list, parameters #{params_to_s(params)}.\n"
        return false
      end
    end

    def notation_cli(result, cli_node, question, ordinal, info)
      info[:notation] = remove_trailing_special(cli_node.attributes["CodedValue"].value) # Little extra to strip any nasty characters off the end
      cli = result[:tc].children.find { |x| x.notation == info[:notation]}
      return false if cli.nil?
      return add_op_ref(cli, question, ordinal)
    end

    def preferred_term_cli(result, cli_node, question, ordinal, info)
      pt_nodes = cli_node.xpath("xmlns:Decode/xmlns:TranslatedText")
      return false if pt_nodes.empty?
      info[:preferred_term] = pt_nodes.first.text.strip
      cli = result[:tc].children.find { |x| x.preferred_term_objects.label.upcase == info[:preferred_term].upcase}
      return false if cli.nil?
      add_op_ref(cli, question, ordinal)
      return true
    end

    def add_op_ref(cli, question, ordinal)
      ref = OperationalReferenceV3.new
      ref.ordinal = ordinal.value
      ref.reference = cli.uri
      question.has_coded_value << ref
      ordinal.increment
      return true
    end      

    def add_mu(doc, nodes, question)
      ordinal = Ordinal.new
      nodes.each do |mu_ref_node|
        oid = mu_ref_node.attributes["MeasurementUnitOID"].value
        symbol = doc.xpath("//xmlns:MeasurementUnit[@OID = '#{oid}']/xmlns:Symbol")
        mu_node = translated_text(symbol)
        result = get_tc({notation: parse_special(mu_node.first.text.strip)})
        if !result[:tc].nil?
          add_op_ref(result[:tc], question, ordinal)
        else
          question.note += "* #{result[:note]}\n" if !result[:note].empty?
        end
      end
    end

    def get_tc(params)   
      thcs = Thesaurus.where_children_current(params)
      if thcs.empty?
        return {tc: nil, note: "No entries found for parameters #{params_to_s(params)}."}
      elsif thcs.count == 1
        thcs.first.children_objects
        return {tc: thcs.first, note: ""}
      else
        entries = thcs.map { |tc| tc.identifier }.join(',')
        return {tc: nil, note: "Multiple entries [#{entries}] found for parameters #{params_to_s(params)}, ignored." }
      end
    end

    def params_to_s(params)
      parts = []
      params.each {|k,v| parts << "'#{k}=#{v}'"}
      return "[#{parts.join(", ")}]"
    end

    def translated_text_node(node)
      return "" if node.empty?
      node_en = node.first.xpath("xmlns:TranslatedText[@lang = 'en']")
      node_non = node.first.xpath("xmlns:TranslatedText")
      return node_en.first if node_en.any?
      return node_non.first if node_non.any?
      nil
    end

  end

end

    