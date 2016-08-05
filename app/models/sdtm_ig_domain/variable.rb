class SdtmIgDomain::Variable < Tabular::Column
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :name, :notes, :controlled_term_or_format, :compliance, :variable_ref

  # Constants
  C_SCHEMA_PREFIX = SdtmIgDomain::C_SCHEMA_PREFIX
  C_INSTANCE_PREFIX = SdtmIgDomain::C_INSTANCE_PREFIX
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

  def self.import_sparql(namespace, parent_id, sparql, json, compliance_map, class_map)
    id = parent_id + Uri::C_UID_SECTION_SEPARATOR + SdtmUtility.replace_prefix(json[:variable_name])  
    super(namespace, id, sparql, C_SCHEMA_PREFIX, C_RDF_TYPE, json[:label])
    subject = {:namespace => namespace, :id => id}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "ordinal"}, {:literal => "#{json[:ordinal]}", :primitive_type => "positiveInteger"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "controlled_term_or_format"}, {:literal => "#{json[:variable_ct_or_format]}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "notes"}, {:literal => "#{json[:variable_notes]}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "name"}, {:literal => "#{json[:variable_name]}", :primitive_type => "string"})
    # Build the reference
    if !class_map.nil?
      var_name = generic_variable_name(json)
      if !class_map[var_name].nil?
        variable = class_map[var_name]
        uri = UriV2.new({:namespace => variable.namespace, :id => variable.id})
        ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'VR'
        ref_subject = {:namespace => namespace, :id => ref_id}
        sparql.triple(subject, {:prefix => UriManagement::C_BD, :id => "basedOnVariable"}, ref_subject)
        sparql.triple(ref_subject, {:prefix => UriManagement::C_RDF, :id => "type"}, {:prefix => UriManagement::C_BO, :id =>"CReference"})
        sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "hasColumn"}, {:uri => uri})
        sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "enabled"}, {:literal => "true", :primitive_type => "boolean"})
        sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "optional"}, {:literal => "false", :primitive_type => "boolean"})
        sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "ordinal"}, {:literal => "1", :primitive_type => "positiveInteger"})
      end
    end
    if compliance_map.has_key?(json[:variable_core])
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "compliance"}, {:uri => compliance_map[json[:variable_core]]})  
    end
    return id
  end

  def to_json
    json = super
    json[:name] = self.name
    json[:notes] = self.notes
    json[:controlled_term_or_format] = self.controlled_term_or_format
    json[:compliance] = self.compliance.to_json
    if !self.variable_ref.nil? 
      json[:variable_ref] = self.variable_ref.to_json
    end
    return json
  end

private

  def self.children_from_triples(object, triples, id)
    variable_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "basedOnVariable"))
    if variable_refs.length > 0
      object.variable_ref = variable_refs[0]
    end
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
