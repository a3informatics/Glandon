require "uri"

class CdiscBc
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :managedItem, :name, :properties, :namespace
  validates_presence_of :id, :managedItem, :name, :properties, :namespace
  
  # Constants
  C_CLASS_NAME = "CdiscBc"
  C_NS_PREFIX = "mdrBcs"
  C_CID_PREFIX = "BC"
  
  # BC object
  #
  # object: id, scopeId, identifier, version, namespace, name, properties where properties is
  # properties [:alias => {:id, :alias, :qText, :pText, :format, :values[{:id, :value}]}]
  
  # Base namespace 
  #@@cdiscOrg # CDISC Organization identifier
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def version
    return self.managedItem.version
  end

  def internalVersion
    return self.managedItem.internalVersion
  end

  def identifier
    return self.managedItem.identifier
  end

  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    return @baseNs
  end
  
  def self.find(id, cdiscTerm)
    
    object = nil
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["cbc", "mdrItems", "isoI"]) +
      "SELECT ?bcName ?bcDtNode ?bcPropertyNode ?bcPropertyValueNode ?datatype ?propertyValue ?propertyAlias WHERE\n" + 
      "{ \n" + 
      " :" + id + " rdf:type cbc:BiomedicalConceptInstance . \n" +
      " :" + id + " cbc:name ?bcName .\n" + 
      " :" + id + " (cbc:hasItem | cbc:hasDatatype )%2B ?bcDtNode .\n" + 
      " OPTIONAL {\n" + 
      "   ?bcDtNode cbc:hasDatatypeRef ?datatype . \n" + 
      "   ?bcDtNode (cbc:hasProperty | cbc:hasComplexDatatype )%2B ?bcPropertyNode . \n" + 
      "   OPTIONAL { \n" + 
      "     ?bcPropertyNode (cbc:hasSimpleDatatype | cbc:nextValue)%2B ?bcPropertyValueNode .\n" + 
      "     ?bcPropertyValueNode rdf:type cbc:PropertyValue .\n" + 
      "     ?bcPropertyValueNode cbc:value ?propertyValue .\n" + 
      "     ?bcPropertyNode cbc:alias ?propertyAlias . \n" + 
      "   }\n" + 
      " }\n" + 
      "}\n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      bcSet = node.xpath("binding[@name='bcPropertyNode']/uri")
      nameSet = node.xpath("binding[@name='bcName']/literal")
      valueSet = node.xpath("binding[@name='propertyValue']/literal")
      aliasSet = node.xpath("binding[@name='propertyAlias']/literal")
      dtSet = node.xpath("binding[@name='datatype']/uri")
      if bcSet.length == 1 && nameSet.length == 1 && valueSet.length == 1 && aliasSet.length == 1 && dtSet.length == 1
        ConsoleLogger::log(C_CLASS_NAME,"find","Found")
        if object != nil
          properties = object.properties          
        else
          object = self.new 
          properties = Hash.new
          object.properties = properties
          object.id = id
          object.managedItem = ManagedItem.find(id, UriManagement.getNs(C_NS_PREFIX))
          object.name = nameSet[0].text
          ConsoleLogger::log(C_CLASS_NAME,"all","Object created, id=" + id)
        end
        propertyCid = ModelUtility.extractCid(bcSet[0].text)
        aliasName = aliasSet[0].text
        value = valueSet[0].text
        dt = dtSet[0].text
        if properties.has_key?(propertyCid)
          property = properties[propertyCid]
          values = property[:Values]
        else
          property = Hash.new
          values = Array.new
        end  
        properties[propertyCid] = property
        if value != ""
          clHash = {:cCode => value, :clis => CdiscCli.findByIdentifier(value, cdiscTerm)}
          values.push(clHash)
        end
        property[:Alias] = aliasName
        property[:Collect] = getCollect(aliasName)
        property[:QuestionText] = getQText(aliasName)
        property[:PromptText] = getQText(aliasName)
        property[:Datatype] = getDatatype(dt,values.length)
        property[:Values] = values
        property[:Format] = getFormat(property[:Datatype])
      end
    end
    return object  
    
  end

  def self.all()
    
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["cbc", "mdrItems", "isoI"]) +
      "SELECT ?bcRoot ?bcName WHERE\n" + 
      "{ \n" + 
      " ?bcRoot rdf:type cbc:BiomedicalConceptInstance . \n" +
      " ?bcRoot cbc:name ?bcName .\n" + 
      "}\n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='bcRoot']/uri")
      siSet = node.xpath("binding[@name='si']/uri")
      nameSet = node.xpath("binding[@name='bcName']/literal")
      ConsoleLogger::log(C_CLASS_NAME,"find","URI=" + uriSet.text)
      if uriSet.length == 1 && nameSet.length == 1 
        bcId = ModelUtility.extractCid(uriSet[0].text)
        if results.has_key?(bcId)
          object = results[bcId]
          properties = object.properties          
        else
          object = self.new 
          object.properties = Hash.new
          object.id = bcId
          object.managedItem = ManagedItem.find(bcId, UriManagement.getNs(C_NS_PREFIX))
          object.name = nameSet[0].text
          ConsoleLogger::log(C_CLASS_NAME,"all","Object created, id=" + bcId)
          results[bcId] = object
        end
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
