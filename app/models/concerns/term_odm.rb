class TermOdm

  C_CLASS_NAME = self.name
  C_NOT_SET = "-"
    
  extend ActiveModel::Naming

  attr_reader   :errors
  attr_reader   :filename
  
  # Initialize. Initialize the class
  #
  # @param [String] filename the ODM filename, the full path
  # @return [TermOdm] class potentially containing errors
  def initialize(filename)
    @errors = ActiveModel::Errors.new(self)
    @filename = filename
    xml = PublicFile.read(filename)
    @doc = Nokogiri::XML(xml)
    @doc.remove_namespaces!
  rescue => e
    exception(e, "Exception raised opening ODM XML file, filename=#{@filename}.")
  end

  # List. List all code lists present in the file.
  #
  # @return [Array] array of hash entries containing the list of code lists (:identifier and :label).
  def list
    results = []
    @doc.xpath("//CodeList").each { |n| results << { identifier: n.attributes["OID"].value, label: n.attributes["Name"].value } }
    return results
  rescue => e
    exception(e, "Exception raised building form list.")
    return []
  end

  # Code List. Return the details for the specificed code list.
  #
  # @return [Hash] hash containing the code list details an darray of children items
  def code_list(identifier)
    nodes = @doc.xpath("//CodeList[@OID = '#{identifier}']")
    cl = OdmCl.new(@doc, nodes.first, identifier)
    return cl.clis
  rescue => e
    exception(e, "Exception raised building code list.")
    return {}
  end

  def self.clean_identifier(identifier)
    identifier.gsub(/[^A-Z0-9a-z]/i, '').upcase.strip
  end

private

  # Exception
  def exception(e, msg)
    ConsoleLogger::log(C_CLASS_NAME, __method__.to_s, "#{msg}\n#{e}\n#{e.backtrace}")
    @errors.add(:base, "#{msg} #{e}")
  end

  # Code List Class
  class OdmCl

    extend ActiveModel::Naming

    attr_reader :record
    attr_reader :items

    def initialize(doc, node, identifier)
      @doc = doc
      @identifier = identifier
      @items = []
      @record = { label: node.attributes["Name"].value, synonym: "", identifier: TermOdm.clean_identifier(identifier), definition: C_NOT_SET, 
        notation: node.attributes["SASFormatName"].value, preferredTerm: C_NOT_SET }
    end

    def clis
      children = []
      @doc.xpath("//CodeList[@OID = '#{@identifier}']/CodeListItem").each { |n| self.items << OdmCli.new(n) }
      self.items.each {|i| children << i.record}
      return {code_list: self.record, items: children}
    end

  end
      
  # Code List Item Class
  class OdmCli

    extend ActiveModel::Naming

    attr_reader :record

    def initialize(node)
      @record = {}
      decode_nodes = node.xpath("Decode/TranslatedText[@lang = 'en']")
      label = decode_nodes.empty? ? C_NO_LABEL : decode_nodes.first.text
      return if node.attributes["CodedValue"].nil?
      code = node.attributes["CodedValue"].value
      @record = { label: label, synonym: "", identifier: TermOdm.clean_identifier(code), definition: C_NOT_SET, notation: code, preferredTerm: C_NOT_SET }
    end

  end

end