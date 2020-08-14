class SdtmClass < Tabulation

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmClass",
            uri_suffix: "CL"
  
  #data_property :domain_class

  #attr_accessor :children

  # Get Children.
  #
  # @return [Array] array of objects
  def get_children
    results = []
    query_string = %Q{SELECT DISTINCT ?var ?ordinal ?type ?label ?typedas ?name ?desc ?classifiedas WHERE
{
  #{self.uri.to_ref} bd:includesColumn ?c .
  ?c bd:ordinal ?ordinal .
  ?c bd:basedOnVariable ?var .     
  ?var rdf:type ?type.
  ?var isoC:label ?label. 
  ?var bd:name ?name .
  ?var bd:description ?desc .
  ?var bd:typedAs ?tas .
  ?tas isoC:label ?typedas .
  ?var bd:classifiedAs ?cas .
  ?cas isoC:label ?classifiedas .  
} ORDER BY ?ordinal
}
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bd])
    query_results.by_object_set([:var, :ordinal, :type, :label, :typedas, :name, :desc, :classifiedas]).each do |x|
      results << {uri: x[:var].to_s, ordinal: x[:ordinal].to_i, rdf_type: x[:type].to_s, label: x[:label], name: x[:name],
                  description: x[:desc], typed_as: x[:typedas], classified_as: x[:classifiedas]}
    end
    results
  end

  # Constants
  # C_SCHEMA_PREFIX = UriManagement::C_BD
  # C_INSTANCE_PREFIX = UriManagement::C_MDR_MD
  # C_CLASS_NAME = "SdtmModelDomain"
  # C_CID_PREFIX = SdtmModel::C_CID_PREFIX
  # C_RDF_TYPE = "ClassDomain"
  # C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  # C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  # C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  # C_EVENTS_LABEL = "Events"
  # C_FINDINGS_LABEL = "Findings"
  # C_INTERVENTIONS_LABEL = "Interventions"
  # C_FINDINGS_ABOUT_LABEL = "Findings About"
  # C_SPECIAL_PURPOSE_LABEL = "Special Purpose"
  # C_TRIAL_DESIGN_LABEL = "Trial Design"
  # C_RELATIONSHIP_LABEL = "Relationship"
  # C_ASSOCIATED_PERSON_LABEL = "Associated Person"
  
  # C_EVENTS_IDENTIFIER = "SDTMMODEL EVENTS"
  # C_FINDINGS_IDENTIFIER = "SDTMMODEL FINDINGS"
  # C_INTERVENTIONS_IDENTIFIER = "SDTMMODEL INTERVENTIONS"
  # C_SPECIAL_PURPOSE_IDENTIFIER = "SDTMMODEL SPECIAL PURPOSE"
  # C_TRIAL_DESIGN_IDENTIFIER = "SDTMMODEL TRIAL DESIGN"
  # C_RELATIONSHIP_IDENTIFIER = "SDTMMODEL RELATIONSHIP"
  # C_FINDINGS_ABOUT_IDENTIFIER = "SDTMMODEL FINDINGS ABOUT"
    
  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  # def initialize(triples=nil, id=nil)
  #   self.children = Array.new
  #   if triples.nil?
  #     super
  #     self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
  #   else
  #     super(triples, id)
  #   end
  # end

  # Find a given model domain.
  #
  # @param id [String] the id of the domain
  # @param namespace [String] the namespace of the domain
  # @param children [Boolean] find all child objects. Defaults to true.
  # @return [SdtmModelDomain] the domain object.
  # def self.find(id, ns, children=true)
  #   uri = UriV3.new(fragment: id, namespace: ns)
  #   super(uri.to_id)
  #   #object = super(id, ns)
  #   #if children
  #   #  children_from_triples(object, object.triples, id)
  #   #end
  #   #return object
  # end

  # Find all model domains.
  #
  # @return [Array] array of objects found
  #def self.all
  #  return IsoManaged.all_by_type(C_RDF_TYPE, C_SCHEMA_NS)
  #end

  # Find all released model domains.
  #
  # @return [Array] An array of objects
  #def self.list
  #  results = super(C_RDF_TYPE, C_SCHEMA_NS)
  #  return results
  #end

	# Build the object from the operational hash and gemnerate the SPARQL.
  #
  # @param [Hash] params the operational hash
  # @param [SdtmModel] model the sdtm model for the references.
  # @param [SparqlUpdateV2] sparql the SPARQL object to add triples to.
  # @return [SdtmModelDomain] The created object. Valid if no errors set.
  # def self.build(params, model, sparql)
  #   cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
  #   params[:managed_item][:scoped_identifier][:namespace] = cdisc_ra.ra_namespace.to_h
  #   params[:managed_item][:registration_state][:registration_authority] = cdisc_ra.to_json
  #   SdtmModelDomain.variable_references(params[:managed_item], model)
  #   object = SdtmModelDomain.from_json(params[:managed_item])
  #   object.from_operation(params[:operation], C_CID_PREFIX, C_INSTANCE_NS, cdisc_ra)
  #   object.adjust_next_version # Versions are assumed, may not be so
  #   object.lastChangeDate = object.creationDate # Make sure we don't set current time.
  #   if object.valid? && object.create_permitted?
  #     object.to_sparql_v2(sparql)
  #   end
  #   return object
  # end

  # To SPARQL
  #
  # @param [SparqlUpdateV2] sparql the SPARQL object
	# @return [UriV2] The URI
  # def to_sparql_v2(sparql)
  #   super(sparql, C_SCHEMA_PREFIX)
  #   subject = {:uri => self.uri}
  #   self.children.each do |child|
  #   	ref_uri = child.to_sparql_v2(self.uri, sparql)
  #   	sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesColumn"}, {:uri => ref_uri})
  #   end
  #   return self.uri
  # end

	# From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmModelDomain] the object created
  # def self.from_json(json)
  #   object = super(json)
  #   json[:children].each { |c| object.children << SdtmModelDomain::Variable.from_json(c) } if !json[:children].blank?
  #   return object
  # end

  # To JSON
  #
  # @return [Hash] the object hash 
  # def to_json
  #   json = super
  #   json[:children] = []
  #   self.children.sort_by! {|u| u.ordinal}
  #   self.children.each do |child|
  #     json[:children] << child.to_json
  #   end
  #   return json
  # end

  # def children_from_triples
  #   self.children = SdtmModelDomain::Variable.find_for_parent(self.triples, self.get_links(C_SCHEMA_PREFIX, "includesColumn"))
  # end

private

	# def self.variable_references(params, model)
	# 	params[:children].each do |child|
	# 		new_child = model.children.find { |c| c.name == child[:variable_name] }
	# 		raise Exceptions::ApplicationLogicError.new(message: "Failed to match variable #{child[:variable_name]} in #{C_CLASS_NAME} object.") if new_child.nil?
	# 		ref = OperationalReferenceV2.new
	# 		ref.subject_ref = new_child.uri
	# 		ref.ordinal = child[:ordinal]
	# 		child[:variable_ref] = ref.to_json
	# 	end
	# end

end
