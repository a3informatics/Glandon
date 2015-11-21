require "uri"

class Form::FormItem
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :type, :name, :optional, :note, :ordinal, :bc, :bcPropertyId, :freeText
  validates_presence_of :id, :type, :name, :optional, :note, :ordinal, :bc, :bcPropertyId, :freeText
  
  # Constants
  C_NS_PREFIX = "mdrForms"
  C_CLASS_NAME = "FormItem"
  C_CID_PREFIX = "FI"
  C_BC = 1
  C_VARIABLE = 2
  C_PLACEHOLDER = 3
  C_UNKNOWN = 4
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
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY******")
    
    object = nil
    useNs = ns || @@baseNs
    
    query = UriManagement.buildNs(useNs, ["bf"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?hj ?i ?j ?k ?l ?m ?type WHERE\n" + 
      "{ \n" + 
      "  { :" + id + " rdf:type bf:Placeholder } UNION { :" + id + " rdf:type bf:vBased } UNION { :" + id + " rdf:type bf:bcBased } . \n" +
      "  :" + id + " rdf:type ?type . \n" +
      "  ?type rdfs:subClassOf bf:Item . \n" +
      "  :" + id + " bf:name ?b . \n" +
      "  :" + id + " bf:optional ?c . \n" +
      "  :" + id + " bf:note ?d . \n" +
      "  :" + id + " bf:ordinal ?e . \n" +
      "  OPTIONAL { \n" +
      "    :" + id + " bf:freeText ?f . \n" +
      "  } \n" +
      "  OPTIONAL { \n" +
      "    :" + id + " bf:datatype ?g . \n" +
      "    :" + id + " bf:format ?h . \n" +
      "    :" + id + " bf:qText ?i . \n" +
      "    :" + id + " bf:mapping ?j . \n" +
      "    OPTIONAL { \n" +
      "      :" + id + " bf:hasVariable ?k . \n" +
      "      :" + id + " bf:hasThesaurusConcept ?l . \n" +
      "    } \n" +
      "  } \n" +
      "  OPTIONAL { \n" +
      "    :" + id + " bf:hasProperty ?m . \n" +
      "    :" + id + " bf:hasBiomedicalConcept ?n . \n" +
      "  } \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      typeSet = node.xpath("binding[@name='type']/uri")
      nameSet = node.xpath("binding[@name='b']/literal")
      optSet = node.xpath("binding[@name='c']/literal")
      noteSet = node.xpath("binding[@name='d']/literal")
      ordSet = node.xpath("binding[@name='e']/literal")
      freeTextSet = node.xpath("binding[@name='f']/literal")
      dtSet = node.xpath("binding[@name='g']/literal")
      formatSet = node.xpath("binding[@name='h']/literal")
      qTextSet = node.xpath("binding[@name='i']/literal")
      mappingSet = node.xpath("binding[@name='j']/literal")
      vrSet = node.xpath("binding[@name='k']/uri")
      tcrSet = node.xpath("binding[@name='l']/uri")
      pSet = node.xpath("binding[@name='m']/uri")
      bcSet = node.xpath("binding[@name='n']/uri")
      if nameSet.length == 1 && optSet.length == 1 && noteSet.length == 1 && ordSet.length == 1 && typeSet.length == 1
        if object == nil 
          ConsoleLogger::log(C_CLASS_NAME,"find","New id=" + id)
          object = self.new 
          object.type = getType(typeSet[0].text)
          object.id = id
          object.name = nameSet[0].text
          object.optional = optSet[0].text
          object.note = noteSet[0].text
          object.ordinal = ordSet[0].text
        end
        if object.type == C_BC && pSet.length == 1 && bcSet.length == 1 
          bcId = ModelUtility.extractCid(bcSet[0].text)
          ConsoleLogger::log(C_CLASS_NAME,"findForGroup","BC id=" + bcId)
          object.bc[bcId] = CdiscBc.find(bcId, cdiscTerm)
          object.bcPropertyId = ModelUtility.extractCid(pSet[0].text)
        end
      end
    end
    return object  
    
  end

  def self.findForGroup(groupId, ns=nil)
    
    ConsoleLogger::log(C_CLASS_NAME,"findForForm","*****ENTRY******")
    
    results = Hash.new
    object = nil
    useNs = ns || @@baseNs
    
    query = UriManagement.buildNs(useNs, ["bf"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?hj ?i ?j ?k ?l ?m ?n ?type WHERE\n" + 
      "{ \n" + 
      "  { ?a rdf:type bf:Placeholder } UNION { ?a rdf:type bf:vBased } UNION { ?a rdf:type bf:bcBased } . \n" +
      "  ?a rdf:type ?type . \n" +
      "  ?type rdfs:subClassOf bf:Item . \n" +
      "  ?a bf:isNodeOf :" + groupId + " . \n" +
      "  ?a bf:name ?b . \n" +
      "  ?a bf:optional ?c . \n" +
      "  ?a bf:note ?d . \n" +
      "  ?a bf:ordinal ?e . \n" +
      "  OPTIONAL { \n" +
      "    ?a bf:freeText ?f . \n" +
      "  } \n" +
      "  OPTIONAL { \n" +
      "    ?a bf:datatype ?g . \n" +
      "    ?a bf:format ?h . \n" +
      "    ?a bf:qText ?i . \n" +
      "    ?a bf:mapping ?j . \n" +
      "    OPTIONAL { \n" +
      "      ?a bf:hasVariable ?k . \n" +
      "      ?a bf:hasThesaurusConcept ?l . \n" +
      "    } \n" +
      "  } \n" +
      "  OPTIONAL { \n" +
      "    ?a bf:hasProperty ?m . \n" +
      "    ?a bf:hasBiomedicalConcept ?n . \n" +
      "  } \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"findforGroup","Node=" + node)
      uriSet = node.xpath("binding[@name='a']/uri")
      typeSet = node.xpath("binding[@name='type']/uri")
      nameSet = node.xpath("binding[@name='b']/literal")
      optSet = node.xpath("binding[@name='c']/literal")
      noteSet = node.xpath("binding[@name='d']/literal")
      ordSet = node.xpath("binding[@name='e']/literal")
      freeTextSet = node.xpath("binding[@name='f']/literal")
      dtSet = node.xpath("binding[@name='g']/literal")
      formatSet = node.xpath("binding[@name='h']/literal")
      qTextSet = node.xpath("binding[@name='i']/literal")
      mappingSet = node.xpath("binding[@name='j']/literal")
      vrSet = node.xpath("binding[@name='k']/uri")
      tcrSet = node.xpath("binding[@name='l']/uri")
      pSet = node.xpath("binding[@name='m']/uri")
      bcSet = node.xpath("binding[@name='n']/uri")
      if uriSet.length == 1 && nameSet.length == 1 && optSet.length == 1 && noteSet.length == 1 && ordSet.length == 1 && typeSet.length == 1
        id = ModelUtility.extractCid(uriSet[0].text)
        ConsoleLogger::log(C_CLASS_NAME,"findForGroup","Id=" + id)
        if results.has_key?(id)
          object = results[id]
        else
          ConsoleLogger::log(C_CLASS_NAME,"findForGroup","Creating obect=====")
          object = self.new 
          object.id = id
          object.type = getType(typeSet[0].text)
          object.name = nameSet[0].text
          object.optional = optSet[0].text
          object.note = noteSet[0].text
          object.ordinal = ordSet[0].text
          results[id] = object
        end
        if object.type == C_BC && pSet.length == 1 
          bcId = ModelUtility.extractCid(bcSet[0].text)
          bcNamepace = ModelUtility.extractNs(bcSet[0].text)
          ConsoleLogger::log(C_CLASS_NAME,"findForGroup","BC id=" + bcId)
          object.bc = CdiscBc.find(bcId, bcNamepace)
          object.bcPropertyId = ModelUtility.extractCid(pSet[0].text)
        end
      end
    end
    return results
    
  end
  
  def self.all()
    return nil
  end

  def self.create(params)
    return nil
  end

  def self.create_placeholder(groupId, ns, cidPrefix, ordinal, version, freeText)

    id = ModelUtility.buildCidVersion(C_CID_PREFIX, cidPrefix + C_ID_SEPARATOR + ordinal.to_s, version)
    update = UriManagement.buildNs(ns, ["bf"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Placeholder . \n" +
      " :" + id + " bf:freeText \"" + freeText + "\"^^xsd:string . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:name \"Placeholder\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:isNodeOf :" + groupId + " . \n" +
            "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      object.type = C_PLACEHOLDER 
      object.name = "Placeholder"
      object.optional = false
      object.note = ""
      object.ordinal = ordinal
      object.bc = nil
      object.bcPropertyId = ""
      object.freeText = freeText
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Failed")
    end

    return object

  end

  def self.create_bc_normal(groupId, ns, cidPrefix, ordinal, version, bc, propertyId)

    id = ModelUtility.buildCid(C_CID_PREFIX, cidPrefix + C_ID_SEPARATOR + ordinal.to_s)
    ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Id=" + id.to_s)
    ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Ordinal=" + ordinal.to_s)
    update = UriManagement.buildNs(ns, ["bf"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:bcBased . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:name \"Item " + ordinal.to_s + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:hasProperty " + ModelUtility::buildUri(bc.namespace, propertyId) + " . \n" +
      " :" + id + " bf:hasBiomedicalConcept " + ModelUtility::buildUri(bc.namespace, bc.id) + " . \n" +
      " :" + id + " bf:isNodeOf :" + groupId + " . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      object.type = C_BC 
      object.name = "Item " + ordinal.to_s 
      object.optional = false
      object.note = ""
      object.ordinal = ordinal
      object.bc = bc
      object.bcPropertyId = propertyId
      object.freeText = ""
      ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Failed")
    end

    return object

  end

  def update
    return nil
  end

  def destroy
  end

private

  def self.getType (uri)
 
    ConsoleLogger::log(C_CLASS_NAME,"getType","uri=" + uri)
    type = ModelUtility.extractCid(uri)
    ConsoleLogger::log(C_CLASS_NAME,"getType","type=" + type)
    if type == "bcBased"
      type = C_BC
    elsif type == "vBased"
      type = C_VARIABLE
    elsif type == "Placeholder"
      type = C_PLACEHOLDER
    else
      type = C_UNKNOWN
    end
    return type
  
   end
    
 end
