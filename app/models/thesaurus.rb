class Thesaurus <  IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Thesaurus",
            uri_suffix: "TH"

  object_property :is_top_concept_reference, cardinality: :many, model_class: "OperationalReferenceV3::TcReference", children: true
  object_property :is_top_concept, cardinality: :many, model_class: "Thesaurus::ManagedConcept", path_exclude: true

  include Thesaurus::Search

  def managed_children_pagination(params)
    super(params) {mcp_query(params)}
  end

private

  # Standard managed children pagination query
  def mcp_query(params)
    count = params[:count].to_i
    offset = params[:offset].to_i
    refs = is_top_concept_reference.sort_by{|x| x.ordinal}[offset..(offset+count-1)]
    uris = refs.map{|x| x.reference.uri.to_ref}.join(" ")
    predicates = refs[0].class.referenced_klass.properties_metadata_class.property_relationships.map{|x| x[:predicate].to_ref}.join("|")

    # Return query string
    %Q{SELECT DISTINCT ?s ?p ?o ?e WHERE
{
  VALUES ?e { #{uris} }
  {
    { ?e (#{predicates}) ?o . ?e ?p ?o . BIND (?e as ?s) } UNION
    { ?e th:synonym ?o . BIND (?e as ?s) . BIND (th:synonym as ?p) } UNION
    { ?e th:synonym ?s . ?s ?p ?o } UNION
    { ?e th:preferredTerm ?o . BIND (?e as ?s) . BIND (th:preferredTerm as ?p) } UNION
    { ?e th:preferredTerm ?s . ?s ?p ?o }
  }
} 
}
  end

=begin
  # Find From Concept. Finds the Thesaurus form a child irrespective of depth in the tree.
  #
  # @param id [string] The id of the form.
  # @param namespace [hash] The raw triples keyed by id.
  # @return [object] The thesaurus object.
  def self.find_from_concept(id, ns)
    result = self.new
    query = UriManagement.buildNs(ns, ["iso25964"]) +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a (iso25964:hasConcept|iso25964:hasChild)%2B :" + id + " . \n" +   
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      result = self.find(ModelUtility.extractCid(uri), ModelUtility.extractNs(uri), false)
    end
    return result
  end

  # Create Simple
  #
  # @param params
  def self.create_simple(params)
    object = self.new 
    object.scopedIdentifier.identifier = params[:identifier]
    object.label = params[:label]
    object = Thesaurus.create(object.to_operation)
    return object
  end
  
  # Create 
  #
  # @param params [hash] {data:} The operational hash
  # @return [oject] The form object. Valid if no errors set.
  def self.create(params)
    operation = params[:operation]
    managed_item = params[:managed_item]
    object = Thesaurus.from_json(managed_item)
    object.from_operation(operation, C_CID_PREFIX, C_INSTANCE_NS, IsoRegistrationAuthority.owner)
    if object.valid? then
      if object.create_permitted?
        sparql = object.to_sparql_v2
        response = CRUD.update(sparql.to_s)
        if !response.success?
          object.errors.add(:base, "The Thesaurus was not created in the database.")
        end
      end
    end
    return object
  end

  # Add a child concept
  #
  # @todo This should probably be in ThesaurusConcept?
  # @params params [hash] The params hash containig the concept data {:label, :notation. :preferredTerm, :synonym, :definition, :identifier}
  # @return [object] The object created. Errors set if create failed.
  def add_child(params)
    object = ThesaurusConcept.from_json(params)
    object.identifier = "#{object.identifier}"
    if !object.exists?
      if object.valid?
        sparql = SparqlUpdateV2.new
        object.to_sparql_v2(self.uri, sparql)
        sparql.triple({:uri => self.uri}, {:prefix => UriManagement::C_ISO_25964, :id => "hasConcept"}, {:uri => object.uri})
        response = CRUD.update(sparql.to_s)
        if !response.success?
          object.errors.add(:base, "The Thesaurus Concept, identifier #{object.identifier}, was not created in the database.")
          raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
        end
      end
    else
      object.errors.add(:base, "The Thesaurus Concept, identifier #{object.identifier}, already exists in the database.")
    end
    return object
  end

  # TODO: This needs looking at. used by CdiscTerm
  def self.import(params, ownerNamespace)
    object = super(C_CID_PREFIX, params, ownerNamespace, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS)
    return object
  end
=end

  # Search. The new version. Searches either the specified version or all current versions.
  # 
  # @param params [Hash]  the hash sent by datatables for a search. If namespace is empty then the 
  #                       current versions of terminolgy are searched.
  # @return [Hash]  a hash containing :count wiht the number of records that could be returned and
  #                 :items which is an array of results.
  def self.search(params)
    results = []
    variable = getOrderVariable(params[:order]["0"][:column])
    order = getOrdering(params[:order]["0"][:dir])
    if params[:namespace].blank?
      uri_set = [] #IsoManaged.current_set(C_RDF_TYPE, C_SCHEMA_NS)
    else
      uri_set = []
      uri_set << self.uri
    end
    query = UriManagement.buildNs(self.rdf_type.namespace, ["iso25964", "isoR"])
    query += query_string(params[:search], params[:columns], uri_set)
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    count = xmlDoc.xpath("//result").length
    query += " ORDER BY #{order} (#{variable}) OFFSET #{params[:start]} LIMIT #{params[:length]}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      process_node(node, results)
    end
    return { count: count, items: results }
  end
 
  # Empty Search? No search parameters
  # 
  # @param params [Hash]  the hash sent by datatables for a search.
  # @return [Boolean] true if empty, otherwise false
  def self.empty_search?(params)
    params[:columns].each {|key, column| return false if !column[:search][:value].blank?}
    return false if !params[:search][:value].blank?
    return true
  end

=begin

  # Impact. Determine what impact this version has.
  # 
  # @return [Array] of thesaurus concepts that have an impact
  def impact()
  	results = []
  	query = UriManagement.buildNs(UriManagement.getNs(UriManagement::C_BO), [UriManagement::C_ISO_25964, UriManagement::C_ISO_I, UriManagement::C_ISO_T])
  	query += %Q{
  		SELECT DISTINCT ?ctc WHERE    
			{     
			  {
			  	?a rdf:type :TcReference .
				  ?a :hasThesaurusConcept ?ctc .
				  ?ctc iso25964:identifier ?i .
				  ?ctc_p iso25964:hasChild ?ctc .
				  ?ctc_p iso25964:identifier ?i_p .
				  ?ntc iso25964:identifier ?i .
				  FILTER(CONTAINS(STR(?ntc), "#{self.namespace}"))
          ?ntc_p iso25964:hasChild ?ntc .
				  ?ntc_p iso25964:identifier ?i_p .
				  ?ctc_t (iso25964:hasConcept|iso25964:hasChild)%2B ?ctc .
				  ?ctc_t isoT:hasIdentifier ?csi .
				  ?csi isoI:version ?cv .
				  ?ntc_t (iso25964:hasConcept|iso25964:hasChild)%2B ?ntc .
				  ?ntc_t isoT:hasIdentifier ?nsi .
				  ?nsi isoI:version ?nv .
				  FILTER(?nv > ?cv)
	  			?ntc iso25964:notation ?ntc_n .
				  ?ctc iso25964:notation ?ctc_n .
				  ?ntc iso25964:definition ?ntc_d .
				  ?ctc iso25964:definition ?ctc_d .
				  ?ntc iso25964:preferredTerm ?ntc_pt .
				  ?ctc iso25964:preferredTerm ?ctc_pt .
				  ?ntc iso25964:synonym ?ntc_s .
				  ?ctc iso25964:synonym ?ctc_s .
				  ?ntc rdfs:label ?ntc_l .
				  ?ctc rdfs:label ?ctc_l .
				  FILTER(?ntc_n != ?ctc_n || ?ntc_d != ?ctc_d || ?ntc_pt != ?ctc_pt || ?ntc_s != ?ctc_s || ?ntc_l != ?ctc_l)
				} UNION {
			    ?a rdf:type :TcReference . 			  
			    ?a :hasThesaurusConcept ?ctc . 			  
			    ?ctc iso25964:identifier ?i . 			  
			    ?ctc_p iso25964:hasChild ?ctc . 			  
			    ?ctc_p iso25964:identifier ?i_p . 
			    ?ctc_t (iso25964:hasConcept|iso25964:hasChild)%2B ?ctc .
			    ?ctc_t isoI:hasIdentifier ?csi .
			    ?csi isoI:identifier ?ci .
			    FILTER (?ci = "#{self.identifier}")
			    FILTER NOT EXISTS 
			    {
			      #{self.uri.to_ref} iso25964:hasConcept+ ?ntc_p .
			    	?ntc_p iso25964:identifier ?i_p . 			  
            ?ntc_p iso25964:hasChild ?ntc .
			    	?ntc iso25964:identifier ?i . 			  
			    } 
			  }
			}
		}
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      results << UriV2.new({:uri => ModelUtility.getValue('ctc', true, node)}).to_s
    end
    return results
  end
=end

end