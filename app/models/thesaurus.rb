class Thesaurus <  IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Thesaurus",
            uri_suffix: "TH"

  object_property :is_top_concept_reference, cardinality: :many, model_class: "OperationalReferenceV3::TcReference", children: true
  object_property :is_top_concept, cardinality: :many, model_class: "Thesaurus::ManagedConcept", path_exclude: true

  include Thesaurus::Search

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
    items = self.class.history_uris(identifier: self.scoped_identifier, scope: self.scope).reverse 
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
    items = self.class.history(identifier: self.scoped_identifier, scope: self.scope).reverse
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
    triples = []
    version_set.each_with_index do |x, index| 
      next if index == 0
    query_string = %Q{
SELECT ?e ?ccl ?cid ?cl ?ci ?cn ?pn WHERE
{ 
  { #{x.to_ref} (th:isTopConceptReference/bo:reference/th:narrower) ?ccl } MINUS   
  { #{version_set[index-1].to_ref} (th:isTopConceptReference/bo:reference/th:narrower) ?ccl } 
  BIND (STRAFTER(str(?ccl), '#') AS ?cid) .           
  FILTER (?pid = ?cid)
  ?ccl th:notation ?cn . 
  FILTER (?pn != ?cn)
  ?ccl isoC:label ?cl . 
  ?ccl th:identifier ?ci . 
  BIND (#{x.to_ref} AS ?e) .          
  {
    SELECT ?pcl ?pid ?pn WHERE 
    {
      { #{version_set[index-1].to_ref} (th:isTopConceptReference/bo:reference/th:narrower) ?pcl } MINUS   
      { #{x.to_ref} (th:isTopConceptReference/bo:reference/th:narrower) ?pcl } 
      BIND (STRAFTER(str(?pcl), '#') AS ?pid) .           
      ?pcl th:notation ?pn .
    }
  }
}}
      query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC])
      triples += query_results.by_object_set([:e, :ccl, :cid, :cl, :ci, :cn, :pn])
    end
    triples.each do |entry|
      uri = entry[:e].to_s
      raw_results[uri][:children] << {key: entry[:cid], uri: entry[:ccl], label: entry[:cl], notation: entry[:cn], previous: entry[:pn], identifier: entry[:ci]}
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

  def managed_children_pagination(params)
    results =[]
    count = params[:count].to_i
    offset = params[:offset].to_i

    # Get the URIs for each child
    query_string = %Q{SELECT ?e WHERE
{
  #{self.uri.to_ref} th:isTopConceptReference ?r . 
  ?r bo:reference ?e .
  ?r bo:ordinal ?v
} ORDER BY (?v) LIMIT #{count} OFFSET #{offset} 
}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo])
    uris = query_results.by_object_set([:e]).map{|x| x[:e]}

    # Get the final result
    query_string = %Q{
SELECT DISTINCT ?i ?n ?d ?pt ?e (GROUP_CONCAT(DISTINCT ?sy;separator=\" \") as ?sys) ?s WHERE\n
{        
  VALUES ?s { #{uris.map{|x| x.to_ref}.join(" ")} }
  {
    ?s th:identifier ?i .
    ?s th:notation ?n .
    ?s th:definition ?d .
    ?s th:extensible ?e .
    ?s th:preferredTerm/isoC:label ?pt .
    OPTIONAL {?s th:synonym/isoC:label ?sy .}
  }
} GROUP BY ?i ?n ?d ?pt ?e ?s ORDER BY ?i
}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC])
    query_results.by_object_set([:i, :n, :d, :e, :pt, :sys, :s]).each do |x|
      results << {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], extensible: x[:e].to_bool, definition: x[:d], id: x[:s].to_id}
    end
    results
  end

  # Add Child. Adds a child item that is itself managed
  #
  # @params [Hash] params 
  # @option params [String] :identifier the identifer
  # @return [Object] the created object. May contain errors if unsuccesful.
  def add_child(params)
    child = Thesaurus::ManagedConcept.empty_concept
    child[:identifier] = Thesaurus::ManagedConcept.generated_identifier? ? Thesaurus::ManagedConcept.new_identifier : params[:identifier]
    ordinal = next_ordinal(:is_top_concept_reference)
    transaction_begin
    child = Thesaurus::ManagedConcept.create(child)
    return child if child.errors.any?
    ref = OperationalReferenceV3::TcReference.create({reference: child, ordinal: ordinal}, self)
    self.add_link(:is_top_concept, child)
    self.add_link(:is_top_concept_reference, ref)
    transaction_execute
    child
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

end