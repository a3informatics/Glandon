require "uri"

class Dashboard
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :namespace, :subject, :predicate, :object, :link, :linkId, :linkNamespace 
  
  # Constants
  C_CLASS_NAME = "Dashboard" 
  
  def self.find(id, ns)
    
    # Set the results
    results = Array.new
    
    # Build query
    query = UriManagement.buildNs(ns, []) +
      "SELECT ?p ?o WHERE\n" + 
      "{ \n" + 
      " :" + id + " ?p ?o . \n" +
      "} \n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      predicate = ModelUtility.getValue('p', true, node)
      objectUri = ModelUtility.getValue('o', true, node)
      objectLit = ModelUtility.getValue('o', false, node)
      if predicate != ""
        result = self.new
        result.id = id
        result.namespace = ns
        result.subject = chunk(":" + id)
        result.predicate = chunk(setPrefix(predicate, ns))
        if objectUri == ""
          result.object = chunk(objectLit)
          result.link = false
        else
          result.object = chunk(setPrefix(objectUri, ns))
          result.linkId = ModelUtility.extractCid(objectUri)
          result.linkNamespace = ModelUtility.extractNs(objectUri)
          result.link = true
        end
        results << result
      end
    end
    return results
  
  end

private 
  
  def self.setPrefix(uri, defaultNs)
    ns = ModelUtility.extractNs(uri)
    cid = ModelUtility.extractCid(uri)
    if ns == defaultNs 
      prefix = ""
    else
      prefix = UriManagement.getPrefix(ns)
      if prefix == nil
        prefix = ns
      end
    end
    return prefix + ":" + cid
  end

  def self.chunk(text)
    if text.length > 40 
      textArray = text.scan(/.{1,40}/)
      result = textArray.join(" ")
    else
      result = text
    end
    return result
  end

end
