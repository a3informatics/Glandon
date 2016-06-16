require "uri"

class Form::Item < IsoConceptNew

  attr_accessor :items, :bcProperty, :bcValues, :itemType, :bcValueSet, :ordinal, :note, :completion, :optional, :freeText, :datatype, :format, :mapping, :qText, :q_values
  #validates_presence_of :items, :bcProperty, :bcValues, :itemType, :bcValueSet, :ordinal, :note, :optional, :freeText, :datatype, :format, :mapping, :qText, :q_values
  
  # Constants
  C_SCHEMA_PREFIX = "bf"
  C_INSTANCE_PREFIX = "mdrForms"
  C_CLASS_NAME = "Form::Item"
  C_CID_PREFIX = "FI"
  C_BC = "BCItem"
  C_QUESTION = "Question"
  C_PLACEHOLDER = "Placeholder"
  C_UNKNOWN = C_PLACEHOLDER  
  
  def initialize(triples=nil, id=nil)
    self.items = Array.new
    self.bcProperty = nil
    self.bcValues = Array.new
    self.bcValueSet = Array.new
    self.q_values = Array.new
    if triples.nil?
      super
      self.itemType = C_BC
      self.ordinal = 1
      self.note = ""
      self.optional = false
      self.freeText = ""
      self.datatype = ""
      self.format = ""
      self.mapping = ""
      self.qText = ""
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

  def self.find_from_triples(triples, id, bc)
    object = new(triples, id)
    children_from_triples(object, triples, id, bc)
    #ConsoleLogger::log(C_CLASS_NAME,"find","find=" + object.to_json.to_s)
    object.triples = ""
    return object
  end
  
  # Overwrites the base definition, extra param for the BC.
  def self.find_for_parent(triples, links, bc)
    results = Array.new
    links.each do |link|
      object = find_from_triples(triples, ModelUtility.extractCid(link), bc)
      results << object
    end
    sorted = results.sort_by{|item| item.id}
    return sorted
  end

  def self.createPlaceholder(groupId, ns, freeText)

    ordinal = 1
    id = ModelUtility.cidSwapPrefix(groupId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    update = UriManagement.buildNs(ns, ["bf"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Placeholder . \n" +
      " :" + id + " bf:freeText \"" + SparqlUtility::replace_special_chars(freeText) + "\"^^xsd:string . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"Placeholder\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:completion \"\"^^xsd:string . \n" +
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

  def to_api_json()
    #ConsoleLogger::log(C_CLASS_NAME,"to_api_json","*****Entry*****")
    result = 
    { 
      :id => self.id, 
      :namespace => self.namespace, 
      :type => self.itemType,
      :label => self.label, 
      :ordinal => self.ordinal,
      :optional => self.optional,
      :note => self.note,
      :completion => self.completion,
      :free_text => "",
      :datatype => "",
      :format => "",
      :qText => "",
      :pText => "",
      :mapping => "",
      :property_reference => {},
      :children => [],
      :otherCommon => []
    }
    if self.itemType == C_PLACEHOLDER
      result[:free_text] = self.freeText
    elsif self.itemType == C_QUESTION
      result[:datatype] = self.datatype
      result[:format] = self.format
      result[:qText] = self.qText
      result[:mapping] = self.mapping
      tc_refs = self.q_values
      ordinal = 1  
      tc_refs.each do |tc_ref|
        cli = tc_ref.thesaurus_concept
        if !cli.nil? 
          # Temporary, remove!!!
          if tc_ref.ordinal == 0
            tc_ref.ordinal = ordinal
          end
          if tc_ref.local_label.empty? 
            tc_ref.local_label = cli.preferredTerm
          end
          result[:children] << 
            { 
              :reference => {:id => cli.id, :namespace => cli.namespace, :enabled => tc_ref.enabled, 
                :optional => tc_ref.optional, :local_label => tc_ref.local_label, :ordinal => tc_ref.ordinal }, 
              :label => cli.label, :notation => cli.notation, :preferred_term => cli.preferredTerm, :identifier => cli.identifier, :type => "CL" 
            }
          ordinal += 1  
        end
      end
      result[:children] = result[:children].sort_by {|item| item[:reference][:ordinal]}
    else
      if self.bcProperty != nil
        result[:property_reference] = 
          { 
            :reference => {:id => self.bcProperty.id, :namespace => self.bcProperty.namespace, :enabled => true, :optional => false},
            :label => bcProperty.label, :identifier => "", :type => "", :ordinal => 1 
          }
      end
      result[:datatype] = self.bcProperty.datatype
      result[:format] = self.bcProperty.format
      result[:qText] = self.bcProperty.qText
      result[:pText] = self.bcProperty.pText
      result[:bridgPath] = self.bcProperty.bridgPath
      clis = self.bcValueSet
      ordinal = 1  
      clis.each do |cli_ref|
        cli = cli_ref.bc_value
        result[:children] << 
          { 
            :reference => {:id => cli.id, :namespace => cli.namespace, :enabled => cli_ref.enabled, 
              :optional => cli_ref.optional, :local_label => cli.label, :ordinal => ordinal }, 
            :label => cli.label, :notation => cli.notation, :preferred_term => cli.preferredTerm, :identifier => cli.identifier, :type => "CL"
          }
        ordinal += 1  
      end
      items.each do |item|
        result[:otherCommon] << item.to_api_json
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"to_api_json","Result=" + result.to_s)
    return result
  end

  def self.to_sparql(parent_id, sparql, schema_prefix, json)
    # Set the type.
    rdf_type = {C_PLACEHOLDER => "Placeholder", C_QUESTION => "Question", C_BC => "BcProperty"} 
    # Build the item.
    id = parent_id + Uri::C_UID_SECTION_SEPARATOR + 'I' + json[:ordinal].to_s  
    super(id, sparql, schema_prefix, rdf_type[json[:type]], json[:label])
    sparql.triple_primitive_type("", id, schema_prefix, "ordinal", json[:ordinal].to_s, "positiveInteger")
    sparql.triple_primitive_type("", id, schema_prefix, "optional", json[:optional].to_s, "boolean")
    sparql.triple_primitive_type("", id, schema_prefix, "note", json[:note].to_s, "string")
    sparql.triple_primitive_type("", id, schema_prefix, "completion", json[:completion].to_s, "string")
    sparql.triple("", id, schema_prefix, "isItemOf", "", parent_id.to_s)
    if json[:type] == C_PLACEHOLDER
      sparql.triple_primitive_type("", id, schema_prefix, "freeText", json[:free_text].to_s, "string")
    elsif json[:type] == C_QUESTION
      sparql.triple_primitive_type("", id, schema_prefix, "datatype", json[:datatype].to_s, "string")
      sparql.triple_primitive_type("", id, schema_prefix, "format", json[:format].to_s, "string")
      sparql.triple_primitive_type("", id, schema_prefix, "qText", json[:qText].to_s, "string")
      sparql.triple_primitive_type("", id, schema_prefix, "mapping", json[:mapping].to_s, "string")
      if json.has_key?(:children)
        #value_ordinal = 1
        json[:children].each do |key, child|
          value = child[:reference]
          ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'TCR' + value[:ordinal].to_s
          sparql.triple("", id, schema_prefix, "hasThesaurusConcept", "", ref_id.to_s)
          sparql.triple("", ref_id, UriManagement::C_RDF, "type", "bo", "TcReference")
          sparql.triple_uri("", ref_id, "bo", "hasThesaurusConcept", value[:namespace], value[:id])
          sparql.triple_primitive_type("", ref_id, "bo", "enabled", value[:enabled].to_s, "boolean")
          sparql.triple_primitive_type("", ref_id, "bo", "optional", value[:optional].to_s, "boolean")
          sparql.triple_primitive_type("", ref_id, "bo", "ordinal", value[:ordinal].to_s, "positiveInteger")
          sparql.triple_primitive_type("", ref_id, "bo", "local_label", value[:local_label].to_s, "string")
          #value_ordinal += 1
        end
      end
    else
      # Handle the terminology children.
      if json.has_key?(:children)
        value_ordinal = 1
        json[:children].each do |key, child|
          value = child[:reference]
          ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'VR' + value_ordinal.to_s
          sparql.triple("", id, schema_prefix, "hasValue", "", ref_id.to_s)
          sparql.triple("", ref_id, UriManagement::C_RDF, "type", "bo", "BcReference")
          sparql.triple_uri("", ref_id, "bo", "hasValue", value[:namespace], value[:id])
          sparql.triple_primitive_type("", ref_id, "bo", "enabled", value[:enabled].to_s, "boolean")
          sparql.triple_primitive_type("", ref_id, "bo", "optional", value[:optional].to_s, "boolean")
          value_ordinal += 1
        end
      end
      # Handle the other common items.
      if json.has_key?(:otherCommon)
        json[:otherCommon].each do |key, item|
          item_id = Form::Item.to_sparql(id, sparql, schema_prefix, item)
          sparql.triple("", id, schema_prefix, "hasCommonItem", "", item_id.to_s)
        end
      end
      # Handle the BC Property references.
      property = json[:property_reference]
      reference = property[:reference]
      ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'PR'
      sparql.triple("", id, schema_prefix, "hasProperty", "", ref_id.to_s)
      sparql.triple("", ref_id, UriManagement::C_RDF, "type", "bo", "BcReference")
      sparql.triple_uri("", ref_id, "bo", "hasProperty", reference[:namespace], reference[:id])
      sparql.triple_primitive_type("", ref_id, "bo", "enabled", property[:enabled].to_s, "boolean")
      sparql.triple_primitive_type("", ref_id, "bo", "optional", property[:optional].to_s, "boolean")
    end
    return id
  end

private

  def self.children_from_triples(object, triples, id, bc=nil)
    #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","*****Entry*****")
    object.items = Form::Item.find_for_parent(triples, object.get_links("bf", "hasCommonItem"), bc)
    object.itemType = get_type(object)
    if object.link_exists?(C_SCHEMA_PREFIX, "hasProperty")
      object.itemType = C_BC
      uri = object.get_links(C_SCHEMA_PREFIX, "hasProperty")
      bcId = ModelUtility.extractCid(uri[0])
      ref = OperationalReference.find_from_triples(triples, bcId, bc)
      object.bcProperty = ref.bc_property
      object.bcValues = object.bcProperty.values
      links = object.get_links("bf", "hasValue")
      links.each do |link|
        id = ModelUtility.extractCid(link)
        object.bcValueSet << OperationalReference.find_from_triples(triples, id)
      end
    end
    if object.link_exists?(C_SCHEMA_PREFIX, "hasThesaurusConcept")
      #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","hasThesaurusConcept, object=" + object.to_json.to_s)
      links = object.get_links(C_SCHEMA_PREFIX, "hasThesaurusConcept")
      links.each do |link|
        id = ModelUtility.extractCid(link)
        object.q_values << OperationalReference.find_from_triples(triples, id)
      end
    end      
  end

  def self.get_type(object)
    type = ModelUtility.extractCid(object.rdf_type)
    if type == "bcBased"
      type = C_BC
    elsif type == "Question"
      type = C_QUESTION
    elsif type == "Placeholder"
      type = C_PLACEHOLDER
    else
      type = C_UNKNOWN
    end
    return type  
   end
    
 end
