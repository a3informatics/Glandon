class OdmXml::Forms

  C_CLASS_NAME = self.name
  C_NO_MAPPING = "[NO MAPPING]"
  C_NO_Q_TEXT = "*** Set Question Text ***"
  
  extend ActiveModel::Naming

  def initialize(parent)
    @parent = parent
    @doc = parent.doc
  end

  def list
    results = []
    @doc.xpath("//FormDef").each { |n| results << { identifier: n.attributes["OID"].value, label: n.attributes["Name"].value } }
    return results
  rescue => e
    @parent.exception(C_CLASS_NAME, __method__.to_s, e, "Exception raised building form list.")
    return []
  end

  def form(identifier)
    thesauri = []
    Thesaurus.current_set.each { |uri| thesauri << Thesaurus.find(uri.id, uri.namespace, false) }
    odm_form = OdmForm.new(self.list, identifier, thesauri)
    odm_form.groups(@doc)
    return odm_form.form
  rescue => e
    @parent.exception(C_CLASS_NAME, __method__.to_s, e, "Exception raised building form.")
    return self
  end

  class OdmForm

    extend ActiveModel::Naming

    attr_reader :oid
    attr_reader :form

    def initialize(list, identifier, thesauri)
      @thesauri = thesauri
      @oid = identifier
      source_form = list.find { |f| f[:identifier] == identifier }
      if source_form.nil?
        parent.error("Failed to find the form, possible identifier mismatch.") 
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
      doc.xpath("//FormDef[@OID = '#{@oid}']/ItemGroupRef").each { |n| results << OdmGroup.new(doc, n, @thesauri) }
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

    def initialize(doc, node, thesauri)
      @thesauri = thesauri
      @oid = node.attributes["ItemGroupOID"].value
      group_node = doc.xpath("//ItemGroupDef[@OID = '#{@oid}']")
      @group = Form::Group::Normal.new
      @group.label = group_node.first.attributes["Name"].value
      @group.ordinal = node.attributes["OrderNumber"].nil? ? 1 : node.attributes["OrderNumber"].value.to_i
    end

    def items(doc)
      results = []
      doc.xpath("//ItemGroupDef[@OID = '#{@oid}']/ItemRef").each { |n| results << OdmItem.new(doc, n, @thesauri) }
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

    def initialize(doc, node, thesauri)  
      @items = []
      @thesauri = thesauri
      @oid = node.attributes["ItemOID"].value
      item_node = doc.xpath("//ItemDef[@OID = '#{@oid}']")
      item = Form::Item::Question.new
      item.note = ""
      item.label = item_node.first.attributes["Name"].value
      dt_and_format = get_datatype_and_format(item_node)
      item.datatype = dt_and_format[:datatype]
      item.format = dt_and_format[:format]
      item.mapping = item_node.first.attributes["SDSVarName"].nil? ? "#{C_NO_MAPPING}" : item_node.first.attributes["SDSVarName"].value
      item.ordinal = node.attributes["OrderNumber"].nil? ? 1 : node.attributes["OrderNumber"].value.to_i
      q_text_node = node.xpath("//ItemDef[@OID = '#{@oid}']/Question/TranslatedText[@lang = 'en']")
      item.question_text = q_text_node.empty? ? "#{C_NO_Q_TEXT}" : parse_special(q_text_node.first.text.strip)
      cl_ref_node = item_node.xpath("CodeListRef")
      if !cl_ref_node.empty?
        cl_oid = cl_ref_node.first.attributes["CodeListOID"].value
        cl_node = node.xpath("//CodeList[@OID = '#{cl_oid}']")
        add_cl(cl_node.first, item)
      end
      @items << item
      mu_nodes = item_node.xpath("MeasurementUnitRef")
      if !mu_nodes.empty?
        mu_item = Form::Item::Question.new
        mu_item.note = ""
        mu_item.label = "#{item.label} units"
        mu_item.datatype = BaseDatatype::C_STRING
        mu_item.format = "20"
        mu_item.mapping = ""
        mu_item.ordinal = item.ordinal
        mu_item.question_text = "#{item.question_text} units"
        add_mu(doc, mu_nodes, mu_item)
        @items << mu_item
      end
    end

  private

    def parse_special(text)
      temp = Nokogiri::HTML.parse(text).text
      # @todo Better filtering and understand the issue a little more.
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

    def add_cl(node, question)
      ordinal = 1
      cli_nodes = node.xpath("CodeListItem")
      cli_nodes.each do |cli_node|
        result = get_cli(cli_node.attributes["CodedValue"].value)
        if !result[:cli].nil?
          ref = OperationalReferenceV2.new
          ref.ordinal = ordinal
          ref.subject_ref = result[:cli].uri
          question.tc_refs << ref
          ordinal += 1
        else
          question.note += "* #{result[:note]}\n" if !result[:note].empty?
        end
      end
    end

     def add_mu(doc, nodes, question)
      ordinal = 1
      nodes.each do |mu_ref_node|
        oid = mu_ref_node.attributes["MeasurementUnitOID"].value
        mu_node = doc.xpath("//MeasurementUnit[@OID = '#{oid}']/Symbol/TranslatedText[@lang = 'en']")
        result = get_cli(mu_node.first.text.strip)
        if !result[:cli].nil?
          ref = OperationalReferenceV2.new
          ref.ordinal = ordinal
          ref.subject_ref = result[:cli].uri
          question.tc_refs << ref
          ordinal += 1
        else
          question.note += "* #{result[:note]}\n" if !result[:note].empty?
        end
      end
    end

    def get_cli(notation)   
      thcs = []
      @thesauri.each { |th| thcs += th.find_by_property({notation: notation}) }
      if thcs.empty?
        return {cli: nil, note: "No entries found for code list item '#{notation}'."}
      elsif thcs.count == 1
        return {cli: thcs.first, note: ""}
      else
        entries = thcs.map { |tc| tc.identifier }.join(',')
        return {cli: nil, note: "Multiple entries [#{entries}] found for code list item '#{notation}', ignored." }
      end
    end

  end

end

    