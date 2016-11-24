class OperationalReferenceV2 < IsoConcept

  attr_accessor :subject_ref, :enabled, :optional, :ordinal, :local_label
  
  # Constants
  C_NONE = "None"
  
  C_PARENT_LINK_BC = "hasBiomedicalConcept"
  C_PARENT_LINK_BCT = "basedOnTemplate"
  C_PARENT_LINK_P = "hasProperty"
  C_PARENT_LINK_TC = "hasThesaurusConcept"
  C_PARENT_LINK_T = "includesTabulation"
  C_PARENT_LINK_DT = "basedOnDomain"
  C_PARENT_LINK_C = "includesColumn"
  C_PARENT_LINK_VC = "basedOnVariable"
  
  C_BC_TYPE = "BcReference"
  C_BCT_TYPE = "BctReference"
  C_P_TYPE = "PReference"
  C_TC_TYPE = "TcReference"
  C_T_TYPE = "TReference"
  C_C_TYPE = "CReference"
  
  C_BC_LINK = "hasBiomedicalConcept"
  C_BCT_LINK = "basedOnTemplate"
  C_P_LINK = "hasProperty"
  C_TC_LINK = "hasThesaurusConcept"
  C_T_LINK = "hasTabulation"
  C_C_LINK = "hasColumn"
  
  C_SCHEMA_PREFIX = "bo"
  C_CLASS_NAME = "OperationalReferenceV2"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "Reference"
  C_BC_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_BC_TYPE})
  C_BCT_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_BCT_TYPE})
  C_P_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_P_TYPE})
  C_TC_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_TC_TYPE})
  C_T_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_T_TYPE})
  C_C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_C_TYPE})
  
  C_TO_TYPE_MAP = 
    {
      C_PARENT_LINK_BC => C_BC_TYPE,
      C_PARENT_LINK_P => C_P_TYPE,
      C_PARENT_LINK_TC => C_TC_TYPE,
      C_PARENT_LINK_T => C_T_TYPE,
      C_PARENT_LINK_DT => C_T_TYPE,
      C_PARENT_LINK_C => C_C_TYPE,
      C_PARENT_LINK_VC => C_C_TYPE,
      C_PARENT_LINK_BCT => C_BCT_TYPE
    }
    
  C_TO_LABEL_MAP = 
    {
      C_PARENT_LINK_BC => "BC Reference",
      C_PARENT_LINK_P => "BC Property Reference",
      C_PARENT_LINK_TC => "Thesaurus Concept Reference",
      C_PARENT_LINK_T => "Tabulation Reference",
      C_PARENT_LINK_DT => "Based on Domain Reference",
      C_PARENT_LINK_C => "Column Reference",
      C_PARENT_LINK_VC => "Based on Variable Reference",
      C_PARENT_LINK_BCT => "Based on Template Reference"
    }
    
  C_TO_LINK_MAP = 
    {
      C_PARENT_LINK_BC => C_BC_LINK,
      C_PARENT_LINK_P => C_P_LINK,
      C_PARENT_LINK_TC => C_TC_LINK,
      C_PARENT_LINK_T => C_T_LINK,
      C_PARENT_LINK_DT => C_T_LINK,
      C_PARENT_LINK_C => C_C_LINK,
      C_PARENT_LINK_VC => C_C_LINK,
      C_PARENT_LINK_BCT => C_BCT_LINK
    }
    
  C_FROM_TYPE_MAP = 
    {
      C_BC_RDF_TYPE_URI.to_s => C_BC_LINK,
      C_P_RDF_TYPE_URI.to_s => C_P_LINK,
      C_TC_RDF_TYPE_URI.to_s => C_TC_LINK,
      C_T_RDF_TYPE_URI.to_s => C_T_LINK,
      C_C_RDF_TYPE_URI.to_s => C_C_LINK,
      C_BCT_RDF_TYPE_URI.to_s => C_BCT_LINK
    }
    
  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.enabled = true
    self.optional = false
    self.ordinal = 0
    self.local_label = ""
    self.subject_ref = nil
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"    
    else
      super(triples, id)
    end
  end

  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:enabled] = self.enabled
    json[:optional] = self.optional
    json[:ordinal] = self.ordinal
    json[:local_label] = self.local_label
    json[:subject_ref] = self.subject_ref.to_json
    return json
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.enabled = json[:enabled]
    object.optional = json[:optional]
    object.ordinal = json[:ordinal]
    object.local_label = json[:local_label]
    object.subject_ref = UriV2.new(json[:subject_ref])
    return object
  end

  # To SPARQL
  #
  # @param parent_uri [object] URI object
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2(parent_uri, ref_type, suffix, ordinal, sparql)
    self.namespace = parent_uri.namespace
    self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{suffix}#{ordinal}"
    self.rdf_type = "#{UriV2.new({ :namespace => C_SCHEMA_NS, :id => C_TO_TYPE_MAP[ref_type]})}"
    self.label = C_TO_LABEL_MAP[ref_type]
    uri = super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => uri}
    sparql.triple(subject, {:prefix => UriManagement::C_BO, :id => "#{C_TO_LINK_MAP[ref_type]}"}, {:uri => self.subject_ref })
    sparql.triple(subject, {:prefix => UriManagement::C_BO, :id => "enabled"}, {:literal => "true", :primitive_type => "boolean"})
    sparql.triple(subject, {:prefix => UriManagement::C_BO, :id => "optional"}, {:literal => "false", :primitive_type => "boolean"})
    sparql.triple(subject, {:prefix => UriManagement::C_BO, :id => "ordinal"}, {:literal => "#{ordinal}", :primitive_type => "positiveInteger"})
    sparql.triple(subject, {:prefix => UriManagement::C_BO, :id => "local_label"}, {:literal => "#{local_label}", :primitive_type => "string"})
    return uri
  end

  # Find an object from triples
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The id of the item to be found
  # @return [object] The new object
  def self.find_from_triples(triples, id)
    object = new(triples, id)
    if C_FROM_TYPE_MAP.has_key?(object.rdf_type)
      links = object.get_links(C_SCHEMA_PREFIX, C_FROM_TYPE_MAP[object.rdf_type])
      if links.length > 0
        object.subject_ref = links[0]
      end
    #else
    #  ConsoleLogger.info(C_CLASS_NAME, "find_from_triples", "object=#{object.to_json}.")
    #  ConsoleLogger.info(C_CLASS_NAME, "find_from_triples", "C_FROM_TYPE_MAP=#{C_FROM_TYPE_MAP.to_json}.")
    end
    return object
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    result = FieldValidation::valid_markdown?(:label_text, self.local_label, self)
    return result
  end

end