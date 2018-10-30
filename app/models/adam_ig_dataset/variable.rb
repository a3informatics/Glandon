class AdamIgDataset::Variable < Tabular::Column
  
  # Attributes
  attr_accessor :name, :notes, :ct, :ct_notes, :compliance

  # Constants
  C_CLASS_NAME = self.name
  C_SCHEMA_PREFIX = AdamIgDataset::C_SCHEMA_PREFIX
  C_INSTANCE_PREFIX = AdamIgDataset::C_INSTANCE_PREFIX
  C_CID_PREFIX = SdtmIg::C_CID_PREFIX
  C_RDF_TYPE = "IgVariable"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.name = ""
    self.notes = ""
    self.ct = ""
    self.ct_notes = ""
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  # Compliance Label
  #
  # @return [String] the label, set blank if none exists
  def compliance_label
    return compliance.nil? ? "" : compliance.label
  end

  # Determines if CT present in the CT/Format field
  #
  # @return [Boolean] true if a CT reference is present
  def ct?
    return !self.ct.empty?
  end

  # Find an item
  #
  # @params id [String] the id of the item to be found.
  # @params namespace [String] the namespace of the item to be found.
  # @raise [NotFoundError] if the object is not found.
  # @return [AdamIgDataset::Variable] the object found.
  def self.find(id, ns, children=true)
    object = super(id, ns)
    children_from_triples(object, object.triples, id) if children
    return object
  end

  # To SPARQL
  #
  # @param [UriV2] parent_uri the parent URI
	# @param [SparqlUpdateV2] sparql the SPARQL object
	# @return [UriV2] The URI
  def to_sparql_v2(parent_uri, sparql)
    self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{SdtmUtility.replace_prefix(self.name)}"
    self.namespace = parent_uri.namespace
    super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => self.uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "name"}, {:literal => "#{self.name}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "controlled_term_or_format"}, {:literal => "#{self.controlled_term_or_format}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "notes"}, {:literal => "#{self.notes}", :primitive_type => "string"})
		sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "compliance"}, {:uri => self.compliance.uri})
		ref_uri = self.variable_ref.to_sparql_v2(self.uri, OperationalReferenceV2::C_PARENT_LINK_VC, 'VR', 1, sparql)
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => OperationalReferenceV2::C_PARENT_LINK_VC}, {:uri => ref_uri})
    return self.uri
  end

  # To JSON
  #
  # @return [Hash] the object hash.
  def to_json
    json = super
    json[:name] = self.name
    #json[:ordinal] = self.ordinal
    json[:notes] = self.notes
    json[:ct] = self.ct
    json[:ct_notes] = self.ct_notes
    json[:compliance] = self.compliance.to_json
    return json
  end

  alias to_hash to_json
  
  # From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmModel::Variable] the object created
  def self.from_json(json)
    object = super(json)
    object.name = json[:name]
    object.notes = json[:notes]
    object.ct = json[:ct]
    object.ct_notes = json[:ct_notes]
    object.compliance = SdtmModelCompliance.from_json(json[:compliance])
    return object
  rescue => e
  	#byebug
  	return object
  end

  # Update Compliance. Amend the reference. Done so references are made common
  #
  # @raise [Exceptions::ApplicationLogicError] if compliance label not present in compliances
  # @param [Hash] compliances a hash of compliances index by the datatype (label)
  # @return [void] no return
  def update_compliance(compliances)
  	if compliances.has_key?(self.compliance.label)
  		self.compliance = compliances[self.compliance.label] 
  	else
  		raise Exceptions::ApplicationLogicError.new(message: "Compliance #{self.compliance.label} not found. Variable #{self.name} in #{C_CLASS_NAME} object.")
  	end
  end
  
  def additional_properties
    [ 
      { instance_variable: "compliance", label: "Compliance", value: self.compliance.label }
    ]
  end

private

  def self.children_from_triples(object, triples, id)
    links = object.get_links_v2(C_SCHEMA_PREFIX, "compliance")
    if links.length > 0
      object.compliance = SdtmModelCompliance.find(links[0].id, links[0].namespace)
    end
  end

end
