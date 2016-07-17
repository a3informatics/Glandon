class SdtmIgDomain < Tabular::Tabulation
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  attr_accessor :prefix, :structure, :model_ref

  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_M
  C_CLASS_NAME = "SdtmIgDomain"
  C_CID_PREFIX = SdtmIg::C_CID_PREFIX
  C_RDF_TYPE = "IGDomain"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.prefix = SdtmUtility::C_PREFIX
    self.structure = ""
    self.model_ref = OperationalReferenceV2.new
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

  def self.import_sparql(params, sparql, compliance_map, class_map)
    # Init data
    object = self.new 
    object.errors.clear
    # Get the Json structure
    data = params[:data]
    operation = data[:operation]
    managed_item = data[:managed_item]
    ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    uri = IsoManaged.create_sparql(C_CID_PREFIX, data, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS, sparql, ra)
    id = uri.getCid()
    namespace = uri.getNs()
    # Set the map
    map = class_map[managed_item[:domain_class]]
    # Set the properties
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "prefix", "#{managed_item[:domain_prefix]}", "string")
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "structure", "#{managed_item[:domain_structure]}", "string")
    # Build the class reference
    if !map.nil? 
      ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'CLR'
      sparql.triple("", id, UriManagement::C_BD, "basedOnDomain", "", ref_id.to_s)
      sparql.triple("", ref_id, UriManagement::C_RDF, "type", UriManagement::C_BO, "TReference")
      ref_uri = class_map[managed_item[:domain_class]][:uri]
      sparql.triple_uri_full_v2("", ref_id, UriManagement::C_BO, "hasTabulation", ref_uri)
      sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "enabled", "true", "boolean")
      sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "optional", "false", "boolean")
      sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "ordinal", "1", "positiveInteger")
    end
    # Now deal with the children
    if managed_item.has_key?(:children)
      managed_item[:children].each do |key, item|
        if !map.nil?
          ref_id = SdtmIgDomain::Variable.import_sparql(id, sparql, item, compliance_map, map[:children])
        else
          ref_id = SdtmIgDomain::Variable.import_sparql(id, sparql, item, compliance_map, nil)
        end
        sparql.triple("", id, C_SCHEMA_PREFIX, "includesColumn", "", ref_id)
      end
    end
    return { :uri => uri, :map => map, :object => object }
  end

private

  def self.children_from_triples(object, triples, id)
    object.children = SdtmIgDomain::Variable.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesColumn"))
    model_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "basedOnDomain"))
    if model_refs.length > 0 
      object.model_ref = model_refs[0]
    end
  end

end
