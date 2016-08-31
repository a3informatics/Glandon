class Form::Item::TextLabel < Form::Item

  attr_accessor :label_text
  
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Item::Label"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "TextLabel"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  def initialize(triples=nil, id=nil)
    self.label_text = ""
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
    object.triples = ""
    return object
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    object.triples = ""
    return object
  end
  
  def to_json
    json = super
    json[:label_text] = self.label_text
    return json
  end

  def self.from_json(json)
    object = super(json)
    object.label_text = json[:label_text]
    return object
  end

  def to_sparql(parent_id, sparql)
    super(parent_id, sparql)
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "label_text", "#{self.label_text}", "string")
    return self.id
  end
  
  def to_xml(metadata_version, form_def, item_group_def)
    super(metadata_version, form_def, item_group_def)
    item_def = metadata_version.add_item_def("#{self.id}", "#{self.label}", "", "", "", "", "", "", "")
    question = item_def.add_question()
    question.add_translated_text("#{self.label_text}")
  end

 end
