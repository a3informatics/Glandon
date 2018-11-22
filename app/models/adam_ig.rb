class AdamIg < TabularStandard
  
  # Constants
  C_CLASS_NAME = self.name
  C_SCHEMA_PREFIX = UriManagement::C_BD
  #C_INSTANCE_PREFIX = UriManagement::C_MDR_M
  C_RDF_TYPE = "ImplementationGuide"
  C_CID_PREFIX = "IG"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  #C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_IDENTIFIER = "ADAM IG"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # Class-wide variables
  @@cdiscNamespace = nil # CDISC Organization identifier
  
  C_ADSL_LABEL = "Subject Level Analysis Dataset"
  C_BDS_LABEL = "Basic Data Structure"
  
  C_ADSL_IDENTIFIER = "ADAMMODEL ADSL"
  C_BDS_IDENTIFIER = "ADAMMODEL BDS"

  # Initialize
  #
  # @params [Hash] triples the triples to be used to initialize the object. Can be nil.
  # @params [String] id the id (fragment) of the URI for the object to be initialized.
  # @return [Void] no return.
  def initialize(triples=nil, id=nil)
    super(triples, id)
  end

  # History. Get the item's history
  #
  # @return [array] An array of objects.
  def self.history
    @@cdiscNamespace ||= IsoNamespace.findByShortName("CDISC")
    return super({identifier: C_IDENTIFIER, scope_id: @@cdiscNamespace.id})
  end

  def self.child_klass
    ::AdamIgDataset
  end

  def self.build(params)
    super(params, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  end
  
  # To SPARQL
  #
  # @param [SparqlUpdateV2] sparql the SPARQL object
  # @return [UriV2] The URI
  def to_sparql_v2(sparql)
    uri = super(sparql, C_SCHEMA_PREFIX)
    return self.uri
  end

  # From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmModel] the object created
  def self.from_json(json)
    super(json)
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    super
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
    object.children =  SdtmModel::Variable.find_for_parent(object.triples, object.get_links(C_SCHEMA_PREFIX, "includesVariable"))
    object.class_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesTabulation"))
  end      

end
