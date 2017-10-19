class SdtmIgDomain < Tabular
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  attr_accessor :children, :prefix, :structure, :model_ref

  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_IGD
  C_CLASS_NAME = "SdtmIgDomain"
  C_CID_PREFIX = SdtmIg::C_CID_PREFIX
  C_RDF_TYPE = "IgDomain"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.prefix = SdtmUtility::C_PREFIX
    self.structure = ""
    self.children = Array.new
    self.model_ref = OperationalReferenceV2.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  # Find a given IG domain.
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
    return object
  end

  # Find all the IG domains
  #
  # @return [Array] array of objects found
  def self.all
    return IsoManaged.all_by_type(C_RDF_TYPE, C_SCHEMA_NS)
  end

  # Find all released IG domains
  #
  # @return [Array] An array of objects
  def self.list
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

	# Build the object from the operational hash.
	#
  # @param [Hash] params the operational hash
  # @param [SdtmModel] model the sdtm model for the references.
  # @return [SdtmIgDomain] The created object. Valid if no errors set.
  def self.build(params, model)
    cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    SdtmIgDomain.variable_references(params[:managed_item], model)
    object = SdtmIgDomain.from_json(params[:managed_item])
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
    super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => self.uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "prefix"}, {:literal => "#{self.prefix}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "structure"}, {:literal => "#{self.structure}", :primitive_type => "string"})
    ref_uri = self.model_ref.to_sparql_v2(uri, OperationalReferenceV2::C_PARENT_LINK_DT, 'CLR', 1, sparql)
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => OperationalReferenceV2::C_PARENT_LINK_DT}, {:uri => ref_uri})
		self.children.each do |child|
    	ref_uri = child.to_sparql_v2(self.uri, sparql)
    	sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesColumn"}, {:uri => ref_uri})
    end
    return self.uri
  end

	# From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmIgDomain] the object created
  def self.from_json(json)
    object = super(json)
    object.prefix = json[:prefix]
    object.structure = json[:structure]
    object.model_ref = OperationalReferenceV2.from_json(json[:model_ref])
    json[:children].each { |c| object.children << SdtmIgDomain::Variable.from_json(c) } if !json[:children].blank?
    return object
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:prefix] = self.prefix
    json[:structure] = self.structure
    json[:model_ref] = self.model_ref.to_json
    json[:children] = Array.new
    self.children.each do |child|
      json[:children] << child.to_json
    end
    return json
  end

  # Compliance
  #
  # @return [Array] set of compliances for the domain
  def compliance()
    results = Array.new
    # Build the query. Note the full namespace reference, doesnt seem to work with a default namespace. Needs checking.
    query = UriManagement.buildNs(self.namespace, ["bd", "bo"])  +
      "SELECT DISTINCT ?b ?c WHERE \n" +
      "{ \n " +
      "  :#{self.id} bd:includesColumn ?a . \n " +
      "  ?a bd:compliance ?b . \n" +
      "  ?b rdfs:label ?c . \n" +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('b', true, node)
      label = ModelUtility.getValue('c', false, node)
      if uri != "" && label != ""
        object = SdtmModelCompliance.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.label = label
        results << object
      end
    end
    return results
  end

  # NOT TESTED
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

  def self.children_from_triples(object, triples, id)
    object.children = SdtmIgDomain::Variable.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesColumn"))
    model_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "basedOnDomain"))
    if model_refs.length > 0 
      object.model_ref = model_refs[0]
    end
  end

end
