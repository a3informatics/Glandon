require "uri"

class Form::Group < IsoConcept
  
  attr_accessor :items, :groups, :groupType, :bc
  validates_presence_of :items, :groups, :groupType, :bc
  
  # Constants
  C_SCHEMA_PREFIX = "bf"
  C_INSTANCE_PREFIX = "mdrForms"
  C_CLASS_NAME = "Form::Group"
  C_CID_PREFIX = "FG"
  C_BC_TYPE = "BCGroup"
  C_COMMON_TYPE = "CommonGroup"
  C_NORMAL_TYPE = "Group"
  
  def self.find(id, ns)
    ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY******")
    object = super(id, ns)
    object.groups = findSubGroups(object.links, ns)
    object.items = Form::Item.findForGroup(object.links, ns)
    if object.links.exists?(C_SCHEMA_PREFIX, "hasBiomedicalConcept")
      object.groupType = C_BC_TYPE
      uri = object.links.get(C_SCHEMA_PREFIX, "hasBiomedicalConcept")
      bcId = ModelUtility.extractCid(uri[0])
      bcNs = ModelUtility.extractNs(uri[0])
      object.bc = BiomedicalConcept.findByReference(bcId, bcNs)
    else
      object.groupType = C_NORMAL_TYPE
      object.bc = nil
    end      
    return object  
  end

  def self.findSubGroups(links, ns)
    ConsoleLogger::log(C_CLASS_NAME,"findForForm","*****ENTRY******")
    ConsoleLogger::log(C_CLASS_NAME,"findForForm","namespace=" + ns)
    results = Hash.new
    linkSet = links.get("bf", "hasSubGroup")
    linkSet.each do |link|
      object = find(ModelUtility.extractCid(link), ns)
      results[object.id] = object
    end
    linkSet = links.get("bf", "hasCommon")
    linkSet.each do |link|
      object = find(ModelUtility.extractCid(link), ns)
      object.groupType = C_COMMON_TYPE
      results[object.id] = object
    end
    return results
  end

  def self.findForForm(links, ns)
    ConsoleLogger::log(C_CLASS_NAME,"findForForm","*****ENTRY******")
    ConsoleLogger::log(C_CLASS_NAME,"findForForm","namespace=" + ns)
    results = Hash.new
    linkSet = links.get("bf", "hasGroup")
    linkSet.each do |link|
      object = find(ModelUtility.extractCid(link), ns)
      results[object.id] = object
    end
    return results
  end
  
  def self.createPlaceholder (formId, ns, freeText) 
    ordinal = 1
    id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    item = Form::Item.createPlaceholder(id, ns, freeText)
    update = UriManagement.buildNs(ns, ["bf"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"Placeholder\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:hasItem :" + item.id + " . \n" +
      " :" + id + " bf:isGroupOf :" + formId + " . \n" +
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

  def self.createBcNormal (formId, ns, ordinal, bc)
    id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    refId = ModelUtility.cidAddSuffix(id, "BCRef")
    
    # Add the properties. Only add if Enabled and Collected (i.e. ignore test codes etc, we only
    # want the visibale stuff on the form).
    insertSparql = ""
    items = Hash.new
    itemOrdinal = 1
    bc.properties.each do |propertyId, property|
      ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Add item for Group=" + propertyId)
      if property[:Enabled] && property[:Collect]
        item = Form::Item.createBcNormal(id, ns, itemOrdinal, bc, propertyId, property[:Values])
        itemOrdinal += 1
        insertSparql = insertSparql + " :" + id + " bf:hasItem :" + item.id + " . \n"
      end
    end
      
    # Build the query
    update = UriManagement.buildNs(ns, ["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"" + bc.label + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      insertSparql + 
      " :" + id + " bf:isGroupOf :" + formId + " . \n" +
      " :" + id + " bf:hasBiomedicalConcept :" + refId + " . \n" +
      " :" + refId + " rdf:type bo:BcReference . \n" +
      " :" + refId + " bo:hasBiomedicalConcept " + ModelUtility.buildUri(bc.namespace, bc.id) + " . \n" +
      " :" + refId + " bo:enabled \"true\"^^xsd:boolean . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Failed")
    end
    return object
  end

  def self.createBcEdit (formId, ns, ordinal, params)
    id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    refId = ModelUtility.cidAddSuffix(id, "BCRef")
    
    # Add the properties. Only add if Enabled and Collected (i.e. ignore test codes etc, we only
    # want the visibale stuff on the form).
    insertSparql = ""
    items = Hash.new
    itemOrdinal = 1
    children = params[:children]
    children.each do |key, child|
      ConsoleLogger::log(C_CLASS_NAME,"createBcEdit","Add item for Group=" + child.to_s)
      #if child[:enabled] 
        item = Form::Item.createBcEdit(id, ns, itemOrdinal, child)
        itemOrdinal += 1
        insertSparql = insertSparql + " :" + id + " bf:hasItem :" + item.id + " . \n"
      #end
    end
      
    # Build the query
    update = UriManagement.buildNs(ns, ["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"" + params[:label] + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      insertSparql + 
      " :" + id + " bf:isGroupOf :" + formId + " . \n" +
      " :" + id + " bf:hasBiomedicalConcept :" + refId + " . \n" +
      " :" + refId + " rdf:type bo:BcReference . \n" +
      " :" + refId + " bo:enabled \"true\"^^xsd:boolean . \n" +
      " :" + refId + " bo:hasBiomedicalConcept " + ModelUtility.buildUri(params[:namespace], params[:id]) + " . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Failed")
    end
    return object
  end

  def self.createCommon (formId, ns, ordinal, params)
    id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    refId = ModelUtility.cidAddSuffix(id, "BCRef")
    
    # Add the properties. Only add if Enabled and Collected (i.e. ignore test codes etc, we only
    # want the visibale stuff on the form).
    insertSparql = ""
    items = Hash.new
    itemOrdinal = 1
    children = params[:children]
    children.each do |key, child|
      ConsoleLogger::log(C_CLASS_NAME,"createCommon","Add item for Group=" + child.to_s)
      #if child[:enabled] 
        item = Form::Item.createBcEdit(id, ns, itemOrdinal, child)
        itemOrdinal += 1
        insertSparql = insertSparql + " :" + id + " bf:hasItem :" + item.id + " . \n"
      #end
    end
      
    # Build the query
    update = UriManagement.buildNs(ns, ["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"" + params[:label] + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      insertSparql + 
      " :" + id + " bf:isGroupOf :" + formId + " . \n" +
      # " :" + id + " bf:hasBiomedicalConcept :" + refId + " . \n" +
      # " :" + refId + " rdf:type bo:BcReference . \n" +
      # " :" + refId + " bo:enabled \"true\"^^xsd:boolean . \n" +
      # " :" + refId + " bo:hasBiomedicalConcept " + ModelUtility.buildUri(params[:namespace], params[:id]) + " . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Failed")
    end
    return object
  end

  def self.createBlank (parentId, ns, ordinal, params)
    ConsoleLogger::log(C_CLASS_NAME,"createBcBlank","*****Blank*****")
    id = ModelUtility.cidSwapPrefix(parentId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    
    # Build the query
    update = UriManagement.buildNs(ns, ["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"" + params[:label] + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:isGroupOf :" + parentId + " . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"createBcBlank","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createBcBlank","Failed")
    end
    return object
  end
  
  def d3(index)
    ii = 0
    result = FormNode.new(self.id, self.namespace, self.groupType, self.label, self.label, "", "", "", index, true)
    self.items.each do |key, item|
      result[:children][ii] = item.d3(ii)
      ii += 1
    end
    self.groups.each do |key, group|
      result[:children][ii] = group.d3(ii)
      ii += 1
    end
    result[:save] = result[:children]
    return result
  end

end
