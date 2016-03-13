require "uri"

class Form::Group < IsoConcept
  
  attr_accessor :items, :groups, :groupType, :bc, :ordinal, :note, :optional, :repeating
  validates_presence_of :items, :groups, :groupType, :bc, :ordinal, :note, :optional, :repeating
  
  # Constants
  C_SCHEMA_PREFIX = "bf"
  C_INSTANCE_PREFIX = "mdrForms"
  C_CLASS_NAME = "Form::Group"
  C_CID_PREFIX = "FG"
  C_BC_TYPE = "BCGroup"
  C_COMMON_TYPE = "CommonGroup"
  C_NORMAL_TYPE = "Group"
  
  def self.find(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY******")
    object = super(id, ns)
    object.ordinal = object.properties.getLiteralValue(C_SCHEMA_PREFIX, "ordinal").to_i
    object.note = object.properties.getLiteralValue(C_SCHEMA_PREFIX, "note")
    object.optional = ModelUtility.to_boolean(object.properties.getLiteralValue(C_SCHEMA_PREFIX, "optional"))
    object.repeating = ModelUtility.to_boolean(object.properties.getLiteralValue(C_SCHEMA_PREFIX, "optional"))
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
    #ConsoleLogger::log(C_CLASS_NAME,"findForForm","*****ENTRY******")
    #ConsoleLogger::log(C_CLASS_NAME,"findForForm","namespace=" + ns)
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
    #ConsoleLogger::log(C_CLASS_NAME,"findForForm","*****ENTRY******")
    #ConsoleLogger::log(C_CLASS_NAME,"findForForm","namespace=" + ns)
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

  #def self.createBcEdit (formId, ns, ordinal, params)
  #  id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
  #  id = ModelUtility.cidAddSuffix(id, ordinal)
  #  refId = ModelUtility.cidAddSuffix(id, "BCRef")
  #  
  #  # Add the properties. Only add if Enabled and Collected (i.e. ignore test codes etc, we only
  #  # want the visibale stuff on the form).
  #  insertSparql = ""
  #  items = Hash.new
  #  itemOrdinal = 1
  #  children = params[:children]
  #  children.each do |key, child|
  #    ConsoleLogger::log(C_CLASS_NAME,"createBcEdit","Add item for Group=" + child.to_s)
  #    #if child[:enabled] 
  #      item = Form::Item.createBcEdit(id, ns, itemOrdinal, child)
  #      itemOrdinal += 1
  #      insertSparql = insertSparql + " :" + id + " bf:hasItem :" + item.id + " . \n"
  #    #end
  #  end
  #    
  #  # Build the query
  #  update = UriManagement.buildNs(ns, ["bf", "bo"]) +
  #    "INSERT DATA \n" +
  #    "{ \n" +
  #    " :" + id + " rdf:type bf:Group . \n" +
  #    " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
  #    " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
  #    " :" + id + " rdfs:label \"" + params[:label] + "\"^^xsd:string . \n" +
  #    " :" + id + " bf:note \"\"^^xsd:string . \n" +
  #    " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
  #    insertSparql + 
  #    " :" + id + " bf:isGroupOf :" + formId + " . \n" +
  #    " :" + id + " bf:hasBiomedicalConcept :" + refId + " . \n" +
  #    " :" + refId + " rdf:type bo:BcReference . \n" +
  #    " :" + refId + " bo:enabled \"true\"^^xsd:boolean . \n" +
  #    " :" + refId + " bo:hasBiomedicalConcept " + ModelUtility.buildUri(params[:namespace], params[:id]) + " . \n" +
  #  "}"
  #
  #  # Send the request, wait the resonse
  #  response = CRUD.update(update)
  #
  #  # Response
  #  if response.success?
  #    object = self.new
  #    object.id = id
  #    ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Success, id=" + id)
  #  else
  #    object = nil
  #    ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Failed")
  #  end
  #  return object
  #end

  #def self.createCommon (formId, ns, ordinal, params)
  #  id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
  #  id = ModelUtility.cidAddSuffix(id, ordinal)
  #  refId = ModelUtility.cidAddSuffix(id, "BCRef")
  #  
  #  # Add the properties. Only add if Enabled and Collected (i.e. ignore test codes etc, we only
  #  # want the visibale stuff on the form).
  #  insertSparql = ""
  #  items = Hash.new
  #  itemOrdinal = 1
  #  children = params[:children]
  #  children.each do |key, child|
  #    ConsoleLogger::log(C_CLASS_NAME,"createCommon","Add item for Group=" + child.to_s)
  #    #if child[:enabled] 
  #      item = Form::Item.createBcEdit(id, ns, itemOrdinal, child)
  #      itemOrdinal += 1
  #      insertSparql = insertSparql + " :" + id + " bf:hasItem :" + item.id + " . \n"
  #    #end
  #  end
  #    
  #  # Build the query
  #  update = UriManagement.buildNs(ns, ["bf", "bo"]) +
  #    "INSERT DATA \n" +
  #    "{ \n" +
  #    " :" + id + " rdf:type bf:Group . \n" +
  #    " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
  #    " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
  #    " :" + id + " rdfs:label \"" + params[:label] + "\"^^xsd:string . \n" +
  #    " :" + id + " bf:note \"\"^^xsd:string . \n" +
  #    " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
  #    insertSparql + 
  #    " :" + id + " bf:isGroupOf :" + formId + " . \n" +
  #    # " :" + id + " bf:hasBiomedicalConcept :" + refId + " . \n" +
  #    # " :" + refId + " rdf:type bo:BcReference . \n" +
  #    # " :" + refId + " bo:enabled \"true\"^^xsd:boolean . \n" +
  #    # " :" + refId + " bo:hasBiomedicalConcept " + ModelUtility.buildUri(params[:namespace], params[:id]) + " . \n" +
  #  "}"
  #
  #  # Send the request, wait the resonse
  #  response = CRUD.update(update)
  #
  #  # Response
  #  if response.success?
  #    object = self.new
  #    object.id = id
  #    ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Success, id=" + id)
  #  else
  #    object = nil
  #    ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Failed")
  #  end
  #  return object
  #end

  #def self.createBlank (parentId, ns, ordinal, params)
  #  ConsoleLogger::log(C_CLASS_NAME,"createBcBlank","*****Blank*****")
  #  id = ModelUtility.cidSwapPrefix(parentId, C_CID_PREFIX)
  #  id = ModelUtility.cidAddSuffix(id, ordinal)
  #  
  #  # Build the query
  #  update = UriManagement.buildNs(ns, ["bf", "bo"]) +
  #    "INSERT DATA \n" +
  #    "{ \n" +
  #    " :" + id + " rdf:type bf:Group . \n" +
  #    " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
  #    " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
  #    " :" + id + " rdfs:label \"" + params[:label] + "\"^^xsd:string . \n" +
  #    " :" + id + " bf:note \"\"^^xsd:string . \n" +
  #    " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
  #    " :" + id + " bf:isGroupOf :" + parentId + " . \n" +
  #  "}"
  #
  #  # Send the request, wait the resonse
  #  response = CRUD.update(update)
  #
  #  # Response
  #  if response.success?
  #    object = self.new
  #    object.id = id
  #    ConsoleLogger::log(C_CLASS_NAME,"createBcBlank","Success, id=" + id)
  #  else
  #    object = nil
  #    ConsoleLogger::log(C_CLASS_NAME,"createBcBlank","Failed")
  #  end
  #  return object
  #end
  
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

  def to_api_json()
    #ConsoleLogger::log(C_CLASS_NAME,"to_api_json","*****Entry*****")
    result = 
    { 
      :id => self.id, 
      :namespace => self.namespace, 
      :type => self.groupType,
      :label => self.label, 
      :ordinal => self.ordinal,
      :optional => self.optional,
      :repeating => self.repeating,
      :note => self.note,
      :biomedical_concept_reference => {},
      :children => []
    }
    if self.bc != nil
      result[:biomedical_concept_reference] = {:id => self.bc.id, :namespace => self.bc.namespace, :enabled => true}
    end  
    self.items.each do |key, item|
      result[:children][item.ordinal - 1] = item.to_api_json
    end
    self.groups.each do |key, group|
      result[:children][group.ordinal - 1] = group.to_api_json
    end
    #ConsoleLogger::log(C_CLASS_NAME,"to_api_json","Result=" + result.to_s)
    return result
  end

  def self.to_sparql(parent_id, sparql, schema_prefix, json)
    #ConsoleLogger::log(C_CLASS_NAME,"to_sparql","*****Entry******")
    #ConsoleLogger::log(C_CLASS_NAME,"to_api_json","json=" + json.to_s)
    
    #rdf_type = {C_PLACEHOLDER => "Placeholder", C_QUESTION => "Question", C_BC => "BcProperty"} 
    
    id = parent_id + Uri::C_UID_SECTION_SEPARATOR + 'G' + json[:ordinal].to_s  
    super(id, sparql, schema_prefix, "Group", json[:label])
    sparql.triple_primitive_type("", id, schema_prefix, "ordinal", json[:ordinal].to_s, "positiveInteger")
    sparql.triple_primitive_type("", id, schema_prefix, "optional", json[:optional].to_s, "boolean")
    sparql.triple_primitive_type("", id, schema_prefix, "repeating", json[:repeating].to_s, "boolean")
    sparql.triple_primitive_type("", id, schema_prefix, "note", json[:note].to_s, "string")
    sparql.triple("", id, schema_prefix, "isGroupOf", "", parent_id.to_s)
    if json.has_key?(:biomedical_concept_reference)
      bc_ref = json[:biomedical_concept_reference]
      ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'BCR'
      sparql.triple("", id, schema_prefix, "hasBiomedicalConcept", "", ref_id.to_s)
      sparql.triple("", ref_id, UriManagement::C_RDF, "type", schema_prefix, "BcReference")
      sparql.triple_uri("", ref_id, "bo", "hasBiomedicalConcept", bc_ref[:namespace], bc_ref[:id])
      sparql.triple_primitive_type("", ref_id, schema_prefix, "enabled", bc_ref[:enabled].to_s, "boolean")
    end
    if json.has_key?(:children)
      json[:children].each do |key, child|
        if child[:type] == C_NORMAL_TYPE || child[:type] == C_BC_TYPE 
          sparql.triple("", id, schema_prefix, "hasSubGroup", "", id + Uri::C_UID_SECTION_SEPARATOR + 'G' + child[:ordinal].to_s)
        elsif child[:type] == C_COMMON_TYPE
          sparql.triple("", id, schema_prefix, "hasCommon", "", id + Uri::C_UID_SECTION_SEPARATOR + 'G' + child[:ordinal].to_s)
        elsif child[:type] == Form::Item::C_BC || child[:type] == Form::Item::C_QUESTION || child[:type] == Form::Item::C_PLACEHOLDER
          sparql.triple("", id, schema_prefix, "hasItem", "", id + Uri::C_UID_SECTION_SEPARATOR + 'I' + child[:ordinal].to_s)
        end    
      end
    end
    if json.has_key?(:children)
      json[:children].each do |key, child|
        if child[:type] == C_NORMAL_TYPE || child[:type] == C_BC_TYPE || child[:type] == C_COMMON_TYPE
          Form::Group.to_sparql(id, sparql, schema_prefix, child)
        elsif child[:type] == Form::Item::C_BC || child[:type] == Form::Item::C_QUESTION || child[:type] == Form::Item::C_PLACEHOLDER
          Form::Item.to_sparql(id, sparql, schema_prefix, child)
        end    
      end
    end
  end

end
