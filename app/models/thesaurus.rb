# Thesaurus. Class for an entire thesaurus
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus <  IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Thesaurus",
            uri_suffix: "TH"

  object_property :is_top_concept_reference, cardinality: :many, model_class: "OperationalReferenceV3::TmcReference", children: true
  object_property :is_top_concept, cardinality: :many, model_class: "Thesaurus::ManagedConcept", delete_exclude: true, read_exclude: true
  object_property :reference, cardinality: :one, model_class: "OperationalReferenceV3", delete_exclude: true, read_exclude: true

  include Thesaurus::Search
  include Thesaurus::Where

  def add(item, ordinal)
    ref = OperationalReferenceV3::TcReference.new(ordinal: ordinal, reference: item.uri)
    ref.uri = ref.create_uri(self.uri)
    self.is_top_concept_reference << ref
    self.is_top_concept << item.uri
  end

  # Where Full. Full where search of the managed item. Will find within children via paths that are not excluded.
  #
  # @return [Array] Array of URIs
  def current_set_where(params)
    where_parts = []
    params.each do |predicate, value|
      where_parts << "?s #{predicate} \"#{value}\""
    end
    where_clause = where_parts.join(" .\n")
    parts = []
    parts << "{ BIND (#{self.uri.to_ref} as ?s) . #{where_clause} }"
    self.class.read_paths.each {|p| parts << "{ #{self.uri.to_ref} (#{p})+ ?o1 . BIND (?o1 as ?s) . #{where_clause} }" }
    query_string = "SELECT DISTINCT ?s WHERE {{ #{parts.join(" UNION\n")} }}"
    query_results = Sparql::Query.new.query(query_string, uri.namespace, [])
    query_results.by_object(:s)
  end

  # Find By Identifier
  def find_by_identifiers(identifiers)
    results = {}
    parts = []
    base_identifier = identifiers.first
    identifiers.drop(1)
    parts[0] = %Q{
      {
        #{self.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
        ?s th:identifier "#{base_identifier}" .
        BIND ("#{base_identifier}" as ?i)
      }}
    identifiers.each do |identifier|
      parts << %Q{
        {
          #{self.uri.to_ref} th:isTopConceptReference/bo:reference ?b .
          ?b th:identifier "#{base_identifier}" .
          ?b th:narrower+ ?s .
          ?s th:identifier "#{identifier}" .
          BIND ("#{identifier}" as ?i)
        }}
    end
    query_string = %Q{SELECT ?s ?i WHERE { #{parts.join("UNION")} }}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo])
    triples = query_results.by_object_set([:i, :s])
    triples.each do |entry|
      results[entry[:i]] = entry[:s]
    end
    results
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
        final_results[key] = {key: entry[:key], id: entry[:uri].to_id, identifier: entry[:key], label: entry[:label] , notation: entry[:notation], status: initial_status.dup}
      end
    end
    # Process the changes
    previous_version = nil
    first_version = nil
    base_version = raw_results.map{|k,v| v[:version]}[1].to_i
    raw_results.each do |uri, version|
      version_index = version[:version].to_i - base_version
      if !previous_version.nil?
        new_items = version[:children] - previous_version[:children]
        common_items = version[:children] & previous_version[:children]
        deleted_items = previous_version[:children] - version[:children]

        new_items.each do |entry|
          final_results[entry[:key].to_sym][:status][version_index] = {status: :created}
          final_results[entry[:key].to_sym][:last_id] = ""
        end
        common_items.each do |entry|
          prev = previous_version[:children].find{|x| x[:key] == entry[:key]}
          curr = version[:children].find{|x| x[:key] == entry[:key]}
          final_results[entry[:key].to_sym][:status][version_index] = curr.no_change?(prev) ? {status: :no_change} : {status: :updated}
          final_results[entry[:key].to_sym][:last_id] = ""
        end
        deleted_items.each do |entry|
          final_results[entry[:key].to_sym][:status][version_index] = {status: :deleted}
          final_results[entry[:key].to_sym][:last_id] = ""
        end
      end
      # Remember reference to the first version
      if version_index == 0
        first_version = version
      end
      # When on last version, find common items existing in the first version and store ids
      if version_index == window_size - 1
        common_items_endpoints = version[:children] & first_version[:children]
        common_items_endpoints.each do |entry|
           final_results[entry[:key].to_sym][:last_id] = entry[:uri].to_id # Store id of the last ref
           final_results[entry[:key].to_sym][:id] = (first_version[:children].detect { |e| e[:key]==entry[:key] })[:uri].to_id # Get and store id of the first ref
        end
      end

      previous_version = version
    end

    # Remove blank entries (those with no changes)
    no_change_entry = [{status: :no_change}] * versions.length
    final_results.delete_if {|k,v| v[:status] == no_change_entry}
    # And return
    {versions: versions, items: final_results}
  end

  # Changes_CDU
  #
  # @param [Integer] window_size the required window size for changes
  # @return [Hash] the changes hash. Consists of the created, deleted and updated changes for the versions,
  # and an array of the versions selected by the user (first and last)
  def changes_cdu (window_size)
    cls = changes(window_size)
    # Remove any entries with :deleted followed by :not_present • n
    first_delete_entry = [{status: :deleted}] + [{status: :not_present}] * (window_size - 1)
    cls[:items].delete_if {|k,v| v[:status] == first_delete_entry }
    # Remove any entries with :updated followed by :no_change • n
    no_change_entry = [{status: :updated}] + [{status: :no_change}] * (window_size - 1)
    cls[:items].delete_if {|k,v| v[:status] == no_change_entry }
    # Now summarise
    results = {created: [], deleted: [], updated: [], versions:[]}
    cls[:items].each do |key, value|
      value[:status].each do |status|
        next if status[:status] == :no_change
        next if status[:status] == :not_present
        if status[:status] == :deleted
            value[:overall_status] = :deleted
            break
        end
        if status[:status] == :created
            value[:overall_status] = :created
        end
        if status[:status] == :updated
          if value[:overall_status].blank?
            value[:overall_status] = :updated
          end
        end
      end
    end
    cls[:items].each do |key, value|
      results[value[:overall_status]]<< {identifier: key, label: value[:label], notation: value[:notation], id: value[:id], last_id: value[:last_id]}
    end
    results[:versions] = cls[:versions]
    results
  end


  # Submission
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
SELECT ?e ?ccl ?cid ?cl ?ci ?cn ?pn ?pi WHERE
{
  ?ccl ^th:narrower ?pcl .
  #{x.to_ref} (th:isTopConceptReference/bo:reference) ?pcl .
  ?pcl th:identifier ?pi .
  {
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
    }
  }
}}
      query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC])
      triples += query_results.by_object_set([:e, :ccl, :cid, :cl, :ci, :cn, :pn, :pi])
    end
    triples.each do |entry|
      uri = entry[:e].to_s
      raw_results[uri][:children] << {key: entry[:cid], uri: entry[:ccl], label: entry[:cl], notation: entry[:cn], previous: entry[:pn], identifier: entry[:ci], parent_identifier: entry[:pi]}
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
        final_results[key] = {id: entry[:uri].to_id, key: entry[:key], label: entry[:label] , notation: entry[:notation], identifier: entry[:identifier], parent_identifier: entry[:parent_identifier], status: initial_status.dup}
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

  # Managed Children Pagination. Get the children in pagination manner
  #
  # @params [Hash] params the params hash
  # @option params [String] :offset the offset to be obtained
  # @option params [String] :count the count to be obtained
  # @option params [Array] :tags the tag to be displayed
  # @return [Array] array of hashes containing the child data
  def managed_children_pagination(params)
    results =[]
    count = params[:count].to_i
    offset = params[:offset].to_i
    tags = params.key?(:tags) ? params[:tags] : []

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
    tag_clause = tags.empty? ? "" : "VALUES ?t { '#{tags.join("' '")}' } "
    query_string = %Q{
SELECT DISTINCT ?i ?n ?d ?pt ?e (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{Thesaurus::ManagedConcept.synonym_separator} \") as ?sys) (GROUP_CONCAT(DISTINCT ?t ;separator=\"#{IsoConceptSystem.tag_separator} \") as ?gt) ?s WHERE\n
{
  SELECT DISTINCT ?i ?n ?d ?pt ?e ?del ?s ?sy ?t WHERE
  {
    VALUES ?s { #{uris.map{|x| x.to_ref}.join(" ")} }
    {
      ?s th:identifier ?i .
      ?s th:notation ?n .
      ?s th:definition ?d .
      ?s th:extensible ?e .
      ?s th:preferredTerm/isoC:label ?pt .
      OPTIONAL {?s th:synonym/isoC:label ?sy .}
      OPTIONAL {?s isoC:tagged/isoC:prefLabel ?t . #{tag_clause}}
    }
  } ORDER BY ?i ?sy ?t
} GROUP BY ?i ?n ?d ?pt ?e ?s ORDER BY ?i
}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC])
    query_results.by_object_set([:i, :n, :d, :e, :pt, :sys, :gt, :s]).each do |x|
      results << {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], extensible: x[:e].to_bool, definition: x[:d], id: x[:s].to_id, tags: x[:gt]}
    end
    results
  end

  # Managed Children Indicators Paginated. Get the children in pagination manner
  #
  # @params [Hash] params the params hash
  # @option params [String] :offset the offset to be obtained
  # @option params [String] :count the count to be obtained
  # @option params [Array] :tags the tag to be displayed
  # @return [Array] array of hashes containing the child data
  def managed_children_indicators_paginated(params)
    results =[]
    tags = params.key?(:tags) ? params[:tags] : []

    # Get set of URIs
    uris = child_uri_set(params)

    # Get the final result
    tag_clause = tags.empty? ? "" : "VALUES ?t { '#{tags.join("' '")}' } "
    query_string = %Q{
SELECT DISTINCT ?i ?n ?d ?pt ?e ?o ?ext ?sub (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{Thesaurus::ManagedConcept.synonym_separator} \") as ?sys) (GROUP_CONCAT(DISTINCT ?t ;separator=\"#{IsoConceptSystem.tag_separator} \") as ?gt) ?s WHERE\n
{
  SELECT DISTINCT ?i ?n ?d ?pt ?e ?del ?s ?sy ?t ?o ?ext ?sub WHERE
  {
    VALUES ?s { #{uris.map{|x| x.to_ref}.join(" ")} }
    {
      ?s th:identifier ?i .
      ?s th:notation ?n .
      ?s th:definition ?d .
      ?s th:extensible ?e .
      ?s th:preferredTerm/isoC:label ?pt .
      ?s isoT:hasIdentifier/isoI:hasScope/isoI:shortName ?o
      OPTIONAL {?s th:synonym/isoC:label ?sy .}
      OPTIONAL {?s isoC:tagged/isoC:prefLabel ?t . #{tag_clause}}
      BIND ( EXISTS {?s ^th:extends ?x } AS ?ext )         
      BIND ( EXISTS {?s ^th:subsets ?x } AS ?sub )   
    }
  } ORDER BY ?i ?sy ?t
} GROUP BY ?i ?n ?d ?pt ?e ?s ?o ?ext ?sub ORDER BY ?i
}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC, :isoT, :isoI])
    query_results.by_object_set([:i, :n, :d, :e, :pt, :sys, :gt, :s, :o, :ext, :sub]).each do |x|
      indicators = {current: false, extended: x[:ext].to_bool, extends: false, version_count: 0, subset: false, subsetted: x[:sub].to_bool}
      results << {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], extensible: x[:e].to_bool, 
        definition: x[:d], id: x[:s].to_id, tags: x[:gt], indicators: indicators, owner: x[:o]}
    end
    results
  end

  # Set Referenced Thesaurus. Set the referenced thesaurus
  #
  # @param [Thesaurus] object the thesaurus object
  # @return [Void] no return
  def set_referenced_thesaurus(object)
    tx = transaction_begin
    self.reference_objects
    if self.reference.nil? 
      self.reference = OperationalReferenceV3.create({reference: object, transaction: tx}, self)
      self.save
    else
      ref = self.reference
      ref.reference = object.uri
      ref.save
    end
    transaction_execute
  end

  # Referenced Thesaurus. Find the single referenced thesaurus
  #
  # @return [Uri] the uri of the singfle reference thesaurus
  def get_referenced_thesaurus
    ref = self.reference_objects
    return nil if ref.nil?
    return Thesaurus.find_minimum(ref.reference)
  end    
  
  # Add Child. Adds a child item that is itself managed
  #
  # @params [Hash] params the parameters, can be empty for auto-generated identifier
  # @option params [String] :identifier the identifer
  # @return [Object] the created object. May contain errors if unsuccesful.
  def add_child(params={})
    ordinal = next_ordinal(:is_top_concept_reference)
    transaction_begin
    child = Thesaurus::ManagedConcept.create
    return child if child.errors.any?
    ref = OperationalReferenceV3::TmcReference.create({reference: child, ordinal: ordinal}, self)
    self.add_link(:is_top_concept, child.uri)
    self.add_link(:is_top_concept_reference, ref.uri)
    transaction_execute
    child
  end

  # Select Children. Select 1 or more child items that are managed
  #
  # @params [Hash] params the parameters
  # @option params [String] :id_set the array of ids to be added
  # @return [Void] the created object. May contain errors if unsuccesful.
  def select_children(params)
    ordinal = next_ordinal(:is_top_concept_reference)
    self.is_top_concept_reference_objects
    transaction_begin
    params[:id_set].each do |id|
      uri = Uri.new(id: id)
      refs = self.is_top_concept_reference.select {|x| x.reference == uri}
      next if refs.any?
      ref = OperationalReferenceV3::TmcReference.create({reference: uri, ordinal: ordinal}, self)
      self.add_link(:is_top_concept, uri)
      self.add_link(:is_top_concept_reference, ref.uri)
      ordinal += 1
    end
    transaction_execute
  end

  # Deselect Children. Deselect 1 or more child items. The child items are not deleted only the references.
  #
  # @params [Hash] params the parameters
  # @option params [String] :id_set the array of ids to be added
  # @return [Void] no return
  def deselect_children(params)
    query_string = %Q{
      DELETE 
      { 
        ?s ?p ?o 
      } 
      WHERE 
      {
        VALUES ?x { #{params[:id_set].map {|x| Uri.new(id: x).to_ref}.join(" ")} }
        { 
          #{self.uri.to_ref} th:isTopConceptReference ?s .
          ?s bo:reference ?x .
          ?s ?p ?o
        } UNION
        { 
          BIND ( #{self.uri.to_ref} as ?s )
          BIND ( th:isTopConceptReference as ?p ) .
          #{self.uri.to_ref} th:isTopConceptReference ?o .
          ?o bo:reference ?x .
        } UNION
        { 
          BIND ( #{self.uri.to_ref} as ?s )
          BIND ( th:isTopConcept as ?p ) .
          BIND ( ?x as ?o)
        }
      }
    }
    partial_update(query_string, [:th, :bo])
  end

  # Deselect All Children. Deselect all child items. The child items are not deleted only the references.
  #
  # @return [Void] no return
  def deselect_all_children
    query_string = %Q{
      DELETE 
      { 
        ?s ?p ?o 
      } 
      WHERE 
      {
        { 
          #{self.uri.to_ref} th:isTopConceptReference ?s .
          ?s ?p ?o
        } UNION
        { 
          BIND ( #{self.uri.to_ref} as ?s )
          BIND ( th:isTopConceptReference as ?p ) .
          #{self.uri.to_ref} th:isTopConceptReference ?o .
        } UNION
        { 
          BIND ( #{self.uri.to_ref} as ?s )
          BIND ( th:isTopConcept as ?p ) .
          #{self.uri.to_ref} th:isTopConcept ?o .
        }
      }
    }
    partial_update(query_string, [:th])
  end

  # Add Extension. Adds an extension code list to the thresaurus
  #
  # @param id [String] the identifier of the code list to be extended
  # @return [Object] the created object. Will contain errors if unsuccesful
  def add_extension(id)
    transaction = transaction_begin
    source = Thesaurus::ManagedConcept.find_full(id)
    source.narrower_links
    object = source.clone
    object.identifier = "#{source.scoped_identifier}E"
    object.extensible = false # Make sure we cannot extend the extension
    object.set_initial(object.identifier)
    object.transaction_set(transaction)
    object.create_or_update(:create, true) if object.valid?(:create) && object.create_permitted?
    object.add_link(:extends, source.uri)
    return object if object.errors.any?
    ordinal = next_ordinal(:is_top_concept_reference)
    ref = OperationalReferenceV3::TcReference.create({reference: object, ordinal: ordinal, transaction: transaction}, self)
    self.add_link(:is_top_concept, object.uri)
    self.add_link(:is_top_concept_reference, ref.uri)
    transaction_execute
    object
  end

  # Add subset. Creates a new MC, Subset, and links them together.
  #
  # @param mc_id [String] the identifier of the code list to be subsetted
  # @return [Object] the created ManagedConcept
  def add_subset(mc_id)
    source_mc = Thesaurus::ManagedConcept.find_minimum(mc_id)
    new_mc = self.add_child({})
    transaction_begin
    subset = Thesaurus::Subset.create(uri: Thesaurus::Subset.create_uri(self.uri))
    new_mc.add_link(:is_ordered, subset.uri)
    new_mc.add_link(:subsets, source_mc.uri)
    transaction_execute
    new_mc
  end

  # Clone. Clone the thesaurus taking care over the reference objects
  #
  # @return [Thesaurus] a clone of the object
  def clone
    self.is_top_concept = []
    self.is_top_concept_links
    self.is_top_concept_reference = []
    self.is_top_concept_reference_objects
    object = super
    object.is_top_concept_reference = []
    self.is_top_concept_reference.each do |ref|
      object.is_top_concept_reference << ref.clone
    end
    object
  end

private

  # Get the set of URIs for each child
  def child_uri_set(params)
    count = params[:count].to_i
    offset = params[:offset].to_i
    query_string = %Q{
      SELECT ?e WHERE
      {
        #{self.uri.to_ref} th:isTopConceptReference ?r .
        ?r bo:reference ?e .
        ?r bo:ordinal ?v
      } ORDER BY (?v) LIMIT #{count} OFFSET #{offset}
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo])
    query_results.by_object_set([:e]).map{|x| x[:e]}
  end

  # Changes result comparison class
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

  # Submission result comparison class
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

  # TODO: This needs looking at. used by CdiscTerm
  def self.import(params, ownerNamespace)
    object = super(C_CID_PREFIX, params, ownerNamespace, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS)
    return object
  end
=end

end
