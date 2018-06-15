class TermOdm

  C_CLASS_NAME = self.name
  C_NOT_SET = "-"
    
  extend ActiveModel::Naming

  attr_reader   :errors
  attr_reader   :filename
  
  def initialize(filename)
    @errors = ActiveModel::Errors.new(self)
    @filename = filename
    xml = PublicFile.read(filename)
    @doc = Nokogiri::XML(xml)
    @doc.remove_namespaces!
  rescue => e
    exception(e, "Exception raised opening ODM XML file, filename=#{@filename}.")
  end

  def list
    results = []
    @doc.xpath("//CodeList").each { |n| results << { identifier: n.attributes["OID"].value, label: n.attributes["Name"].value } }
    return results
  rescue => e
    exception(e, "Exception raised building form list.")
    return []
  end

  def code_list(identifier)
    nodes = doc.xpath("//CodeList[@OID = '#{@oid}']/CodeListItems")
    cl = OdmCl.new(doc, nodes.first)
    cl.clis(doc, nodes.first)
    return cl.to_hash
  rescue => e
    exception(e, "Exception raised building code list.")
    return {}
  end

private

  # Exception
  def exception(e, msg)
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, "#{msg} #{e}")
  end

  class OdmCl

    extend ActiveModel::Naming

    attr_reader :record
    attr_reader :items

    def initialize(node, identifier)
      @record = { label: node.attributes["Name"].value, synonym: "", identifier: identifier, definition: C_NOT_SET, 
        notation: node.attributes["SASFormatName"].value, preferredTerm: C_NOT_SET }
    end

    def clis(doc, node)
      results = []
      doc.xpath("//CodeList[@OID = '#{@oid}']/CodeListItem").each { |n| results << OdmCli.new(doc, n) }
      return results
    end

    def to_hash
      children = []
      self.items.each {|i| children << i.record}
      return {code_list: self.record, items: children}
    end

  end
      
  class OdmCli

    extend ActiveModel::Naming

    attr_reader :record

    def initialize(doc, node)
      decode_nodes = node.xpath("Decode/TranslatedText[@lang = 'en']")
      label = decode_nodes.empty? ? C_NO_LABEL : q_text_node.first.text
      @record = { label: label, synonym: "", identifier: identifier, definition: C_NOT_SET, 
        notation: node.attributes["CodedValue"].value, preferredTerm: C_NOT_SET }
    end

  end

end