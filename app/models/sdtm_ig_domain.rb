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
  # @return [SdtmModelDomain] the domain object.
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
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  # Find all released IG domains
  #
  # @return [Array] An array of objects
  def self.list
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.import_sparql(params, sparql, compliance_set, class_map)
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
    # Set the map
    map = class_map[managed_item[:domain_class]]
    # Set the properties
    subject = {:uri => uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "prefix"}, {:literal => "#{managed_item[:prefix]}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "structure"}, {:literal => "#{managed_item[:structure]}", :primitive_type => "string"})
    # Build the class reference
    if !map.nil? 
      ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'CLR'
      subject_ref = {:namespace => namespace, :id => ref_id}
      ref_uri = class_map[managed_item[:domain_class]][:uri]
      sparql.triple(subject, {:prefix => UriManagement::C_BD, :id => "basedOnDomain"}, subject_ref)
      sparql.triple(subject_ref, {:prefix => UriManagement::C_RDF, :id => "type"}, {:prefix => UriManagement::C_BO, :id => "TReference"})
      sparql.triple(subject_ref, {:prefix => UriManagement::C_BO, :id => "hasTabulation"}, {:uri => ref_uri})
      sparql.triple(subject_ref, {:prefix => UriManagement::C_BO, :id => "enabled"}, {:literal => "true", :primitive_type => "boolean"})
      sparql.triple(subject_ref, {:prefix => UriManagement::C_BO, :id => "optional"}, {:literal => "false", :primitive_type => "boolean"})
      sparql.triple(subject_ref, {:prefix => UriManagement::C_BO, :id => "ordinal"}, {:literal => "1", :primitive_type => "positiveInteger"})
    end
    # Build the compliance (core) triples
    compliance_map = Hash.new
    compliance_set.each do |key, core|
      ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'C' + Uri::C_UID_SECTION_SEPARATOR + core.upcase.gsub(/\s+/, "")
      compliance_map[core] = UriV2.new({:namespace => namespace, :id => ref_id})
    end
    compliance_map.each do |core, uri|
      label = compliance_set[core] # Slightly odd but needed. TODO, something to do with frozen strings.
      IsoConcept.import_sparql(uri.namespace, uri.id, sparql, C_SCHEMA_PREFIX, "VariableCompliance", label)
    end
    # Now deal with the children
    if !managed_item[:children].blank?
      managed_item[:children].each do |item|
        if !map.nil?
          ref_id = SdtmIgDomain::Variable.import_sparql(namespace, id, sparql, item, compliance_map, map[:children])
        else
          ref_id = SdtmIgDomain::Variable.import_sparql(namespace, id, sparql, item, compliance_map, nil)
        end
        sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesColumn"}, {:namespace => namespace, :id => ref_id})
      end
    end
    return { :uri => uri, :map => map, :object => object }
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

private

  def self.children_from_triples(object, triples, id)
    object.children = SdtmIgDomain::Variable.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesColumn"))
    model_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "basedOnDomain"))
    if model_refs.length > 0 
      object.model_ref = model_refs[0]
    end
  end

end
