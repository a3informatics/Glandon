require "uri"

class Form::FormItem < IsoConceptInstance
  
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
  
  def self.find(id, ns)
    object = super(id, ns)
    return object  
  end

  def self.findForGroup(links, ns=nil)
    
    ConsoleLogger::log(C_CLASS_NAME,"findForGroup","*****ENTRY******")
    
    results = Hash.new
    links.each do |link|
      ConsoleLogger::log(C_CLASS_NAME,"findForGroup","Id=" + link.objectUri)
      if link.range == UriManagement.getNs("bf") + "#" + "Item"
        object = find(ModelUtility.extractCid(link.objectUri), ns)
        results[object.id] = object
      end
    end
    return results
  
  end
  
  def self.all()
    return nil
  end

  def self.create()
    return nil
  end

  def self.createPlaceholder(groupId, ns, freeText)

    ordinal = 1
    id = ModelUtility.cidSwapPrefix(groupId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    update = UriManagement.buildNs(ns, ["bf"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Placeholder . \n" +
      " :" + id + " bf:freeText \"" + freeText + "\"^^xsd:string . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"Placeholder\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:isItemOf :" + groupId + " . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Failed")
    end
    return object

  end

  def self.createBcNormal(groupId, ns, ordinal, bc, propertyId, propertyValues)

    id = ModelUtility.cidSwapPrefix(groupId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    pRefId = ModelUtility.cidAddSuffix(id, "PRef")
    name = bc.properties[propertyId][:Name]
    #ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Id=" + id.to_s)
    #ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Ordinal=" + ordinal.to_s)
    
    valueOrdinal = 1
    insertSparql = "" 
    propertyValues.each do |value|
      valueId = value[:id]
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Add value for Item=" + valueId)
      vRefId = ModelUtility.cidAddSuffix(id, "VRef" + valueOrdinal.to_s)
      insertSparql = insertSparql + " :" + id + " bf:hasValue :" + vRefId + " . \n" +
      " :" + vRefId + " rdf:type bo:BcReference . \n" +
      " :" + vRefId + " bo:hasValue " + ModelUtility.buildUri(bc.namespace, valueId) + " . \n"
      valueOrdinal += 1
    end

    update = UriManagement.buildNs(ns, ["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:BcProperty . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"" + name + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:isItemOf :" + groupId + " . \n" +
      " :" + id + " bf:hasProperty :" + pRefId + " . \n" +
      " :" + pRefId + " rdf:type bo:BcReference . \n" +
      " :" + pRefId + " bo:hasProperty " + ModelUtility.buildUri(bc.namespace, propertyId) + " . \n" +
      " :" + pRefId + " bo:enabled \"true\"^^xsd:boolean . \n" +
      insertSparql +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Failed")
    end

    return object

  end

  def self.createBcEdit(groupId, ns, ordinal, params)

    id = ModelUtility.cidSwapPrefix(groupId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    pRefId = ModelUtility.cidAddSuffix(id, "PRef")
    #ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Id=" + id.to_s)
    #ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Ordinal=" + ordinal.to_s)
    
    valueOrdinal = 1
    insertSparql = "" 
    if params.has_key?(:children)
      params[:children].each do |key, value|
        valueId = value[:id]
        ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Add value for Item=" + valueId)
        vRefId = ModelUtility.cidAddSuffix(id, "VRef" + valueOrdinal.to_s)
        insertSparql = insertSparql + " :" + id + " bf:hasValue :" + vRefId + " . \n" +
        " :" + vRefId + " rdf:type bo:BcReference . \n" +
        " :" + vRefId + " bo:hasValue " + ModelUtility.buildUri(params[:namespace], valueId) + " . \n"
        valueOrdinal += 1
      end
    end

    update = UriManagement.buildNs(ns, ["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:BcProperty . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"" + params[:label] + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:isItemOf :" + groupId + " . \n" +
      " :" + id + " bf:hasProperty :" + pRefId + " . \n" +
      " :" + pRefId + " rdf:type bo:BcReference . \n" +
      " :" + pRefId + " bo:hasProperty " + ModelUtility.buildUri(params[:namespace], params[:id]) + " . \n" +
      " :" + pRefId + " bo:enabled \"" + params[:enabled] + "\"^^xsd:boolean . \n" +
      insertSparql +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
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

  def to_D3

    result = Hash.new
    #if bc.properties[bcPropertyId][:Enabled]
      result[:name] = self.label
      result[:identifier] = self.id
      result[:nodeType] = "item"
      result[:item] = self.to_json
    #end
    return result

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
