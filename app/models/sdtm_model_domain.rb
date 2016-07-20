class SdtmModelDomain < Tabular::Tabulation
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_M
  C_CLASS_NAME = "SdtmModelDomain"
  C_CID_PREFIX = SdtmModel::C_CID_PREFIX
  C_RDF_TYPE = "ClassDomain"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  C_EVENTS_LABEL = "Events"
  C_FINDINGS_LABEL = "Findings"
  C_INTERVENTIONS_LABEL = "Interventions"
  C_FINDINGS_ABOUT_LABEL = "Findings About"
  C_SPECIAL_PURPOSE_LABEL = "Special Purpose"
  C_TRIAL_DESIGN_LABEL = "Trial Design"
  C_RELATIONSHIP_LABEL = "Relationship"
  C_ASSOCIATED_PERSON_LABEL = "Associated Person"
  
  C_EVENTS_IDENTIFIER = "SDTMMODEL_EVENTS"
  C_FINDINGS_IDENTIFIER = "SDTMMODEL_FINDINGS"
  C_INTERVENTIONS_IDENTIFIER = "SDTMMODEL_INTERVENTIONS"
    
  def initialize(triples=nil, id=nil)
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

  def self.import_sparql(params, sparql, model_map)
    # Init data
    object = self.new 
    object.errors.clear
    map = Hash.new
    # Get the Json structure
    data = params[:data]
    operation = data[:operation]
    managed_item = data[:managed_item]
    ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    uri = IsoManaged.create_sparql(C_CID_PREFIX, data, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS, sparql, ra)
    id = uri.getCid()
    namespace = uri.getNs()
    # Set the properties
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "domain_class", "#{managed_item[:domain_class]}", "string")
    # Now deal with the children
    if managed_item.has_key?(:children)
      managed_item[:children].each do |key, item|
        ref_id = SdtmModelDomain::Variable.import_sparql(id, sparql, item, model_map)
        sparql.triple("", id, C_SCHEMA_PREFIX, "includesColumn", "", ref_id)
        map[item[:variable_name]] = ModelUtility.buildUri(namespace, ref_id)
      end
    end
    return { :uri => uri, :map => map, :object => object }
  end

private

  def self.children_from_triples(object, triples, id)
    object.children = SdtmModelDomain::Variable.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesColumn"))
  end

end
