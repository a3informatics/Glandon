class SdtmModelDomain < Tabular
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  attr_accessor :children

  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_MD
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
  C_SPECIAL_PURPOSE_IDENTIFIER = "SDTMMODEL_SPECIAL_PURPOSE"
  C_TRIAL_DESIGN_IDENTIFIER = "SDTMMODEL_TRIAL_DESIGN"
  C_RELATIONSHIP_IDENTIFIER = "SDTMMODEL_RELATIONSHIP"
    
  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.children = Array.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  # Find a given model domain.
  #
  # @param id [String] the id of the domain
  # @param namespace [String] the namespace of the domain
  # @param children [Boolean] find all child objects. Defaults to true.
  # @return [SdtmModelDomain] the domain object.
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  # Find all model domains.
  #
  # @return [Array] array of objects found
  def self.all
    return IsoManaged.all_by_type(C_RDF_TYPE, C_SCHEMA_NS)
  end

  # Find all released model domains.
  #
  # @return [Array] An array of objects
  def self.list
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

	def self.build_and_sparql(params, sparql, model)
    cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    SdtmModelDomain.variable_references(params, model)
    object = SdtmModelDomain.from_json(params[:managed_item])
    object.from_operation(params[:operation], C_CID_PREFIX, C_INSTANCE_NS, cdisc_ra)
    if object.valid? then
      if object.create_permitted?
        object.to_sparql_v2(sparql)
      end
    end
    return object
  end

  # To SPARQL
  #
  # @param [SparqlUpdateV2] sparql the SPARQL object
  # @param [String] schema_prefix the schema prefix for the triples
	# @return [UriV2] The URI
  def to_sparql_v2(sparql, schema_prefix)
    super(sparql, schema_prefix)
    subject = {:uri => self.uri}
    self.children.each do |child|
    	ref_uri = child.to_sparql_v2(sparql, schema_prefix)
    	sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesColumn"}, {:uri => ref_uri})
    end
    return self.uri
  end

	# From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmModelDomain] the object created
  def self.from_json(json)
    object = super(json)
    json[:children].each { |c| object.children << SdtmModelDomain::Variable.from_json(c) } if !json[:children].blank?
    return object
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:children] = Array.new
    self.children.each do |child|
      json[:children] << child.to_json
    end
    return json
  end

private

	def self.variable_references(params, model)
		params[:children].each do |child|
			new_child = model.children.select { |c| where c.name == child.name }
			ref = OperationalReferenceV2.new
			ref.subject_ref = new_child.uri
			child[:variable_ref] = ref.to_json
		end
	end

  def self.children_from_triples(object, triples, id)
    object.children = SdtmModelDomain::Variable.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesColumn"))
  end

end
