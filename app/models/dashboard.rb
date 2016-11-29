require "uri"

class Dashboard
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :namespace, :subject, :predicate, :object, :link, :link_id, :link_namespace 
  
  # Constants
  C_CLASS_NAME = "Dashboard" 
  
  # Find all triples for the specified id and namespace
  #
  # @param id [String] The id
  # @param ns [String] The namespace
  # @return [Array] Array of objects contining the subject predicate and object plus the URI of the object if not a literal.
  def self.find(id, ns)
    results = Array.new
    query = UriManagement.buildNs(ns, []) +
      "SELECT ?p ?o WHERE\n" + 
      "{ \n" + 
      " :" + id + " ?p ?o . \n" +
      "} \n"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      predicate = ModelUtility.getValue('p', true, node)
      object_uri = ModelUtility.getValue('o', true, node)
      object_literal = ModelUtility.getValue('o', false, node)
      if predicate != ""
        result = self.new
        subject = UriV2.new({id: id, namespace: ns})
        result.id = id
        result.namespace = ns
        result.subject = setPrefix(subject.to_s, ns)
        result.predicate = setPrefix(predicate, ns)
        if object_uri == ""
          result.object = object_literal
          result.link_id = ""
          result.link_namespace = ""
          result.link = false
        else
          result.object = setPrefix(object_uri, ns)
          result.link_id = ModelUtility.extractCid(object_uri)
          result.link_namespace = ModelUtility.extractNs(object_uri)
          result.link = true
        end
        results << result
      end
    end
    return results
  end

private 
  
  # Find the prefix for the namespace it it exists. Replace default namespace with
  # empty string.
  def self.setPrefix(uri, default_namespace)
    ns = ModelUtility.extractNs(uri)
    cid = ModelUtility.extractCid(uri)
    if ns == default_namespace
      prefix = ""
    else
      prefix = UriManagement.getPrefix(ns)
      if prefix == nil
        prefix = ns
      end
    end
    return prefix + ":" + cid
  end

end
