class SdtmModelDomain::Variable < Tabular::Column
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :variable_ref

  # Constants
  C_SCHEMA_PREFIX = SdtmModelDomain::C_SCHEMA_PREFIX
  C_INSTANCE_PREFIX = SdtmModelDomain::C_INSTANCE_PREFIX
  C_CLASS_NAME = "SDTMModelDomain::Variable"
  C_CID_PREFIX = SdtmModel::C_CID_PREFIX
  C_RDF_TYPE = "ClassVariable"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.variable_ref = nil
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  def self.import_sparql(namespace, parent_id, sparql, json, map)
    id = parent_id + Uri::C_UID_SECTION_SEPARATOR + SdtmUtility.replace_prefix(json[:variable_name])  
    subject = {:namespace => namespace, :id => id}
    super(namespace, id, sparql, UriManagement::C_BD, C_RDF_TYPE, json[:label])
    sparql.triple(subject, {:prefix => UriManagement::C_BD, :id => "ordinal"}, {:literal => "#{json[:ordinal]}", :primitive_type => "positiveInteger"})
    uri = map[json[:variable_name]]
    ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'CR'
    ref_subject = {:namespace => namespace, :id => ref_id}
    sparql.triple(subject, {:prefix => UriManagement::C_BD, :id => "basedOnVariable"}, {:namespace => namespace, :id => ref_id.to_s})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_RDF, :id => "type"}, {:prefix => UriManagement::C_BO, :id => "CReference"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "hasColumn"}, {:uri => uri})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "enabled"}, {:literal => "true", :primitive_type => "boolean"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "optional"}, {:literal => "false", :primitive_type => "boolean"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "ordinal"}, {:literal => "#{json[:ordinal]}", :primitive_type => "positiveInteger"})
    return id
  end

  def to_json
    json = super
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
  end

end
