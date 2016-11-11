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
  
  # Thesaurus Concepts
  # A null method for those classes who dont need to return TCs.
  #
  # @return [object] An empty array
  def thesaurus_concepts
    return Array.new
  end

  # BC Property
  # A null method for those classes who dont need to return a BC property.
  #
  # @return [nil]
  def bc_property
    return nil
  end

  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.ordinal = 1
    self.note = ""
    self.completion = ""
    self.optional = false
    if triples.nil?
      super
    else
      super(triples, id)
    end        
  end

  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:ordinal] = self.ordinal
    json[:note] = self.note
    json[:completion] = self.completion
    json[:optional] = self.optional
    return json
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.ordinal = json[:ordinal]
    object.note = json[:note]
    object.completion = json[:completion]
    object.optional = json[:optional]
    return object
  end

  # To SPARQL
  #
  # @param parent_uri [object] URI object
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2(parent_uri, sparql)
    self.namespace = parent_uri.namespace
    self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{C_CID_SUFFIX}#{self.ordinal}"
    uri = super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "ordinal"}, {:literal => "#{self.ordinal}", :primitive_type => "positiveInteger"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "note"}, {:literal => "#{self.note}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "completion"}, {:literal => "#{self.completion}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "optional"}, {:literal => "#{self.optional}", :primitive_type => "boolean"})
    return uri
  end

  # To XML
  #
  # @param metadata_version [object] 
  # @param form_def [object] 
  # @param item_group_def [object]
  def to_xml(metadata_version, form_def, item_group_def)
    item_group_def.add_item_ref("#{self.id}", "#{self.ordinal}", "No", "", "", "", "", "")
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    result = super
    result = result &&
      FieldValidation::valid_markdown?(:completion, self.completion, self) &&
      FieldValidation::valid_markdown?(:note, self.note, self)
    return result
  end

private

  def to_xml_length(datatype, format)
    if datatype == BaseDatatype::C_STRING
      return format
    elsif datatype == BaseDatatype::C_INTEGER || datatype == BaseDatatype::C_POSITIVE_INTEGER
      return format
    elsif datatype == BaseDatatype::C_FLOAT
      parts = format.split('.')
      length = (parts[0].to_i) - 1
      return length
    else
      return ""
    end
  end

  def to_xml_significant_digits(datatype, format)
    if datatype == BaseDatatype::C_FLOAT
      parts = format.split('.')
      digits = (parts[1].to_i)
      return digits
    else
      return ""
    end
  end

 end
