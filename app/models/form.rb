require "uri"

class Form
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :scopedIdentifierId, :identifier, :version, :namespace, :name, :properties
  validates_presence_of :scopedIdentifierId, :identifier, :version, :namespace, :properties
  
  # Constants
  C_CLASS_NAME = "Form"
  
  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    #return @baseNs
  end
  
  def self.find(id,cdiscTerm)
    
    object = nil
    query = UriManagement.buildPrefix("mdrForm", ["bo","bf","cbc", "item", "isoI"]) +
      "SELECT ?a ?b ?c ?d ?e WHERE\n" + 
      "{ \n" + 
      " ?a rdf:type bf:Form . \n" +
      " ?a bo:name ?e . \n" +
      " ?a bf:hasGroupRelationship ?b . \n" +
      " ?b bf:hasItemRelationship ?c . \n" +
      " ?c bf:hasPropertyRelationship ?d . \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      uriSet = node.xpath("binding[@name='a']/uri")
      gSet = node.xpath("binding[@name='b']/uri")
      iSet = node.xpath("binding[@name='c']/uri")
      pSet = node.xpath("binding[@name='d']/uri")
      nSet = node.xpath("binding[@name='e']/literal")
      if uriSet.length == 1 && nSet.length == 1 && iSet.length == 1 && pSet.length == 1 && nSet.length == 1
        #ConsoleLogger::log(C_CLASS_NAME,"find","Found")
        if object != nil
          properties = object.properties          
        else
          object = self.new 
          properties = Hash.new
          object.properties = properties
          object.id = id
          #object.scopedIdentifierId = ModelUtility.extractCid(siSet[0].text)
          #si = ScopedIdentifier.find(object.scopedIdentifierId)
          #object.identifier = si.identifier
          #object.version = si.version
          object.name = nSet[0].text
        end
      end
    end
    return object  
    
  end

  def self.all()
    
    results = Hash.new
    query = UriManagement.buildPrefix("mdrForm", ["bo","bf","cbc", "item", "isoI"]) 
    
    ConsoleLogger::log(C_CLASS_NAME,"find","Query1=" + query)
    
    query = query +
      "SELECT ?a ?b WHERE\n" + 
      "{ \n" + 
      " ?a rdf:type bf:Form . \n" +
      " ?a bo:name ?b . \n" +
      "} \n"
    
    ConsoleLogger::log(C_CLASS_NAME,"find","Query2=" + query)
      
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      nSet = node.xpath("binding[@name='b']/literal")
      if uriSet.length == 1 && nSet.length == 1 
        #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.name = nSet[0].text
        results[object.id] = object
      end
    end
    return results  
    
  end

  def self.create(params)
    object = nil
    return object
  end

  def update
    return nil
  end

  def destroy
  end

private

  def self.getQText (text)
    parts = text.split("(")
    if parts.size == 2
      result = parts[0].strip
    else
      result = text
    end
    return result 
  end

  def self.getDatatype (text, count)
    result = ""
    if count > 0 then
      result = "CL"
    else
      parts = text.split("-")
      if parts.size == 2
        if parts[1] == "CD"
          result = "CL"
        elsif parts[1] == "PQR"
          result = "F"
        else
          result = ""
        end
      else
        result = ""
      end
    end
    ConsoleLogger::log(C_CLASS_NAME,"getDatatype","Text=" + text + ", Result=" + result + ", Count=" + count.to_s)
    return result 
  end

  def self.getFormat (dt)
    result = ""
    if dt == "CL"
      result = ""
    elsif dt == "F"
      result = "5.1"
    else
      result = ""
    end
    #ConsoleLogger::log(C_CLASS_NAME,"getFormat","Type=" + dt + ", Result=" + result)
    return result
  end
  
  def self.getCollect (text)
    result = ""
    parts = text.split("(")
    if parts.size == 2
      #ConsoleLogger::log(C_CLASS_NAME,"getCollect","Text=" + text + ", Part[1]=" + parts[1])
      local = parts[1]
      #ConsoleLogger::log(C_CLASS_NAME,"getCollect","local[0..5]=" + local[0..5])
      if local[0..5] == "--TEST"
        result = false
      else
        result = true
      end
    else
      result = true
    end
    #ConsoleLogger::log(C_CLASS_NAME,"getCollect","Text=" + text + ", Result=" + result.to_s)
    return result 
  end
  
end
