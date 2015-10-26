require "uri"

class Form::FormGroup
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :name, :optional, :note, :ordinal, :repeating, :items
  validates_presence_of :id, :name, :optional, :note, :ordinal, :repeating, :items
  
  # Constants
  C_NS_PREFIX = "mdrForms"
  C_CLASS_NAME = "FormGroup"
  C_CID_PREFIX = "FG"
  C_ID_SEPARATOR = "_"
  
  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    #return @baseNs
  end
  
  def self.find(id, cdiscTerm)
    
    object = nil
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bf"]) +
      "SELECT ?b ?c ?d ?e ?f WHERE\n" + 
      "{ \n" + 
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:name ?b . \n" +
      " :" + id + " bf:optional ?c . \n" +
      " :" + id + " bf:note ?d . \n" +
      " :" + id + " bf:ordinal ?e . \n" +
      " :" + id + " bf:repeating ?f . \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      nameSet = node.xpath("binding[@name='b']/literal")
      optSet = node.xpath("binding[@name='c']/literal")
      noteSet = node.xpath("binding[@name='d']/literal")
      ordSet = node.xpath("binding[@name='e']/literal")
      rptSet = node.xpath("binding[@name='f']/literal")
      if nameSet.length == 1 && optSet.length == 1 && noteSet.length == 1 && ordSet.length == 1 && rptSet.length == 1 
        object = self.new 
        object.items = Hash.new
        object.id = id
        ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id)
        object.name = nameSet[0].text
        object.optional = optSet[0].text
        object.note = noteSet[0].text
        object.ordinal = ordSet[0].text
        object.repeating = rptSet[0].text
        object.items = Form::FormItem.findForGroup(object.id, cdiscTerm)
      end
    end
    return object  
    
  end

  def self.findForForm(formId, cdiscTerm)
    
    ConsoleLogger::log(C_CLASS_NAME,"findForForm","***** ENTRY *****")
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bf"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g WHERE\n" + 
      "{ \n" + 
      " ?a rdf:type bf:Group . \n" +
      " ?a bf:isGroupOf :" + formId + " . \n" +
      " ?a bf:name ?b . \n" +
      " ?a bf:optional ?c . \n" +
      " ?a bf:note ?d . \n" +
      " ?a bf:ordinal ?e . \n" +
      " ?a bf:repeating ?f . \n" +
      #" ?a bf:hasBiomedicalConcept ?g . \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      uriSet = node.xpath("binding[@name='a']/uri")
      nameSet = node.xpath("binding[@name='b']/literal")
      optSet = node.xpath("binding[@name='c']/literal")
      noteSet = node.xpath("binding[@name='d']/literal")
      ordSet = node.xpath("binding[@name='e']/literal")
      rptSet = node.xpath("binding[@name='f']/literal")
      bcSet = node.xpath("binding[@name='g']/uri")
      if uriSet.length == 1 && nameSet.length == 1 && optSet.length == 1 && noteSet.length == 1 && ordSet.length == 1 && rptSet.length == 1 
        id = ModelUtility.extractCid(uriSet[0].text)
        ConsoleLogger::log(C_CLASS_NAME,"findForForm","Id=" + id)
        if results.has_key?(id)
          object = results[id]
        else
          object = self.new 
          object.id = ModelUtility.extractCid(uriSet[0].text)
          object.name = nameSet[0].text
          object.optional = optSet[0].text
          object.note = noteSet[0].text
          object.ordinal = ordSet[0].text
          object.repeating = rptSet[0].text
          object.items = Form::FormItem.findForGroup(object.id, cdiscTerm)
          results[id] = object
        end
      end
    end
    return results
    
  end
  
  def self.all()
    return nil
  end

  def self.create_placeholder (formId, cidPrefix, ordinal, version, freeText)
   
    itemCidPrefix = cidPrefix + C_ID_SEPARATOR + ordinal.to_s
    id = ModelUtility.buildCidVersion(C_CID_PREFIX, itemCidPrefix, version)
    item = Form::FormItem.create_placeholder(id, itemCidPrefix, 1, version, freeText)
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["bf"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:name \"Placehoilder\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:hasNode :" + item.id + " . \n" +
      " :" + id + " bf:isGroupOf :" + formId + " . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      object.name = "Placeholder"
      object.optional = false
      object.repeating = false
      object.note = ""
      object.ordinal = ordinal
      object.items = Hash.new
      object.items[item.id] = item
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Failed")
    end

    return object
  
  end

  def update
    return nil
  end

  def destroy
  end
  
end
