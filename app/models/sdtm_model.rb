class SdtmModel < Tabular
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :children, :class_refs, :datatypes, :classifications
  
  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_M
  C_CLASS_NAME = "SdtmModel"
  C_RDF_TYPE = "Model"
  C_CID_PREFIX = "M"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_IDENTIFIER = "SDTM MODEL"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # Class-wide variables
  @@cdiscNamespace = nil # CDISC Organization identifier
  
  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.children = []
    self.class_refs = []
    self.datatypes = {}
    self.classifications = {}
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  # Find a given models.
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
    object.triples = ""
    return object
  end

  # Find all the models
  #
  # @return [Array] array of objects found
  def self.all()
    results = IsoManaged.all_by_type(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  # Find all the released models
  #
  # @return [Array] An array of objects
  def self.list
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  # Find the Model history
  #
  # @return [array] An array of objects.
  def self.history()
    @@cdiscNamespace ||= IsoNamespace.findByShortName("CDISC")
    results = super(C_RDF_TYPE, C_SCHEMA_NS, { :identifier => C_IDENTIFIER, :scope_id => @@cdiscNamespace.id })
    return results
  end

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
  	 	job.import_cdisc_sdtm_model(params)
    end
    return { :object => object, :job => job }
  end

  # Valididate and SPARQL. Build the object from the operational hash validate and 
	# generate the SPARQL if valid and object can be created.
  #
  # @param [Hash] params the operational hash
  # @param [SparqlUpdateV2] sparql the SPARQL object to add triples to.
  # @return [SdtmModel] The created object. Valid if no errors set.
  def self.build_and_sparql(params, sparql)
    cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    object = SdtmModel.from_json(params[:managed_item])
    object.add_datatypes(params[:managed_item])
    object.add_classifications(params[:managed_item])
    object.update_variables
    object.from_operation(params[:operation], C_CID_PREFIX, C_INSTANCE_NS, cdisc_ra)
    object.lastChangeDate = object.creationDate # Make sure we don't set current time.
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
  # @return [UriV2] The URI
  def to_sparql_v2(sparql)
    uri = super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => uri}
    self.datatypes.each { |k, dt| dt.to_sparql_v2(uri, sparql) }
    self.classifications.each { |k, c| c.to_sparql_v2(uri, sparql) }
    self.children.each do |child|
    	ref_uri = child.to_sparql_v2(uri, sparql)
    	sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesColumn"}, {:uri => ref_uri})
    end
    self.class_refs.each do |ref|
    	ref_uri = ref.to_sparql_v2(uri, "includesTabulation", 'TR', ref.ordinal, sparql)
    	sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesTabulation"}, {:uri => ref_uri})
    end
    return self.uri
  end

	# From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmModel] the object created
  def self.from_json(json)
    object = super(json)
    json[:children].each { |c| object.children << SdtmModel::Variable.from_json(c) } if !json[:children].blank?
    json[:class_refs].each { |ref| object.class_refs << OperationalReferenceV2.from_json(ref) } if !json[:class_refs].blank?
    return object
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:children] = []
    json[:class_refs] = []
    self.children.each { |c| json[:children] << c.to_json }
    self.class_refs.each { |ref| json[:class_refs] << ref.to_json }
    return json
  end

  # Add Datatypes. Create the datatypes existing within the variables
  #
  # @param [Hash] json the managed item hash
  # @return [void] no return
  def add_datatypes(json)
  	return if json[:children].blank?
    json[:children].each do |item|
    	label = item[:datatype][:label]
    	if !self.datatypes.has_key?(label)
    		object = SdtmModelDatatype.new
    		object.label = label
      	self.datatypes[label] = object
      end
    end
  end

  # Add Classifications. Create the classifcations existing within the variables
  #
  # @param [Hash] json the managed item hash
  # @return [void] no return
  def add_classifications(json)
  	return if json[:children].blank?
    add_classification(SdtmModel::Variable::C_ROLE_NONE, SdtmModel::Variable::C_ROLE_Q_NA)
    json[:children].each { |c| add_classification(c[:classification][:label], c[:sub_classification][:label]) }
  end
 
  # Update Variables. Update the variables with common references
  #
  # @return [void] no return
 	def update_variables
 		self.children.each do |child|
 			child.update_datatype(self.datatypes)
 			child.update_classification(self.classifications)
 		end
 	end

private

	def add_classification(classification, sub_classification)
		if !self.classifications.has_key?(classification)
			object = SdtmModelClassification.new
			object.label = classification
			object.set_parent
			self.classifications[classification] = object
		end
		if !self.classifications.has_key?(sub_classification) && sub_classification != SdtmModel::Variable::C_ROLE_Q_NA
			parent = self.classifications[classification] 
			object = SdtmModelClassification.new
			object.label = sub_classification
			parent.add_child(object)
			self.classifications[sub_classification] = object
		end        
	end

  def self.import_params_valid?(params, object)
    result1 = FieldValidation::valid_version?(:version, params[:version], object)
    result2 = FieldValidation::valid_date?(:date, params[:date], object)
    result3 = FieldValidation::valid_files?(:files, params[:files], object)
    result4 = FieldValidation::valid_label?(:version_label, params[:version_label], object)
    return result1 && result2 && result3 && result4
  end

  #def self.create_params_valid?(params, object)
  #  result1 = FieldValidation::valid_identifier?(:version, params[:identifier], object)
  #  result2 = FieldValidation::valid_label?(:label, params[:label], object)
  #  return result1 && result2 
  #end

  def self.children_from_triples(object, triples, id, bc=nil)
    object.children =  SdtmModel::Variable.find_for_parent(object.triples, object.get_links(C_SCHEMA_PREFIX, "includesVariable"))
    object.class_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesTabulation"))
  end      

end
