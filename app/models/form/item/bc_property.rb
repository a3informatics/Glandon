class Form::Item::BcProperty < Form::Item

  attr_accessor :item_refs, :property_ref, :value_refs
  
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Item::BcProperty"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "BcProperty"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  def thesaurus_concepts
    results = Array.new
    refs.each do |ref|
      results << ThesaurusConcept.find(ref.subject_ref.id, ref.subject_ref.namespace, false)
    end
    return results
  end

  def bc_property
    result = BiomedicalConceptCore::Property.find(self.property_ref.subject_ref.id, self.property_ref.subject_ref.namespace)
    return result
  end

  def initialize(triples=nil, id=nil)
    self.item_refs = Array.new
    self.property_ref = nil
    self.value_refs = Array.new
    if triples.nil?
      super
      # Set the type. Overwrite default.
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
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
    #ConsoleLogger::log(C_CLASS_NAME,"find","find=" + object.to_json.to_s)
    object.triples = ""
    return object
  end
  
  def to_json
    json = super
    json[:property_ref] = self.property_ref.to_json
    json[:children] = Array.new
    json[:otherCommon] = Array.new
    value_refs.each do |ref|
      json[:children] << ref.to_json
    end
    item_refs.each do |ref|
      json[:otherCommon] << ref.to_json
    end
    return json
  end
  
  def self.from_json(json)
    object = super(json)
    object.property_ref = OperationalReferenceV2.from_json(json[:property_ref])
    if !json[:children].blank?
      json[:children].each do |child|
        object.value_refs << OperationalReferenceV2.from_json(child)
      end
    end
    if !json[:otherCommon].blank?
      json[:otherCommon].each do |child|
        object.item_refs << Form::Item::BcProperty.from_json(child)
      end
    end
    return object
  end

  def to_sparql(parent_id, sparql)
    super(parent_id, sparql)
    ref_id = property_ref.to_sparql(id, "hasProperty", 'PR', property_ref.ordinal, sparql)
    sparql.triple("", self.id, C_SCHEMA_PREFIX, "hasProperty", "", "#{ref_id}")
    self.item_refs.each do |item_ref|
      ref_id = item_ref.to_sparql(id, sparql)
      sparql.triple("", self.id, C_SCHEMA_PREFIX, "hasCommonItem", "", "#{ref_id}")
    end
    self.value_refs.each do |value_ref|
      ref_id = value_ref.to_sparql(id, "hasValue", 'VR', value_ref.ordinal, sparql)
      sparql.triple("", self.id, C_SCHEMA_PREFIX, "hasValue", "", "#{ref_id}")
    end
    return self.id
  end

  def to_xml(metadata_version, form_def, item_group_def)
    super(metadata_version, form_def, item_group_def)
    bc_property = BiomedicalConceptCore::Property.find(property_ref.subject_ref.id, property_ref.subject_ref.namespace)
    xml_datatype = to_xml_datatype(bc_property.datatype)
    xml_length = to_xml_length(bc_property.datatype, bc_property.format)
    xml_digits = to_xml_significant_digits(bc_property.datatype, bc_property.format)
    item_def = metadata_version.add_item_def("#{self.id}", "#{self.label}", "#{xml_datatype}", "#{xml_length}", "#{xml_digits}", "", "", "", "")
    question = item_def.add_question()
    question.add_translated_text("#{bc_property.qText}")
    if bc_property.values.length > 0
      code_list_ref = item_def.add_code_list_ref("#{self.id}-CL")
      code_list = metadata_version.add_code_list("#{self.id}-CL", "Code list for #{self.label}", "text", "")
      bc_property.values.each do |value|
        cli = value.cli
        code_list_item = code_list.add_code_list_item(cli.notation, "", "#{value.ordinal}")
        decode = code_list_item.add_decode()
        decode.add_translated_text(cli.label)
      end
    end
  end

private

  def self.children_from_triples(object, triples, id)
    #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","*****Entry*****")
    object.item_refs = Form::Item::BcProperty.find_for_parent(triples, object.get_links("bf", "hasCommonItem"))
    links = object.get_links_v2(C_SCHEMA_PREFIX, "hasProperty")
    if links.length > 0
      object.property_ref = OperationalReferenceV2.find_from_triples(triples, links[0].id)
    end      
    links = object.get_links_v2("bf", "hasValue")
    links.each do |link|
      object.value_refs << OperationalReferenceV2.find_from_triples(triples, link.id)
    end      
  end

 end
