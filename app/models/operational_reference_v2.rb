class OperationalReferenceV2 < IsoConcept

  attr_accessor :subject_ref, :enabled, :optional, :ordinal, :local_label
  #validates_presence_of :concept, :property, :value, :enabled

  # Constants
  C_NONE = "None"
  
  C_PARENT_LINK_BC = "hasBiomedicalConcept"
  C_PARENT_LINK_P = "hasProperty"
  C_PARENT_LINK_V = "hasValue"
  C_PARENT_LINK_TC = "hasThesaurusConcept"
  C_PARENT_LINK_T = "includesTabulation"
  C_PARENT_LINK_DT = "basedOnDomain"
  C_PARENT_LINK_C = "includesColumn"
  C_PARENT_LINK_VC = "basedOnVariable"
  
  C_BC_TYPE = "BcReference"
  C_P_TYPE = "PReference"
  C_V_TYPE = "VReference"
  C_TC_TYPE = "TcReference"
  C_T_TYPE = "TReference"
  C_C_TYPE = "CReference"
  
  C_BC_LINK = "hasBiomedicalConcept"
  C_P_LINK = "hasProperty"
  C_V_LINK = "hasValue"
  C_TC_LINK = "hasThesaurusConcept"
  C_T_LINK = "hasTabulation"
  C_C_LINK = "hasColumn"
  
  C_SCHEMA_PREFIX = "bo"
  C_CLASS_NAME = "OperationalReferenceV2"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "Reference"

  C_TO_TYPE_MAP = 
    {
      C_PARENT_LINK_BC => C_BC_TYPE,
      C_PARENT_LINK_P => C_P_TYPE,
      C_PARENT_LINK_V => C_V_TYPE,
      C_PARENT_LINK_TC => C_TC_TYPE,
      C_PARENT_LINK_T => C_T_TYPE,
      C_PARENT_LINK_DT => C_T_TYPE,
      C_PARENT_LINK_C => C_C_TYPE,
      C_PARENT_LINK_VC => C_C_TYPE
    }
    
  C_TO_LINK_MAP = 
    {
      C_PARENT_LINK_BC => C_BC_LINK,
      C_PARENT_LINK_P => C_P_LINK,
      C_PARENT_LINK_V => C_V_LINK,
      C_PARENT_LINK_TC => C_TC_LINK,
      C_PARENT_LINK_T => C_T_LINK,
      C_PARENT_LINK_DT => C_T_LINK,
      C_PARENT_LINK_C => C_C_LINK,
      C_PARENT_LINK_VC => C_C_LINK
    }
    
  C_FROM_TYPE_MAP = 
    {
      "#{C_SCHEMA_NS}##{C_BC_TYPE}" => C_BC_LINK,
      "#{C_SCHEMA_NS}##{C_P_TYPE}" => C_P_LINK,
      "#{C_SCHEMA_NS}##{C_V_TYPE}" => C_V_LINK,
      "#{C_SCHEMA_NS}##{C_TC_TYPE}" => C_TC_LINK,
      "#{C_SCHEMA_NS}##{C_T_TYPE}" => C_T_LINK,
      "#{C_SCHEMA_NS}##{C_C_TYPE}" => C_C_LINK
    }
    
  def initialize(triples=nil, id=nil)
    self.enabled = true
    self.optional = false
    self.ordinal = 0
    self.local_label = ""
    self.subject_ref = nil
    if triples.nil?
      super
      # Set the type. Overwrite default.
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"    
    else
      super(triples, id)
    end
  end

  def to_json
    json = super
    json[:enabled] = self.enabled
    json[:optional] = self.optional
    json[:ordinal] = self.ordinal
    json[:local_label] = self.local_label
    json[:subject_ref] = self.subject_ref.to_json
    return json
  end

  def self.from_json(json)
    object = super(json)
    object.enabled = json[:enabled]
    object.optional = json[:optional]
    object.ordinal = json[:ordinal]
    object.local_label = json[:local_label]
    object.subject_ref = UriV2.new(json[:subject_ref])
    return object
  end

  def to_sparql(parent_id, ref_type, suffix, ordinal, sparql)
    ConsoleLogger::log(C_CLASS_NAME,"to_sparql","Op ref=#{self.to_json}")
    ref_id = "#{parent_id}#{Uri::C_UID_SECTION_SEPARATOR}#{suffix}#{ordinal}"
    sparql.triple("", ref_id, UriManagement::C_RDF, "type", UriManagement::C_BO, "#{C_TO_TYPE_MAP[ref_type]}")
    sparql.triple_uri_full_v2("", ref_id, UriManagement::C_BO, "#{C_TO_LINK_MAP[ref_type]}", self.subject_ref)
    sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "enabled", "true", "boolean")
    sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "optional", "false", "boolean")
    sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "ordinal", "#{ordinal}", "positiveInteger")
    return ref_id
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    links = object.get_links(C_SCHEMA_PREFIX, C_FROM_TYPE_MAP[object.rdf_type])
    if links.length > 0
      object.subject_ref = UriV2.new({:uri => links[0]})
    end
    object.triples = ""
    return object
  end

end