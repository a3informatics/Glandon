require "uri"

class Form::Group < IsoConcept
  
  attr_accessor :items, :groups, :groupType, :bc, :ordinal, :note, :optional, :repeating, :completion
  #validates_presence_of :items, :groups, :groupType, :bc, :ordinal, :note, :optional, :repeating
  
  # Constants
  C_SCHEMA_PREFIX = "bf"
  C_INSTANCE_PREFIX = "mdrForms"
  C_CLASS_NAME = "Form::Group"
  C_CID_PREFIX = "FG"
  C_BC_TYPE = "BCGroup"
  C_COMMON_TYPE = "CommonGroup"
  C_NORMAL_TYPE = "Group"
  
  def initialize(triples=nil, id=nil)
    self.items = Array.new
    self.groups = Array.new
    self.bc = nil
    self.groupType = C_BC_TYPE
    self.ordinal = 1
    self.note = ""
    self.optional = false
    self.repeating = false
    self.completion = ""
    if triples.nil?
      super
    else
      super(triples, id)    
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    object.triples = ""
    return object
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    children_from_triples(object, triples, id)
    object.triples = ""
    return object
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
      " :" + id + " bf:completion \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:hasItem :" + item.id + " . \n" +
      " :" + id + " bf:isGroupOf :" + formId + " . \n" +
    "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Process the response
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

  #def d3(index)
  #  ii = 0
  #  result = FormNode.new(self.id, self.namespace, self.groupType, self.label, self.label, "", "", "", index, true)
  #  self.items.sort_by! {|u| u.ordinal}
  #  self.items.each do |item|
  #    result[:children][ii] = item.d3(ii)
  #    ii += 1
  #  end
  #  self.groups.sort_by! {|u| u.ordinal}
  #  self.groups.each do |group|
  #    result[:children][ii] = group.d3(ii)
  #    ii += 1
  #  end
  #  result[:save] = result[:children]
  #  return result
  #end

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
      :completion => self.completion,
      :note => self.note,
      :biomedical_concept_reference => {},
      :children => []
    }
    if self.bc != nil
      result[:biomedical_concept_reference] = 
        { 
          :id => self.bc.id, 
          :namespace => self.bc.namespace, 
          :enabled => true, 
          :optional => false, 
          :label => bc.label, 
          :identifier => bc.identifier, 
          :type => "", 
          :ordinal => 1  
        }
    end  
    self.items.sort_by! {|u| u.ordinal}
    self.items.each do |item|
      result[:children] << item.to_api_json
    end
    self.groups.sort_by! {|u| u.ordinal}
    self.groups.each do |group|
      result[:children] << group.to_api_json
    end
    #ConsoleLogger::log(C_CLASS_NAME,"to_api_json","Result=" + result.to_s)
    return result
  end

  def self.to_sparql(parent_id, sparql, schema_prefix, json)
    id = parent_id + Uri::C_UID_SECTION_SEPARATOR + 'G' + json[:ordinal].to_s  
    super(id, sparql, schema_prefix, "Group", json[:label])
    sparql.triple_primitive_type("", id, schema_prefix, "ordinal", json[:ordinal].to_s, "positiveInteger")
    sparql.triple_primitive_type("", id, schema_prefix, "optional", json[:optional].to_s, "boolean")
    sparql.triple_primitive_type("", id, schema_prefix, "repeating", json[:repeating].to_s, "boolean")
    sparql.triple_primitive_type("", id, schema_prefix, "note", json[:note].to_s, "string")
    sparql.triple_primitive_type("", id, schema_prefix, "completion", json[:completion].to_s, "string")
    sparql.triple("", id, schema_prefix, "isGroupOf", "", parent_id.to_s)
    if json.has_key?(:biomedical_concept_reference)
      bc_ref = json[:biomedical_concept_reference]
      #reference = bc_ref[:reference]
      ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'BCR'
      sparql.triple("", id, schema_prefix, "hasBiomedicalConcept", "", ref_id.to_s)
      sparql.triple("", ref_id, UriManagement::C_RDF, "type", "bo", "BcReference")
      sparql.triple_uri("", ref_id, "bo", "hasBiomedicalConcept", bc_ref[:namespace], bc_ref[:id])
      sparql.triple_primitive_type("", ref_id, "bo", "enabled", bc_ref[:enabled].to_s, "boolean")
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

private

  def self.children_from_triples(object, triples, id)
    # Subgroups first
    object.groups = Form::Group.find_for_parent(triples, object.get_links("bf", "hasSubGroup"))
    common_groups = Form::Group.find_for_parent(triples, object.get_links("bf", "hasCommon"))
    common_groups.each do |group|
      group.groupType = C_COMMON_TYPE
    end
    object.groups += common_groups
    # BC if we have one
    if object.link_exists?(C_SCHEMA_PREFIX, "hasBiomedicalConcept")
      object.groupType = C_BC_TYPE
      uri = object.get_links(C_SCHEMA_PREFIX, "hasBiomedicalConcept")
      bcId = ModelUtility.extractCid(uri[0])
      bcNs = ModelUtility.extractNs(uri[0])
      #object.bc = BiomedicalConcept.findByReference(bcId, bcNs)
      ref = OperationalReference.find_from_triples(triples, bcId)
      object.bc = ref.biomedical_concept
    else
      object.groupType = C_NORMAL_TYPE
    end
    # Items
    object.items = Form::Item.find_for_parent(triples, object.get_links("bf", "hasItem"), object.bc)  
  end

end
