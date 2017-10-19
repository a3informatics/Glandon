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

=begin
  def self.import(params)
    object = self.new
    object.errors.clear
    if import_params_valid?(params, object)
      # Clean files
      files = params[:files]
      files.reject!(&:blank?)
      # Check to ensure version does not exist
      ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
      if !versionExists?(C_IDENTIFIER, params[:version], ra.namespace)
        job = Background.create
        job.importCdiscSdtmIg(params, files)
      else
        object.errors.add(:base, "The version (#{params[:version]}) has already been created.")
        job = nil
      end
    else
      job = nil
    end
    return { :object => object, :job => job }
  end

  def self.import_sparql(params, sparql, ig_domains, compliance_set)
    # Init data
    object = self.new 
    object.errors.clear
    # Get the Json structure
    data = params[:data]
    operation = data[:operation]
    managed_item = data[:managed_item]
    ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    uri = IsoManaged.create_sparql(C_CID_PREFIX, data, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS, sparql, ra)
    id = uri.id
    namespace = uri.namespace
    # Build the compliance (core) set
    ig_domains.each do |result|
      result[:instance][:managed_item][:children].each do |variable|
        core = variable[:variable_core]
        if !compliance_set.has_key?(core)
          compliance_set[core] = core
        end
      end
    end    
    return { :uri => uri, :object => object }
  end

  def self.add_domain_sparql(uri, ref_uri, ordinal, sparql)
    object = self.new 
    object.errors.clear
    subject = {:uri => uri}
    ref_id = "#{uri.id}#{Uri::C_UID_SECTION_SEPARATOR}TR#{ordinal}" 
    ref_subject ={:namespace => uri.namespace, :id => ref_id}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesTabulation"}, ref_subject)
    sparql.triple(ref_subject, {:prefix => UriManagement::C_RDF, :id => "type"}, {:prefix => UriManagement::C_BO, :id => "TReference"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "hasTabulation"}, {:uri => ref_uri})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "enabled"}, {:literal => "true", :primitive_type => "boolean"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "optional"}, {:literal => "false", :primitive_type => "boolean"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "ordinal"}, {:literal => "#{ordinal}", :primitive_type => "positiveInteger"})
    return { :object => object }
  end
=end

	# NOT TESTED
  # Create a new version. This is an import and runs in the background.
  #
  # @param [Hash] params the parameters
  # @option params [String] :date The release date of the version being created
  # @option params [String] :version The version being created
  # @option params [String] :version_label The label for the version being created
  # @option params [String] :files Array of files being used 
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

  # NOT TESTED
  # Build the object from the operational hash.
  #
  # @param [Hash] params the operational hash
  # @return [SdtmIg] The created object. Valid if no errors set.
  def self.build(params, sparql)
    cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    object = SdtmIg.from_json(params[:managed_item])
    object.add_compliance(params[:managed_item])
    object.update_variables
    object.from_operation(params[:operation], C_CID_PREFIX, C_INSTANCE_NS, cdisc_ra)
    object.lastChangeDate = object.creationDate # Make sure we don't set current time.
    object.valid?
    return object
  end

  # To SPARQL
  #
  # @param [SparqlUpdateV2] sparql the SPARQL object
  # @return [UriV2] The URI
  def to_sparql_v2(sparql)
    uri = super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => uri}
    self.compliance.each { |k, c| c.to_sparql_v2(uri, sparql) }
    self.domain_refs.each do |ref|
    	ref_uri = ref.to_sparql_v2(uri, "includesTabulation", 'TR', ref.ordinal, sparql)
    	sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesTabulation"}, {:uri => ref_uri})
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
    json[:domain_refs] = Array.new
    self.domain_refs.each do |ref|
      json[:domain_refs] << ref.to_json
    end
    return json
  end

  # Add Compliance. Create the datatypes existing within the variables
  #
  # @param [Hash] json the managed item hash
  # @return [void] no return
  def add_compliance(json)
  	return if json[:children].blank?
    json[:children].each do |item|
    	label = item[:compliance][:label]
    	if !self.compliance.has_key?(label)
    		object = SdtmModelCompliance.new
    		object.label = label
      	self.compliance[label] = object
      end
    end
  end

private

  def self.import_params_valid?(params, object)
    result1 = FieldValidation::valid_version?(:version, params[:version], object)
    result2 = FieldValidation::valid_date?(:date, params[:date], object)
    result3 = FieldValidation::valid_files?(:files, params[:files], object)
    result4 = FieldValidation::valid_label?(:version_label, params[:version_label], object)
    return result1 && result2 && result3 && result4
  end

  def self.children_from_triples(object, triples, id, bc=nil)
    object.domain_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesTabulation"))
  end      

end
