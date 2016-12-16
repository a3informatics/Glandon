class Form::Item::Question < Form::Item

  attr_accessor :datatype, :format, :mapping, :question_text, :tc_refs
  
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Item::Question"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "Question"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  # Thesaurus Concepts
  #
  # @return [object] An array of Thesaurus Concepts
  def thesaurus_concepts
    results = Array.new
    self.tc_refs.each do |ref|
      results << ThesaurusConcept.find(ref.subject_ref.id, ref.subject_ref.namespace, false)
    end
    return results
  end

  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.tc_refs = Array.new
    self.datatype = ""
    self.format = ""
    self.mapping = ""
    self.question_text = ""
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
      # Special. Update datatype if using old scheme
      if !FieldValidation::valid_datatype?(:datatype, self.datatype, self)
        self.datatype = BaseDatatype.from_short_label(self.datatype)
      end
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
    return object
  end
  
  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:datatype] = self.datatype
    json[:format] = self.format
    json[:question_text] = self.question_text
    json[:mapping] = self.mapping
    json[:children] = Array.new
    self.tc_refs.sort_by! {|u| u.ordinal}
    self.tc_refs.each do |tc_ref|
      json[:children] << tc_ref.to_json
    end 
    json[:children] = json[:children].sort_by {|item| item[:ordinal]}
    return json
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.datatype = json[:datatype]
    object.format = json[:format]
    object.question_text = json[:question_text]
    object.mapping = json[:mapping]
    if !json[:children].blank?
      json[:children].each do |child|
        object.tc_refs << OperationalReferenceV2.from_json(child)
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
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "datatype"}, {:literal => "#{self.datatype}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "format"}, {:literal => "#{self.format}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "question_text"}, {:literal => "#{self.question_text}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "mapping"}, {:literal => "#{self.mapping}", :primitive_type => "string"})
    self.tc_refs.each do |tc_ref|
      ref_uri = tc_ref.to_sparql_v2(uri, "hasThesaurusConcept", 'TCR', tc_ref.ordinal, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasItem"}, {:uri => uri})
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
    xml_datatype = BaseDatatype.to_odm(self.datatype)
    xml_length = to_xml_length(self.datatype, self.format)
    xml_digits = to_xml_significant_digits(self.datatype, self.format)
    item_def = metadata_version.add_item_def("#{self.id}", "#{self.label}", "#{xml_datatype}", "#{xml_length}", "#{xml_digits}", "", "", "", "")
    question = item_def.add_question()
    question.add_translated_text("#{self.question_text}")
    if tc_refs.length > 0
      code_list_ref = item_def.add_code_list_ref("#{self.id}-CL")
      code_list = metadata_version.add_code_list("#{self.id}-CL", "Code list for #{self.label}", "text", "")
      self.tc_refs.each do |tc_ref|
        tc = ThesaurusConcept.find(tc_ref.subject_ref.id, tc_ref.subject_ref.namespace)
        code_list_item = code_list.add_code_list_item(tc.notation, "", "#{tc_ref.ordinal}")
        decode = code_list_item.add_decode()
        decode.add_translated_text(tc.label)
      end
    end
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    result = super
    result = result &&
      FieldValidation::valid_mapping?(:mapping, self.mapping, self) &&
      FieldValidation::valid_format?(:question_text, self.format, self) &&
      FieldValidation::valid_question?(:question_text, self.question_text, self) &&
      FieldValidation::valid_datatype?(:datatype, self.datatype, self)
    return result
  end

private

  def self.children_from_triples(object, triples, id)
    links = object.get_links_v2(C_SCHEMA_PREFIX, "hasThesaurusConcept")
    links.each do |link|
      object.tc_refs << OperationalReferenceV2.find_from_triples(triples, link.id)
    end      
  end

end
