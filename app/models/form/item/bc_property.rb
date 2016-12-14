class Form::Item::BcProperty < Form::Item

  attr_accessor :property_ref, :value_refs
  
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Item::BcProperty"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "BcProperty"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  # Thesaurus Concepts
  #
  # @return [object] Array of concepts
  def thesaurus_concepts
    results = Array.new
    refs.each do |ref|
      results << ThesaurusConcept.find(ref.subject_ref.id, ref.subject_ref.namespace, false)
    end
    return results
  end

  # BC Property
  #
  # @return [object] The associated BC property
  def bc_property
    result = BiomedicalConceptCore::Property.find(self.property_ref.subject_ref.id, self.property_ref.subject_ref.namespace)
    return result
  end

  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.property_ref = nil
    self.value_refs = Array.new
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end        
  end

  # Find the object
  #
  # @param id [string] The id of the item to be found
  # @param ns [string] The namespace of the item to be found
  # @return [object] The new object
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    object.triples = ""
    return object
  end

  # Find an object from triples
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The id of the item to be found
  # @return [object] The new object
  def self.find_from_triples(triples, id)
    object = new(triples, id)
    children_from_triples(object, triples, id)
    object.triples = ""
    return object
  end
  
  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:property_ref] = self.property_ref.to_json
    json[:children] = Array.new
    value_refs.each do |ref|
      json[:children] << ref.to_json
    end
    return json
  end
  
  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.property_ref = OperationalReferenceV2.from_json(json[:property_ref])
    if !json[:children].blank?
      json[:children].each do |child|
        object.value_refs << OperationalReferenceV2.from_json(child)
      end
    end
    return object
  end

  # To SPARQL
  #
  # @param parent_uri [object] URI object
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2(parent_uri, sparql)
    uri = super(parent_uri, sparql)
    subject = {:uri => uri}
    ref_uri = property_ref.to_sparql_v2(uri, "hasProperty", 'PR', property_ref.ordinal, sparql)
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasProperty"}, {:uri => ref_uri})
    self.value_refs.each do |value_ref|
      ref_uri = value_ref.to_sparql_v2(uri, "hasValue", 'VR', value_ref.ordinal, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasValue"}, {:uri => ref_uri})
    end
    return uri
  end

  # To XML
  #
  # @param metadata_version [object] 
  # @param form_def [object] 
  # @param item_group_def [object]
  # @return null
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

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    super
  end

private

  def self.children_from_triples(object, triples, id)
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
