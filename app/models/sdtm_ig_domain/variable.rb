class SdtmIgDomain::Variable < Tabular::Column
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :name, :notes, :controlled_term_or_format, :compliance, :variable_ref

  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_M
  C_CLASS_NAME = "SdtmIgDomain::Variable"
  C_CID_PREFIX = SdtmIg::C_CID_PREFIX
  C_RDF_TYPE = "IgVariable"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  # SDTM role classification
  C_CORE_REQD = "Required"
  C_CORE_PERM = "Permissible"
  C_CORE_EXP = "Expected"
  
  def initialize(triples=nil, id=nil)
    self.name = ""
    self.notes = ""
    self. controlled_term_or_format = ""
    self.variable_ref = nil
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def compliance_label
    return compliance.nil? ? "" : compliance.label
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  def self.import_sparql(parent_id, sparql, json, compliance_map, class_map)
    id = parent_id + Uri::C_UID_SECTION_SEPARATOR + SdtmUtility.replace_prefix(json[:variable_name])  
    super(id, sparql, C_SCHEMA_PREFIX, C_RDF_TYPE, json[:label])
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "ordinal", "#{json[:ordinal]}", "positiveInteger")
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "controlled_term_or_format", "#{json[:variable_ct_or_format]}", "string")
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "notes", "#{json[:variable_notes]}", "string")
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "name", "#{json[:variable_name]}", "string")
    # Build the reference
    if !class_map.nil?
      var_name = generic_variable_name(json)
      if !class_map[var_name].nil?
        variable = class_map[var_name]
        uri = UriV2.new({:namespace => variable.namespace, :id => variable.id})
        ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'VR'
        sparql.triple("", id, UriManagement::C_BD, "basedOnVariable", "", ref_id.to_s)
        sparql.triple("", ref_id, UriManagement::C_RDF, "type", UriManagement::C_BO, "CReference")
        sparql.triple_uri_full_v2("", ref_id, UriManagement::C_BO, "hasColumn", uri)
        sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "enabled", "true", "boolean")
        sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "optional", "false", "boolean")
        sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "ordinal", "1", "positiveInteger")
      end
    end
    if compliance_map.has_key?(json[:variable_core])
      sparql.triple_uri_full("", id, C_SCHEMA_PREFIX, "compliance", compliance_map[json[:variable_core]])  
    end
    return id
  end

private

  def self.children_from_triples(object, triples, id)
    variable_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "basedOnVariable"))
    object.variable_ref = variable_refs[0]
    compliance = EnumeratedLabel.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "compliance"))
    if compliance.length > 0
      object.compliance = compliance[0]
    end
    
  end

  def self.generic_variable_name(json)
    if json[:variable_name] == json[:variable_name_minus]
      return json[:variable_name]
    else
      return SdtmUtility.add_prefix(json[:variable_name_minus])
    end
  end    

end
