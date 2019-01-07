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

  # Get the next version
  #
  # @return [integet] the integer version
  def self.next_version
    return super(C_IDENTIFIER, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  end

  def self.child_klass
    ::AdamIgDataset
  end

  def self.build(params)
    super(params, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  end
  
  # To SPARQL
  #
  # @return [UriV2] The URI
  def to_sparql_v2
    sparql = SparqlUpdateV2.new
    super(sparql, C_SCHEMA_PREFIX)
    return sparql
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

  def children_from_triples
    self.references = OperationalReferenceV2.find_for_parent(self.triples, self.get_links(C_SCHEMA_PREFIX, "includesTabulation"))
  end      

end
