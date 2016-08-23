class Form::Item < IsoConcept

  attr_accessor :ordinal, :note, :completion, :optional

  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Group"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "Item"
  C_CID_SUFFIX = "I"

  @@datatype_map = 
    {
      "S" => "text",
      "I" => "integer",
      "F" => "float",
      "D" => "date",
      "T" => "time",
      "D+T" => "datetime",
      "B" => "boolean",
    }
  
  def thesaurus_concepts(refs)
    return Array.new
  end

  def bc_property
    return nil
  end

  def initialize(triples=nil, id=nil)
    self.ordinal = 1
    self.note = ""
    self.completion = false
    self.optional = false
    if triples.nil?
      super
    else
      super(triples, id)
    end        
  end

  def to_json
    json = super
    json[:ordinal] = self.ordinal
    json[:note] = self.note
    json[:completion] = self.completion
    json[:optional] = self.optional
    return json
  end

  def self.from_json(json)
    object = super(json)
    object.ordinal = json[:ordinal]
    object.note = json[:note]
    object.completion = json[:completion]
    object.optional = json[:optional]
    return object
  end

  def to_sparql(parent_id, sparql)
    self.id = "#{parent_id}#{Uri::C_UID_SECTION_SEPARATOR}#{C_CID_SUFFIX}#{self.ordinal}"
    super(sparql, C_SCHEMA_PREFIX)
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "ordinal", "#{self.ordinal}", "positiveInteger")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "note", "#{self.note}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "completion", "#{self.completion}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "optional", "#{self.optional}", "boolean")
    return self.id
  end

  def to_xml(metadata_version, form_def, item_group_def)
    item_group_def.add_item_ref("#{self.id}", "#{self.ordinal}", "No", "", "", "", "", "")
  end

private

  def to_xml_datatype(datatype)
    if @@datatype_map.has_key?(datatype)
      return @@datatype_map[datatype]
    else
      return "text"
    end
  end

  def to_xml_length(datatype, format)
    if datatype == "S"
      return format
    elsif datatype == "I"
      return format
    elsif datatype == "F"
      parts = format.split('.')
      length = (parts[0].to_i) - 1
      return length
    else
      return ""
    end
  end

  def to_xml_significant_digits(datatype, format)
    if datatype == "F"
      parts = format.split('.')
      digits = (parts[1].to_i)
      return digits
    else
      return ""
    end
  end

 end
