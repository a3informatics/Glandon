require "uri"

class Form::Item < IsoConcept

  attr_accessor :items, :bcProperty, :bcValues, :itemType, :bcValueSet
  validates_presence_of :items, :bcProperty, :bcValues, :itemType, :bcValueSet
  
  # Constants
  C_SCHEMA_PREFIX = "bf"
  C_INSTANCE_PREFIX = "mdrForms"
  C_CLASS_NAME = "Form::Item"
  C_CID_PREFIX = "FI"
  C_BC = "BCItem"
  C_QUESTION = "Question"
  C_PLACEHOLDER = "Placeholder"  
  
  def self.find(id, ns)
    object = super(id, ns)
    object.bcValueSet = Array.new
    object.items = findSubItems(object.links, ns)
    if object.links.exists?(C_SCHEMA_PREFIX, "hasProperty")
      object.itemType = C_BC
      uri = object.links.get(C_SCHEMA_PREFIX, "hasProperty")
      bcId = ModelUtility.extractCid(uri[0])
      bcNs = ModelUtility.extractNs(uri[0])
      ref = OperationalReference.find(bcId, bcNs)
      object.bcProperty = ref.property
      #object.bcProperty = BiomedicalConcept::Property.findByReference(bcId, bcNs)
      object.bcValues = object.bcProperty.values
      linkSet = object.links.get("bf", "hasValue")
      linkSet.each do |link|
        id = ModelUtility.extractCid(link)
        ns = ModelUtility.extractNs(link)
        object.bcValueSet << OperationalReference.find(id, ns)
      end
    elsif object.properties.exists?(C_SCHEMA_PREFIX, "freeText")
      object.bcProperty = nil
      object.bcValues = nil
      object.itemType = C_PLACEHOLDER
    else
      object.bcProperty = nil
      object.bcValues = nil
      object.itemType = C_QUESTION
    end   
    return object  
  end

  def self.findSubItems(links, ns)
    ConsoleLogger::log(C_CLASS_NAME,"findSubItems","*****ENTRY******")
    ConsoleLogger::log(C_CLASS_NAME,"findSubItems","namespace=" + ns)
    results = Hash.new
    linkSet = links.get("bf", "hasCommonItem")
    linkSet.each do |link|
      object = find(ModelUtility.extractCid(link), ns)
      results[object.id] = object
    end
    return results
  end

  def self.findForGroup(links, ns=nil)    
    ConsoleLogger::log(C_CLASS_NAME,"findForGroup","*****ENTRY******")
    results = Hash.new
    linkSet = links.get("bf", "hasItem")
    linkSet.each do |link|
      object = find(ModelUtility.extractCid(link), ns)
      results[object.id] = object
    end
    return results
  end
  
  def self.createQuestion(groupId, ns, qText, datatype, format, mapping)

    ordinal = 1
    id = ModelUtility.cidSwapPrefix(groupId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    if params.has_key?(:children)
      params[:children].each do |key, value|
        clId = value[:id]
        clNs = value[:namespace]
        ConsoleLogger::log(C_CLASS_NAME,"createQuestion","id=" + clId + ", ns=" + clNamespace)
        insertSparql = " :" + id + " bo:hasThesaurusConcept " + ModelUtility.buildUri(clNs, clId) + " . \n" 
        valueOrdinal += 1
      end
    end

    update = UriManagement.buildNs(ns, ["bf"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Question . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"Placeholder\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:qText \"" + qText.to_s + "\"^^xsd:string . \n" +
      " :" + id + " bf:datatype \"" + datatype.to_s + "\"^^xsd:string . \n" +
      " :" + id + " bf:format \"" + format.to_s + "\"^^xsd:string . \n" +
      " :" + id + " bf:mapping \"" + mapping.to_s + "\"^^xsd:string . \n" +
      " :" + id + " bf:isItemOf :" + groupId + " . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"createQuestion","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createQuestion","Failed")
    end
    return object

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
      ConsoleLogger::log(C_CLASS_NAME,"createPlaceholder","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createPlaceholder","Failed")
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
      namespace = value[:namespace]
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Add value for Item=" + valueId + ", namespace=" + namespace)
      vRefId = ModelUtility.cidAddSuffix(id, "VRef" + valueOrdinal.to_s)
      insertSparql = insertSparql + " :" + id + " bf:hasValue :" + vRefId + " . \n" +
      " :" + vRefId + " rdf:type bo:BcReference . \n" +
      " :" + vRefId + " bo:hasValue " + ModelUtility.buildUri(namespace, valueId) + " . \n" +
      " :" + vRefId + " bo:enabled \"true\"^^xsd:boolean . \n"
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
        namespace = value[:namespace]
        enabled = value[:enabled]
        ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Add value for Item=" + valueId + ", namespace=" + namespace + ", enabled=" + enabled)
        vRefId = ModelUtility.cidAddSuffix(id, "VRef" + valueOrdinal.to_s)
        insertSparql = insertSparql + " :" + id + " bf:hasValue :" + vRefId + " . \n" +
        " :" + vRefId + " rdf:type bo:BcReference . \n" +
        " :" + vRefId + " bo:hasValue " + ModelUtility.buildUri(namespace, valueId) + " . \n" +
        " :" + vRefId + " bo:enabled \"" + enabled + "\"^^xsd:boolean . \n"
        valueOrdinal += 1
      end
    end

    commonOrdinal = 1
    if params.has_key?(:otherCommon)
      params[:otherCommon].each do |key, common|
        item = createCommon(id, ns, commonOrdinal, common)
        commonOrdinal += 1
        insertSparql = insertSparql + " :" + id + " bf:hasCommonItem :" + item.id + " . \n"
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
      ConsoleLogger::log(C_CLASS_NAME,"createBcEdit","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createBcEdit","Failed")
    end

    return object

  end

  def self.createCommon(itemId, ns, ordinal, params)

    id = ModelUtility.cidSwapPrefix(itemId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    pRefId = ModelUtility.cidAddSuffix(id, "PRef")
    #ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Id=" + id.to_s)
    #ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Ordinal=" + ordinal.to_s)
    
    valueOrdinal = 1
    insertSparql = "" 
    if params.has_key?(:children)
      params[:children].each do |key, value|
        valueId = value[:id]
        enabled = value[:enabled]
        ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Add value for Item=" + valueId)
        vRefId = ModelUtility.cidAddSuffix(id, "VRef" + valueOrdinal.to_s)
        insertSparql = insertSparql + " :" + id + " bf:hasValue :" + vRefId + " . \n" +
        " :" + vRefId + " rdf:type bo:BcReference . \n" +
        " :" + vRefId + " bo:hasValue " + ModelUtility.buildUri(params[:namespace], valueId) + " . \n" +
        " :" + vRefId + " bo:enabled \"" + enabled + "\"^^xsd:boolean . \n"
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
      # " :" + id + " bf:isItemOf :" + itemId + " . \n" +
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
      ConsoleLogger::log(C_CLASS_NAME,"createBcEdit","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createBcEdit","Failed")
    end

    return object

  end

  def d3(index)
    ord = "1"
    ordinal = self.properties.getOnly(C_SCHEMA_PREFIX, "ordinal")
    if ordinal.has_key?(:value) 
      ord = ordinal[:value]
    end
    if self.itemType == C_PLACEHOLDER
      name = "Placeholder " + ord
      result = FormNode.new(self.id, self.namespace,  "Placeholder", name, "", "", "", "", index, true)
      result[:freeText] = self.properties.getOnly(C_SCHEMA_PREFIX, "freeText")[:value]
    elsif self.itemType == C_QUESTION
      name = Question + ord
      result = FormNode.new(self.id, self.namespace,  "Question", name, "", "", "", "", index, true)
      result[:datatype] = self.properties.getOnly(C_SCHEMA_PREFIX, "datatype")[:value]
      result[:format] = self.properties.getOnly(C_SCHEMA_PREFIX, "format")[:value]
      result[:qText] = self.properties.getOnly(C_SCHEMA_PREFIX, "qText")[:value]
      result[:mapping] = self.properties.getOnly(C_SCHEMA_PREFIX, "mapping")[:value]
    else
      name = bcProperty.alias
      result = FormNode.new(self.id, self.namespace,  "BCItem", name, "", "", "", "", index, true)
      localIndex = 0
      #pvSet = self.bcValues
      #pvSet.each do |pvKey, pv|
      #  pv.clis.each do |cliKey, cli|
      #    result[:children] << FormNode.new(cli.id, cli.namespace, "CL", cli.notation, "", "", "", "", localIndex, true)
      #    localIndex += 1;
      #  end
      clis = self.bcValueSet
      clis.each do |cliRef|
        if cliRef.enabled
          cli = cliRef.value
          result[:children] << FormNode.new(cli.id, cli.namespace, "CL", cli.notation, "", "", "", "", localIndex, true)
          localIndex += 1;
        end
      end
    end  
    result[:save] = result[:children]
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
