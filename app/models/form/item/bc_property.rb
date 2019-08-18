class Form::Item::BcProperty < Form::Item

  attr_accessor :is_common, :property_ref, :children
  
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
    children.each do |child|
      #results << ThesaurusConcept.find(child.subject_ref.id, child.subject_ref.namespace, false)
      results << Thesaurus::UnmanagedConcept.find(Uri.new(fragment: child.subject_ref.id, namespace: child.subject_ref.namespace))
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
    self.is_common = false
    self.property_ref = nil
    self.children = Array.new
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
    json[:is_common] = self.is_common
    json[:property_ref] = self.property_ref.to_json
    json[:children] = Array.new
    self.children.sort_by! {|u| u.ordinal}
    children.each do |child|
      json[:children] << child.to_json
    end
    return json
  end
  
  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.is_common = json[:is_common]
    object.property_ref = OperationalReferenceV2.from_json(json[:property_ref])
    if !json[:children].blank?
      json[:children].each do |child|
        object.children << OperationalReferenceV2.from_json(child)
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
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "is_common"}, {:literal => "#{self.is_common}", :primitive_type => "boolean"})
    ref_uri = property_ref.to_sparql_v2(uri, "hasProperty", 'PR', property_ref.ordinal, sparql)
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasProperty"}, {:uri => ref_uri})
    self.children.each do |child|
      ref_uri = child.to_sparql_v2(uri, "hasThesaurusConcept", 'TCR', child.ordinal, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasThesaurusConcept"}, {:uri => ref_uri})
    end
    return uri
  end

  # To XML
  #
  # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
  # @param [Nokogiri::Node] form_def the ODM FormDef node
  # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
  # @return [void]
  def to_xml(metadata_version, form_def, item_group_def)
    super(metadata_version, form_def, item_group_def)
    bc_property = BiomedicalConceptCore::Property.find(property_ref.subject_ref.id, property_ref.subject_ref.namespace)
    xml_datatype = BaseDatatype.to_odm(bc_property.simple_datatype)
    xml_length = to_xml_length(bc_property.simple_datatype, bc_property.format)
    xml_digits = to_xml_significant_digits(bc_property.simple_datatype, bc_property.format)
    item_def = metadata_version.add_item_def("#{self.id}", "#{self.label}", "#{xml_datatype}", "#{xml_length}", "#{xml_digits}", "", "", "", "")
    question = item_def.add_question()
    question.add_translated_text("#{bc_property.question_text}")
    if children.length > 0
      code_list_ref = item_def.add_code_list_ref("#{self.id}-CL")
      code_list = metadata_version.add_code_list("#{self.id}-CL", "Code list for #{self.label}", "text", "")
      children.each do |tc_ref|
      	#cli = ThesaurusConcept.find(tc_ref.subject_ref.id, tc_ref.subject_ref.namespace)
        cli = Thesaurus::UnmanagedConcept.find(Uri.new(fragment: tc_ref.subject_ref.id, namespace: tc_ref.subject_ref.namespace))
        code_list_item = code_list.add_code_list_item(cli.notation, "", "#{tc_ref.ordinal}")
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
    links = object.get_links_v2(C_SCHEMA_PREFIX, "hasThesaurusConcept")
    links.each do |link|
      object.children << OperationalReferenceV2.find_from_triples(triples, link.id)
    end      
  end

 end
