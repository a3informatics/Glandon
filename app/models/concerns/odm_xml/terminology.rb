class OdmXml::Terminology < OdmXml

  C_CLASS_NAME = self.name
  C_NOT_SET = "-"
    
  extend ActiveModel::Naming

  # List. List all code lists present in the file.
  #
  # @return [Array] array of hash entries containing the list of code lists (:identifier and :label).
  def list
    results = []
    @doc.xpath("//xmlns:CodeList").each { |n| results << { identifier: n.attributes["OID"].value, label: n.attributes["Name"].value } }
    return results
  rescue => e
    exception(C_CLASS_NAME, __method__.to_s, e, "Exception raised building form list.")
    return []
  end

  # Code List. Return the details for the specificed code list.
  #
  # @param [String] identifier the identifier of the code list required. CodeList OID is used.
  # @return [Hash] hash containing the code list details and array of children items
  def code_list(identifier)
    nodes = @doc.xpath("//xmlns:CodeList[@OID = '#{identifier}']")
    return {} if nodes.empty?
    cl = OdmCl.new(@doc, nodes.first, identifier)
    return cl.clis
  rescue => e
byebug
    exception(C_CLASS_NAME, __method__.to_s, e, "Exception raised building code list.")
    return {}
  end

private

  # Code List Class
  class OdmCl

    extend ActiveModel::Naming

    attr_reader :record
    attr_reader :items

    def initialize(doc, node, identifier)
      @doc = doc
      @identifier = identifier
      @items = []
      notation = node.attributes["SASFormatName"].nil? ? C_NOT_SET : node.attributes["SASFormatName"].value
      @record = { label: node.attributes["Name"].value, synonym: "", identifier: identifier.to_alphanumeric, definition: C_NOT_SET, 
        notation: notation, preferredTerm: C_NOT_SET }
    end

    def clis
      children = []
      @doc.xpath("//xmlns:CodeList[@OID = '#{@identifier}']/xmlns:CodeListItem").each { |n| self.items << OdmCli.new(n) }
      @doc.xpath("//xmlns:CodeList[@OID = '#{@identifier}']/xmlns:EnumeratedItem").each { |n| self.items << OdmCli.new(n) }
      self.items.each {|i| children << i.record if i.record != {}}
      return {code_list: self.record, items: children}
    end

  end
      
  # Code List Item Class
  class OdmCli

    extend ActiveModel::Naming

    attr_reader :record

    def initialize(node)
      @record = {}
      return if node.attributes["CodedValue"].nil?
      code = node.attributes["CodedValue"].value
      decode_nodes = node.xpath("xmlns:Decode/xmlns:TranslatedText[@xml:lang = 'en']")
      label = decode_nodes.empty? ? code : decode_nodes.first.text
      @record = { label: label, synonym: "", identifier: code.to_alphanumeric, definition: C_NOT_SET, notation: code, preferredTerm: C_NOT_SET }
    end

  end

end