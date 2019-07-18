class Thesaurus <  IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Thesaurus",
            uri_suffix: "TH"

  object_property :is_top_concept_reference, cardinality: :many, model_class: "OperationalReferenceV3::TcReference", children: true
  object_property :is_top_concept, cardinality: :many, model_class: "Thesaurus::ManagedConcept", path_exclude: true

  include Thesaurus::Search

  def managed_children_pagination(params)
    super(params) {mcp_query(params)}
  end

  # Changes
  #
  # @param [Integer] window_size the required window size for changes
  # @return [Hash] the changes hash. Consists of a set of versions and the changes for each item and version
  def changes(window_size)
    raw_results = {}
    final_results = {}
    versions = []
    start_index = 0
    first_index = 0

    # Get the version set. Work out if we need a dummy first one.
    items = self.class.history_uris(identifier: self.identifier, scope: self.scope)
    first_index = items.index {|x| x == self.uri}    
    if first_index == 0 
      start_index = 0 
      raw_results["dummy"] = {version: 0, date: "", children: []} if first_index == 0
    else
      start_index = first_index - 1
      raw_results = {}
    end    
    version_set = items[start_index..(first_index + window_size - 1)]

    # Get the raw results
    query_string = %Q{SELECT ?e ?v ?d ?i ?cl ?l ?n WHERE
{
  #{version_set.map{|x| "{ #{x.to_ref} th:isTopConceptReference ?r . #{x.to_ref} isoT:creationDate ?d . #{x.to_ref} isoT:hasIdentifier ?si1 . ?si1 isoI:version ?v . BIND (#{x.to_ref} as ?e)} "}.join(" UNION\n")}
  ?r bo:reference ?cl .
  ?cl isoT:hasIdentifier ?si2 .
  ?cl isoC:label ?l .
  ?cl th:notation ?n .
  ?si2 isoI:identifier ?i .
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
    triples = query_results.by_object_set([:e, :v, :d, :i, :cl, :l, :n])
    triples.each do |entry|
      uri = entry[:e].to_s
      raw_results[uri] = {version: entry[:v].to_i, date: entry[:d].to_time_with_default.strftime("%Y-%m-%d"), children: []} if !raw_results.key?(uri)
      raw_results[uri][:children] << DiffResult[key: entry[:i], uri: entry[:cl], label: entry[:l], notation: entry[:n]]
    end

    # Get the version array
    raw_results.sort_by {|k,v| v[:version]}
    raw_results.each {|k,v| versions << v[:date]}
    versions = versions.drop(1)

    # Build the skeleton final results with a default value.
    initial_status = [{ status: :not_present}] * versions.length
    raw_results.each do |uri, version|
      version[:children].each do |entry|
        key = entry[:key].to_sym
        next if final_results.key?(key)
        final_results[key] = {key: entry[:key], id: entry[:uri].to_id, label: entry[:label] , notation: entry[:notation], status: initial_status.dup}
      end
    end

    # Process the changes
    previous_version = nil
    base_version = raw_results.map{|k,v| v[:version]}[1].to_i
    raw_results.each do |uri, version|
      version_index = version[:version].to_i - base_version
      if previous_version.nil?
        # nothing needed?
      else
        # :created = B-A
        # :updated = A Union B URI != URI
        # :no_change = A Union B URI == URI
        # :deleted = A-B
        new_items = version[:children] - previous_version[:children]
        common_items = version[:children] & previous_version[:children]
        deleted_items = previous_version[:children] - version[:children]
        new_items.each do |entry|
          final_results[entry[:key].to_sym][:status][version_index] = {status: :created}
        end
        common_items.each do |entry|
          prev = previous_version[:children].find{|x| x[:key] == entry[:key]}
          curr = version[:children].find{|x| x[:key] == entry[:key]}
          final_results[entry[:key].to_sym][:status][version_index] = curr.no_change?(prev) ? {status: :no_change} : {status: :updated}
        end
        deleted_items.each do |entry|
          final_results[entry[:key].to_sym][:status][version_index] = {status: :deleted}
        end
      end
      previous_version = version
    end

    # And return
    {versions: versions, items: final_results}
  end

  # Submisison
  #
  # @param [Integer] window_size the required window size for changes
  # @return [Hash] the changes hash. Consists of a set of versions and the changes for each item and version
  def submission(window_size)
    raw_results = {}
    final_results = {}
    versions = []
    start_index = 0
    first_index = 0

    # Get the version set. Work out if we need a dummy first one.
    items = self.class.history(identifier: self.identifier, scope: self.scope)
    first_index = items.index {|x| x.uri == self.uri}    
    if first_index == 0 
      start_index = 0 
      raw_results["dummy"] = {version: 0, date: "", children: []} if first_index == 0
    else
      start_index = first_index - 1
      raw_results = {}
    end    
    version_set = items.map {|e| e.uri}
    version_set = version_set[start_index..(first_index + window_size - 1)]

    items[start_index..(first_index + window_size - 1)].each do |x|
      raw_results[x.uri.to_s] = {version: x.version, date: "#{x.creation_date}".to_time_with_default.strftime("%Y-%m-%d"), children: []}
    end

    # Query
    parts = []
    version_set.each_with_index do |x, index| 
      next if index == 0
      parts << %Q{
{
  { #{x.to_ref} (th:isTopConceptReference/bo:reference/th:narrower) ?p } MINUS
  { #{version_set[index-1].to_ref} (th:isTopConceptReference/bo:reference/th:narrower) ?p }
  ?p th:identifier ?ci . 
  ?p (th:preferredTerm/isoC:label) ?l . 
  ?cl th:narrower ?p . 
  ?cl th:identifier ?pi .
  #{version_set[index-1].to_ref} (th:isTopConceptReference/bo:reference/th:narrower) ?x . 
  ?x th:identifier ?ci . 
  ?cl2 th:narrower ?x . 
  ?cl2 th:identifier ?pi .
  ?p th:notation ?n . 
  ?x th:notation ?pn . 
  FILTER (?pn != ?n)
  BIND (#{x.to_ref} as ?e)
} 
      }    
    end
    query_string = %Q{
SELECT ?e ?pi ?cl ?n ?pn ?ci ?l WHERE
{
  { #{parts.join(" UNION\n")} }
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
    triples = query_results.by_object_set([:e, :pi, :cl, :l, :n, :pn, :ci])
    triples.each do |entry|
      uri = entry[:e].to_s
      raw_results[uri][:children] << DiffResultSubmission[key: "#{entry[:pi]}.#{entry[:ci]}", uri: entry[:cl], label: entry[:l], notation: entry[:n], previous: entry[:pn], identifier: entry[:i2]]
    end

    # Get the version array
    raw_results.sort_by {|k,v| v[:version]}
    raw_results.each {|k,v| versions << v[:date]}
    versions = versions.drop(1)

    # Build the skeleton final results with a default value.
    initial_status = [{ status: :no_change, notation: "", previous: ""}] * versions.length
    raw_results.each do |uri, version|
      version[:children].each do |entry|
        key = entry[:key].to_sym
        next if final_results.key?(key)
        final_results[key] = {key: entry[:key], label: entry[:label] , notation: entry[:notation], identifier: entry[:identifier], status: initial_status.dup}
      end
    end

    # Process the changes
    previous_version = nil
    base_version = raw_results.map{|k,v| v[:version]}[1].to_i
    raw_results.each do |uri, version|
      version_index = version[:version].to_i - base_version
      if !previous_version.nil?
        version[:children].each do |entry|
          final_results[entry[:key].to_sym][:status][version_index] = {status: :updated, notation: entry[:notation], previous: entry[:previous]}
        end
      end
      previous_version = version
    end

    # And return
    {versions: versions, items: final_results}
  end

private

  class DiffResult < Hash

    def no_change?(other_hash)
      self[:uri] == other_hash[:uri]
    end

    def eql?(other_hash)
      self[:key] == other_hash[:key]
    end

    def hash
      self[:key].hash
    end

  end

  class DiffResultSubmission < Hash

    def no_change?(other_hash)
      self[:uri] == other_hash[:uri] && self[:notation] == other_hash[:notation]
    end

    def eql?(other_hash)
      self[:key] == other_hash[:key]
    end

    def hash
      self[:key].hash
    end

  end

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