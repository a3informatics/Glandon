class SdtmIg < Tabular
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :domain_refs, :compliance
  
  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_IG
  C_CLASS_NAME = "SdtmIg"
  C_RDF_TYPE = "ImplementationGuide"
  C_CID_PREFIX = "IG"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_IDENTIFIER = "SDTM IG"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # Class-wide variables
  @@cdiscNamespace = nil # CDISC Organization identifier
  
  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.domain_refs = []
    self.compliance = {}
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  # Find a given IG.
  #
  # @param id [String] the id of the domain
  # @param namespace [String] the namespace of the domain
  # @param children [Boolean] find all child objects. Defaults to true.
  # @return [SdtmIgDomain] the domain object.
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    object.triples = ""
    return object
  end

  # Find all the IGs.
  #
  # @return [Array] array of objects found
  def self.all()
    results = IsoManaged.all_by_type(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  # Find the IG history
  #
  # @return [array] An array of objects.
  def self.history()
    @@cdiscNamespace ||= IsoNamespace.findByShortName("CDISC")
    results = super(C_RDF_TYPE, C_SCHEMA_NS, { :identifier => C_IDENTIFIER, :scope_id => @@cdiscNamespace.id })
    return results
  end

	# Create a new version. This is an import and runs in the background.
  #
  # @param [Hash] params the parameters
  # @option params [String] :date The release date of the version being created
  # @option params [String] :version The version being created
  # @option params [String] :version_label The label for the version being created
  # @option params [String] :files Array of files being used 
  # @option params [String] :model_uri The URI for the SDTM model
  # @return [Hash] A hash containing the object with any errors and the background job reference.
  def self.create(params)
    job = nil
    object = self.new
    if import_params_valid?(params, object)
      params[:files].reject!(&:blank?)
			job = Background.create
  	 	job.import_cdisc_sdtm_ig(params)
    end
    return { :object => object, :job => job }
  end

  # Build the object from a set of operational hash structures and generate the SPARQL.
  #
  # @param [Array] params an array of operational hash structures for the IG and Domains
  # @return [SdtmIg] The created object. Valid if no errors set.
  def self.build(params, sparql)
  	ig_params = params.select { |x| x[:type] == "IG" } # At least one assumed to exist
    cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    object = SdtmIg.from_json(ig_params.first[:instance][:managed_item])
    object.from_operation(ig_params.first[:instance][:operation], C_CID_PREFIX, C_INSTANCE_NS, cdisc_ra)
    build_compliance(object.compliance, params)
    object.lastChangeDate = object.creationDate # Make sure we don't set current time.
    if object.valid? && object.create_permitted?
      object.to_sparql_v2(sparql, false)
    end
  	return object
  end

  # To SPARQL
  #
  # @param [SparqlUpdateV2] sparql the SPARQL object
  # @param [Boolean] refs output the domain references if true, defaults to true
  # @return [UriV2] The subject URI
  def to_sparql_v2(sparql, refs=true)
    super(sparql, C_SCHEMA_PREFIX)
    self.compliance.each { |k, c| c.to_sparql_v2(self.uri, sparql) }
    domain_refs_to_sparql(sparql) if refs
    return self.uri
  end

  # Refs To SPARQL
  #
  # @param [SparqlUpdateV2] sparql the SPARQL object
  # @return [UriV2] The subject URI
  def domain_refs_to_sparql(sparql)
    self.domain_refs.each do |ref|
    	ref_uri = ref.to_sparql_v2(self.uri, "includesTabulation", 'TR', ref.ordinal, sparql)
    	sparql.triple({:uri => self.uri}, {:prefix => C_SCHEMA_PREFIX, :id => "includesTabulation"}, {:uri => ref_uri})
    end
    return self.uri
  end

	# From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmIg] the object created
  def self.from_json(json)
    object = super(json)
    json[:domain_refs].each { |ref| object.domain_refs << OperationalReferenceV2.from_json(ref) } if !json[:domain_refs].blank?
    return object
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:domain_refs] = []
    self.domain_refs.sort_by! {|u| u.ordinal}
    self.domain_refs.each {|ref| json[:domain_refs] << ref.to_json}
    return json
  end

  # Add Domain
  #
  # @param [SdtmIgDomain] domain the domain object
  # @return [void] no return
  def add_domain(domain)
  	ref = OperationalReferenceV2.new
  	ref.subject_ref = domain.uri
  	self.domain_refs << ref
  	ref.ordinal = self.domain_refs.count
  end

private

  # Build Compliance. Create the common compliance objects
  def self.build_compliance(compliances, params)
  	params.each do |item|
  		if item[:type] == "IG_DOMAIN"
  			item[:instance][:managed_item][:children].each do |child|
  	  		label = child[:compliance][:label]
    			if !compliances.has_key?(label)
    				object = SdtmModelCompliance.new
    				object.label = label
      			compliances[label] = object
      		end
      	end
      end
    end
  end

  def self.import_params_valid?(params, object)
    result1 = FieldValidation::valid_version?(:version, params[:version], object)
    result2 = FieldValidation::valid_date?(:date, params[:date], object)
    result3 = FieldValidation::valid_files?(:files, params[:files], object)
    result4 = FieldValidation::valid_label?(:version_label, params[:version_label], object)
    result5 = FieldValidation::valid_uri?(:model_uri, params[:model_uri], object)
    return result1 && result2 && result3 && result4 && result5
  end

  def self.children_from_triples(object, triples, id, bc=nil)
    object.domain_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesTabulation"))
  end      

end
