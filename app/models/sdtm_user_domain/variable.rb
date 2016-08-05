class SdtmUserDomain::Variable < Tabular::Column
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :name, :notes, :format, :non_standard, :comment, :length, :used, :key_ordinal, :datatype, :compliance, 
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
  
  def initialize(triples=nil, id=nil)
    self.name = ""
    self.notes = ""
    self.format = "" 
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
      # Set the type. Overwrite default.
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

  def self.find(id, ns, children=true)
    object = super(id, ns, children)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  def to_json
    json = super
    json[:ordinal] = self.ordinal
    json[:name] = self.name
    json[:notes] = self.notes 
    json[:format] = self.format 
    json[:non_standard] = self.non_standard
    json[:comment] = self.comment
    json[:length] = self.length
    json[:used] = self.used
    json[:key_ordinal] = self.key_ordinal
    json[:datatype] = self.datatype.to_json
    #ConsoleLogger::log(C_CLASS_NAME,"to_json","Datatype=#{self.datatype.to_json}")
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

  def self.from_json(json)
    object = super(json)
    object.ordinal = json[:ordinal]
    object.name = json[:name]
    object.notes = json[:notes]
    object.format = json[:format]
    object.non_standard = false
    object.comment = json[:comment]
    object.length = json[:length]
    object.used = json[:used]
    object.key_ordinal = json[:key_ordinal]
    object.datatype = SdtmModelDatatype.from_json(json[:datatype])
    object.compliance = EnumeratedLabel.from_json(json[:compliance])
    object.classification = EnumeratedLabel.from_json(json[:classification]) 
    if json.has_key?(:sub_classification) 
      object.sub_classification = EnumeratedLabel.from_json(json[:sub_classification]) 
    end
    if !json.has_key?(:variable_ref)
      object.variable_ref = nil
    else
      object.variable_ref = OperationalReferenceV2.from_json(json[:variable_ref])
    end
    return object
  end

  def to_sparql(parent_id, sparql)
    self.id = parent_id + Uri::C_UID_SECTION_SEPARATOR + SdtmUtility.replace_prefix(self.name)
    super(sparql, C_SCHEMA_PREFIX)
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "ordinal", "#{self.ordinal}", "positiveInteger")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "name", "#{self.name}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "notes", "#{self.notes}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "format", "#{self.format}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "non_standard", "#{self.non_standard}", "boolean")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "comment", "#{self.comment}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "length", "#{self.length}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "used", "#{self.used}", "boolean")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "key_ordinal", "#{self.key_ordinal}", "positiveInteger")
    sparql.triple_uri_full_v2("", self.id, C_SCHEMA_PREFIX, "typedAs", self.datatype.uri)  
    sparql.triple_uri_full_v2("", self.id, C_SCHEMA_PREFIX, "compliance", self.compliance.uri)  
    if self.sub_classification.nil?
      sparql.triple_uri_full_v2("", self.id, C_SCHEMA_PREFIX, "classifiedAs", self.classification.uri)   
    else
      sparql.triple_uri_full_v2("", self.id, C_SCHEMA_PREFIX, "classifiedAs", self.sub_classification.uri)   
    end
    if !self.variable_ref.nil? 
      ref_id = self.variable_ref.to_sparql(id, "basedOnVariable", C_IGV_REF_PREFIX, 1, sparql)
      sparql.triple("", self.id, UriManagement::C_BD, "basedOnVariable", "", "#{ref_id}")
    end
    return self.id
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
