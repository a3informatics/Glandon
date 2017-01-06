class SdtmUserDomain::Variable < Tabular::Column
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :name, :notes, :ct, :format, :non_standard, :comment, :length, :used, :key_ordinal, :datatype, :compliance, 
    :classification, :sub_classification, :variable_ref

  # Constants
  C_SCHEMA_PREFIX = SdtmUserDomain::C_SCHEMA_PREFIX
  C_INSTANCE_PREFIX = SdtmUserDomain::C_INSTANCE_PREFIX
  C_CLASS_NAME = "SdtmUserDomain::Variable"
  C_CID_PREFIX = SdtmUserDomain::C_CID_PREFIX
  C_RDF_TYPE = "UserVariable"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  C_IGV_REF_PREFIX = "IGV"
  C_VARIABLE_PREFIX = "V"
  
  def initialize(triples=nil, id=nil)
    self.name = ""
    self.notes = ""
    self.format = "" 
    self.ct = "" 
    self.non_standard = false
    self.comment = ""
    self.length = 0
    self.used = true
    self.key_ordinal = 0
    self.datatype = nil
    self.compliance = nil
    self.classification = nil 
    self.sub_classification = nil 
    self.variable_ref = nil
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  def classification_label
    return classification.nil? ? "" : classification.label
  end

  def sub_classification_label
    return sub_classification.nil? ? "" : sub_classification.label 
  end
  
  def datatype_label
    return datatype.nil? ? "" : datatype.label 
  end

  def compliance_label
    return compliance.nil? ? "" : compliance.label
  end

  # Find a given variable
  #
  # @param id [String] the id of the variable
  # @param namespace [String] the namespace of the variable
  # @param children [Boolean] find all child objects. Defaults to true.
  # @return [SdtmUserDomain::Variable] The variable object.
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:name] = self.name
    json[:notes] = self.notes 
    json[:format] = self.format 
    json[:ct] = self.ct 
    json[:non_standard] = self.non_standard
    json[:comment] = self.comment
    json[:length] = self.length
    json[:used] = self.used
    json[:key_ordinal] = self.key_ordinal
    json[:datatype] = self.datatype.to_json
    json[:compliance] = self.compliance.to_json
    json[:classification] = self.classification.to_json
    if !self.sub_classification.nil? 
      json[:sub_classification] = self.sub_classification.to_json
    end
    if !self.variable_ref.nil? 
      json[:variable_ref] = self.variable_ref.to_json
    else
      json[:variable_ref] = {}
    end
    return json
  end

  # From JSON
  #
  # @param json [Hash] the hash of values for the object 
  # @return [SdtmUserDomain::Variable] the object
  def self.from_json(json)
    object = super(json)
    object.name = json[:name]
    object.notes = json[:notes]
    object.format = json[:format]
    object.ct = json[:ct]
    object.non_standard = json[:non_standard]
    object.comment = json[:comment]
    object.length = json[:length]
    object.used = json[:used]
    object.key_ordinal = json[:key_ordinal]
    object.datatype = SdtmModelDatatype.from_json(json[:datatype])
    object.compliance = EnumeratedLabel.from_json(json[:compliance])
    object.classification = EnumeratedLabel.from_json(json[:classification]) 
    if !json[:sub_classification].blank? 
      object.sub_classification = EnumeratedLabel.from_json(json[:sub_classification]) 
    end
    if !json[:variable_ref].blank?
      object.variable_ref = OperationalReferenceV2.from_json(json[:variable_ref])
    else
      object.variable_ref = nil      
    end
    return object
  end

  # To SPARQL
  #
  # @param parent_uri [UriV2] the parent URI object
  # @param sparql [SparqlUpdateV2] the SPARQL object
  # @return [UriV2] the item's URI
  def to_sparql_v2(parent_uri, sparql)
    self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{C_VARIABLE_PREFIX}#{self.ordinal}"
    self.namespace = parent_uri.namespace
    super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => self.uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "name"}, {:literal => "#{self.name}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "notes"}, {:literal => "#{self.notes}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "format"}, {:literal => "#{self.format}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "ct"}, {:literal => "#{self.ct}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "non_standard"}, {:literal => "#{self.non_standard}", :primitive_type => "boolean"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "comment"}, {:literal => "#{self.comment}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "length"}, {:literal => "#{self.length}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "used"}, {:literal => "#{self.used}", :primitive_type => "boolean"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "key_ordinal"}, {:literal => "#{self.key_ordinal}", :primitive_type => "integer"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "typedAs"}, {:uri => self.datatype.uri})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "compliance"}, {:uri => self.compliance.uri})
    if self.sub_classification.nil?
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "classifiedAs"}, {:uri => self.classification.uri})
    else
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "classifiedAs"}, {:uri => self.sub_classification.uri})
    end
    if !self.variable_ref.nil? 
      ref_uri = self.variable_ref.to_sparql_v2(self.uri, "basedOnVariable", C_IGV_REF_PREFIX, 1, sparql)
      sparql.triple(subject, {:prefix => UriManagement::C_BD, :id => "basedOnVariable"}, {:uri => ref_uri})
    end
    return self.uri
  end

  # Check Valid
  #
  # @return [Boolean] returns true if valid, false otherwise.
  def valid?
    #result = super 
    result = true
    result = result &&
      FieldValidation::valid_sdtm_variable_name?(:name, self.name, self) && 
      FieldValidation::valid_submission_value?(:ct, self.ct, self) && 
      FieldValidation::valid_sdtm_format_value?(:format, self.format, self) && 
      FieldValidation::valid_boolean?(:non_standard, self.non_standard, self) &&
      FieldValidation::valid_boolean?(:used, self.used, self) &&
      FieldValidation::valid_integer?(:key_ordinal, self.key_ordinal, self) &&
      FieldValidation::valid_integer?(:length, self.length, self) &&
      FieldValidation::valid_label?(:notes, self.notes, self) &&
      FieldValidation::valid_label?(:comment, self.comment, self)
    return result
  end

private

  def self.children_from_triples(object, triples, id)
    variable_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "basedOnVariable"))
    if variable_refs.length > 0
      object.variable_ref = variable_refs[0]
    end
    links = object.get_links_v2(C_SCHEMA_PREFIX, "compliance")
    if links.length > 0
      object.compliance = EnumeratedLabel.find(links[0].id, links[0].namespace)
    end
    links = object.get_links_v2(C_SCHEMA_PREFIX, "typedAs")
    if links.length > 0
      object.datatype = SdtmModelDatatype.find(links[0].id, links[0].namespace)
    end
    # Work out the classifcation and sub-classification
    links = object.get_links_v2(C_SCHEMA_PREFIX, "classifiedAs")
    if links.length > 0
      classification = EnumeratedLabel.find(links[0].id, links[0].namespace)
      parent_links = classification.get_links_v2(C_SCHEMA_PREFIX, "parentClassification")
      if parent_links.length > 0
        object.classification = EnumeratedLabel.find(parent_links[0].id, parent_links[0].namespace)
        object.sub_classification = classification
      else
        object.classification = classification
        object.sub_classification = nil
      end
    end
  end  

end
