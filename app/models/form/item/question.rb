class Form::Item::Question < Form::Item

  attr_accessor :datatype, :format, :mapping, :question_text, :tc_refs
  
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Item::Question"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "Question"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  def thesaurus_concepts(refs)
    results = Array.new
    refs.each do |ref|
      results << ThesaurusConcept.find(ref.subject_ref.id, ref.subject_ref.namespace, false)
    end
    return results
  end

  def initialize(triples=nil, id=nil)
    self.tc_refs = Array.new
    self.datatype = ""
    self.format = ""
    self.mapping = ""
    self.question_text = ""
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
    json[:datatype] = self.datatype
    json[:format] = self.format
    json[:question_text] = self.question_text
    json[:mapping] = self.mapping
    json[:children] = Array.new
    self.tc_refs.each do |tc_ref|
      json[:children] << tc_ref.to_json
    end 
    json[:children] = json[:children].sort_by {|item| item[:ordinal]}
    return json
  end

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

  def to_sparql(parent_id, sparql)
    super(parent_id, sparql)
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "datatype", "#{self.datatype}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "format", "#{self.format}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "question_text", "#{self.question_text}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "mapping", "#{self.mapping}", "string")
    self.tc_refs.each do |tc_ref|
      ref_id = tc_ref.to_sparql(id, "hasThesaurusConcept", 'TCR', tc_ref.ordinal, sparql)
      sparql.triple("", self.id, C_SCHEMA_PREFIX, "hasThesaurusConcept", "", "#{ref_id}")
    end
    return self.id
  end
  
  def to_xml(metadata_version, form_def, item_group_def)
    super(metadata_version, form_def, item_group_def)
    xml_datatype = to_xml_datatype(self.datatype)
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

private

  def self.children_from_triples(object, triples, id, bc=nil)
    links = object.get_links_v2(C_SCHEMA_PREFIX, "hasThesaurusConcept")
    links.each do |link|
      object.tc_refs << OperationalReferenceV2.find_from_triples(triples, link.id)
    end      
  end

end
