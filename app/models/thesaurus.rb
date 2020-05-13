# Thesaurus. Class for an entire thesaurus
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus <  IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Thesaurus",
            uri_suffix: "TH"

  object_property :is_top_concept_reference, cardinality: :many, model_class: "OperationalReferenceV3::TmcReference", children: true
  object_property :is_top_concept, cardinality: :many, model_class: "Thesaurus::ManagedConcept", delete_exclude: true, read_exclude: true
  object_property :reference, cardinality: :one, model_class: "OperationalReferenceV3"
  object_property :baseline_reference, cardinality: :one, model_class: "OperationalReferenceV3"

  include Thesaurus::Search
  include Thesaurus::Where
  include Thesaurus::Difference

  # Update Status. Update the status.
  #
  # @params [Hash] params the parameters
  # @option params [String] :registration_tatus, the new state
  # @return [Void] errors are in the error object, if any
  def update_status(params)
    move_to_next_state? ? super : self.errors.add(:base, "Child items are not in the appropriate state.")
  end

  # Add. Add an item to the thesaurus. Note there is no save!
  #
  # @param item [Object] the item being added
  # @param ordinal [Integer] the ordinal of the item in the collection
  # @return [Void] no return
  def add(item, ordinal)
    ref = OperationalReferenceV3::TmcReference.new(ordinal: ordinal, reference: item.uri)
    ref.uri = ref.create_uri(self.uri)
    self.is_top_concept_reference << ref
    self.is_top_concept << item.uri
  end

  # Current Set Where. Full where search of the managed items. Will find within children via paths that are not excluded.
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

  # Find By Identifier. Finds items with the quoted identifier path.
  #
  # @param [Array] identifiers array of the required identifiers as a path
  # @return [Hash] a hash keyed by identifier containing the URI of the items found matching the path
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

  # Find Identifier. Finds any children with the specified identifier.
  #
  # @param [String] identifier the identifier to be found
  # @result [Array] an array of hash containing the uri and rdf_type for the item
  def find_identifier(identifier)
    query_string = %Q{
      SELECT ?uri ?rdf_type WHERE
      {
        #{self.uri.to_ref} th:isTopConceptReference/bo:reference ?b .
        ?b th:narrower* ?uri .
        ?uri th:identifier "#{identifier}" .
        ?uri rdf:type ?rdf_type
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo])
    query_results.by_object_set([:uri, :rdf_type])
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

  # Changes_impact_v2. It finds the changes between two CDISC thesauruses, filtered by items with existing links to the specific sponsor thesaurus
  #
  # @param [Object] new_version the required window size for changes
  # @param [Object] sponsor_version the required window size for changes
  # @return [Array] the changes hash. Consists of a set of versions and the changes for each item and version
  def changes_impact_v2(new_version, sponsor_version)
    final_results = []
    # Get the raw results
    query_string = %Q{
      SELECT DISTINCT ?cl ?v ?l ?n ?i ?o ?t ?cl_new WHERE
      {
        { #{self.uri.to_ref} th:isTopConceptReference/bo:reference ?cl  } MINUS { #{new_version.uri.to_ref} th:isTopConceptReference/bo:reference ?cl }
        BIND (NOT EXISTS {#{sponsor_version.uri.to_ref} th:isTopConceptReference/bo:reference/th:narrower/^th:narrower ?cl}
          && NOT EXISTS {#{sponsor_version.uri.to_ref} th:isTopConceptReference/bo:reference ?cl} AS ?cilink)
        FILTER(?cilink=false)
        ?cl isoT:hasIdentifier ?si .
        ?si isoI:version ?v .
        ?cl isoC:label ?l .
        ?cl th:notation ?n .
        ?si isoI:identifier ?i .
        ?cl isoT:hasIdentifier/isoI:hasScope/isoI:shortName ?o .
        ?cl rdf:type ?t
        OPTIONAL
        {
          #{new_version.uri.to_ref} th:isTopConceptReference/bo:reference ?cl_new .
          ?cl_new isoT:hasIdentifier/isoI:identifier ?i .
        }
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
    triples = query_results.by_object_set([:cl, :v, :l, :n, :i, :o, :t, :cl_new])
    triples.each do |entry|
      final_results.push({identifier: entry[:i], id: Uri.new(uri: entry[:cl].to_s).to_id, label: entry[:l],
        notation: entry[:n], version: entry[:v], owner: entry[:o], rdf_type: entry[:t].to_s, cl_new: Uri.new(uri: entry[:cl_new].to_s).to_id})
    end
    final_results
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
    date_time = Time.now.iso8601
    
    # Get set of URIs. Not needed if we dont use VALUES in the following query.
    # uris = child_uri_set(params)
    count = params[:count].to_i
    offset = params[:offset].to_i

    # Get the final result
    tag_clause = tags.empty? ? "" : "VALUES ?t { '#{tags.join("' '")}' } "
    query_string = %Q{
      SELECT DISTINCT ?s ?i ?n ?d ?pt ?e ?o ?rs ?ext ?sub ?eo ?so ?sv ?sci ?ns ?count ?current (count(distinct ?ci) AS ?countci) (count(distinct ?cn) AS ?countcn)
      (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{Thesaurus::ManagedConcept.synonym_separator} \") as ?sys)
      (GROUP_CONCAT(DISTINCT ?t ;separator=\"#{IsoConceptSystem.tag_separator} \") as ?gt)
      WHERE\n
      {
        SELECT DISTINCT ?i ?n ?d ?pt ?e ?del ?s ?sy ?t ?o ?rs ?ext ?sub ?eo ?so ?sv ?sci ?ns ?count ?current ?ci ?cn
        WHERE
        {
          {
            SELECT DISTINCT ?s ?sv ?sci ?ns (count(?lv) AS ?count) WHERE
            {
              #{self.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
              ?s isoT:hasIdentifier/isoI:semanticVersion ?sv .                 
              ?s isoT:hasIdentifier/isoI:identifier ?sci .                 
              ?s isoT:hasIdentifier/isoI:hasScope ?ns .                 
              ?x rdf:type th:ManagedConcept .                 
              ?x isoT:hasIdentifier/isoI:identifier ?sci .                 
              ?x isoT:hasIdentifier/isoI:hasScope ?ns .                 
              ?x isoT:hasIdentifier/isoI:version ?lv .    
            } GROUP BY ?s ?sv ?sci ?ns
          }
          ?s isoT:hasState ?st .
          ?st isoR:registrationStatus ?rs .
          ?st isoR:effectiveDate ?ed .
          ?st isoR:untilDate ?ud .
          BIND ( xsd:dateTime(?ed) <= \"#{date_time}\"^^xsd:dateTime && xsd:dateTime(?ud) >= \"#{date_time}\"^^xsd:dateTime AS ?current ) .
          OPTIONAL {?ci (ba:current/bo:reference)|(ba:previous/bo:reference) ?s . ?ci rdf:type ba:ChangeInstruction }
          OPTIONAL {?cn (ba:current/bo:reference) ?s . ?cn rdf:type ba:ChangeNote }
          ?s th:identifier ?i .
          ?s th:notation ?n .
          ?s th:definition ?d .
          ?s th:extensible ?e .
          ?s th:preferredTerm/isoC:label ?pt .
          ?s isoT:hasIdentifier/isoI:hasScope/isoI:shortName ?o
          OPTIONAL {?s th:synonym/isoC:label ?sy .}
          OPTIONAL {?s isoC:tagged/isoC:prefLabel ?t . #{tag_clause}}
          BIND (EXISTS {?s th:extends ?xe1} as ?eo)
          BIND (EXISTS {?s th:subsets ?xs1} as ?so)
          BIND (EXISTS {?s ^th:extends ?x } AS ?ext )
          BIND (EXISTS {?s ^th:subsets ?x } AS ?sub )
        } ORDER BY ?i ?sy ?t
      } GROUP BY ?i ?n ?d ?pt ?e ?s ?o ?rs ?ext ?sub ?eo ?so ?sv ?sci ?ns ?count ?current ?countci ?countcn ORDER BY ?i LIMIT #{count} OFFSET #{offset}
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC, :isoT, :isoI, :isoR, :ba])
    query_results.by_object_set([:s, :i, :n, :d, :pt, :e, :o, :rs, :ext, :sub, :eo, :so, :sv, :sci, :ns, :count, :current, :sys, :gt ]).each do |x|
      indicators = {current: x[:current].to_bool, extended: x[:ext].to_bool, extends: x[:eo].to_bool, version_count: x[:count].to_i, subset: x[:so].to_bool, subsetted: x[:sub].to_bool, annotations: {change_notes: x[:countcn].to_i, change_instructions: x[:countci].to_i}}
      results << {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], state: x[:rs], extensible: x[:e].to_bool,
        definition: x[:d], id: x[:s].to_id, semantic_version: x[:sv], tags: x[:gt], indicators: indicators, owner: x[:o], scoped_identifier: x[:sci], scope_id: x[:ns].to_id }
    end
    results
  end


  def move_to_next_state?
    (managed_children_states & IsoRegistrationStateV2.previous_states(self.registration_status)).empty?
  end

  # Managed Children States.
  #
  # @return [Array] array of states for the children
  def managed_children_states
    query_string = %Q{
      SELECT ?s WHERE
      {
        #{self.uri.to_ref} th:isTopConceptReference/bo:reference/isoT:hasState/isoR:registrationStatus ?s .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoT, :isoR])
    query_results.by_object_set([:s]).map{|x| x[:s].to_sym}
  end

  # Upgrade. Upgrade the thesaurus when referened version updated.
  #
  # @return [Void] no return
  def upgrade
    self.reference_objects
    self.baseline_reference_objects
    query_string = %Q{
      SELECT DISTINCT ?s ?x WHERE
      {
        #{self.uri.to_ref} th:isTopConceptReference ?r .
        ?r bo:ordinal ?ord .
        ?r bo:reference ?s .
         #{self.baseline_reference.reference.to_ref} th:isTopConceptReference/bo:reference ?s .
        ?s isoT:hasIdentifier/isoI:identifier ?i .
        OPTIONAL {
          #{self.reference.reference.to_ref} th:isTopConceptReference/bo:reference ?x .
          ?x isoT:hasIdentifier/isoI:identifier ?i .
        }
      } ORDER BY ?ord
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoT, :isoI])
    old_items = query_results.by_object_set([:s]).map{|x| x[:s]}
    new_items = query_results.by_object_set([:x]).map{|x| x[:x]}.reject(&:blank?)
    deselect_children({id_set: old_items.map{|x| x.to_id}})
    select_children({id_set: new_items.map{|x| x.to_id}})
  end

  # Set Referenced Thesaurus. Set the referenced thesaurus and set the baseline if necessary
  #
  # @param [Thesaurus] object the thesaurus object
  # @return [Boolean] true if the upgrade should be called on this instance
  def set_referenced_thesaurus(object)
    tx = transaction_begin
    should_upgrade = false
    self.reference_objects
    self.baseline_reference_objects
    if self.reference.nil?
      self.reference = OperationalReferenceV3.create({reference: object.uri, ordinal: 1, transaction: tx}, self)
      self.baseline_reference = nil
      self.save
    else
      ref = self.reference
      self.baseline_reference = OperationalReferenceV3.create({reference: ref.reference.dup, ordinal: 2, transaction: tx}, self) if self.baseline_reference.nil?
      self.save
      ref.transaction_set(tx)
      ref.reference = object.uri
      ref.save
      should_upgrade = true
    end
    transaction_execute
    should_upgrade
  end

  # Check if can Set Referenced Thesaurus.
  #
  # @param [Thesaurus] object the thesaurus object
  # @return [Object] current object
  def valid_reference?(object)
    self.reference_objects
    return self if self.reference.nil?
    ref = self.reference
    ref_th = Thesaurus.find_minimum(ref.reference)
    self.errors.add(:base, "The reference thesaurus must be a later version than the current one is (#{ref_th.version_label}).") if object.version <= ref_th.version
    self
  end

  # Referenced Thesaurus. Find the single referenced thesaurus
  #
  # @return [Uri] the uri of the single reference thesaurus
  def get_referenced_thesaurus
    ref = self.reference_objects
    return nil if ref.nil?
    Thesaurus.find_minimum(ref.reference)
  end

  # Baseline Referenced Thesaurus. Find the single referenced baseline thesaurus
  #
  # @return [Uri] the uri of the single baseline reference thesaurus
  def get_baseline_referenced_thesaurus
    ref = self.baseline_reference_objects
    return nil if ref.nil?
    Thesaurus.find_minimum(ref.reference)
  end

  # Add Child. Adds a child item that is itself managed
  #
  # @params [Hash] params the parameters, can be empty for auto-generated identifier
  # @option params [String] :identifier the identifer
  # @return [Object] the created object. May contain errors if unsuccesful.
  def add_child(params={})
    ordinal = next_ordinal(:is_top_concept_reference)
    tx = transaction_begin
    child = Thesaurus::ManagedConcept.create
    return child if child.errors.any?
    ref = OperationalReferenceV3::TmcReference.create({reference: child, ordinal: ordinal, transaction: tx}, self)
    self.add_link(:is_top_concept, child.uri)
    self.add_link(:is_top_concept_reference, ref.uri)
    transaction_execute
    child
  end

  # Replace Child. Replaces a child item that is itself managed
  #
  # @params [Thesaurus::ManagedConcept] old_ref the item to be replaced 
  # @params [Thesaurus::ManagedConcept] new_ref the new item
  # @return [Void] no return
  def replace_child(old_ref, new_ref)
    query = %Q{
      DELETE
      {
        ?r bo:reference #{old_ref.uri.to_ref} .
        #{self.uri.to_ref} th:isTopConcept #{old_ref.uri.to_ref} .
      }
      INSERT
      {
        ?r bo:reference #{new_ref.uri.to_ref} .
        #{self.uri.to_ref} th:isTopConcept #{new_ref.uri.to_ref} .
      }
      WHERE
      {
        #{self.uri.to_ref} th:isTopConceptReference ?r .
        ?r bo:reference #{old_ref.uri.to_ref} .
        #{self.uri.to_ref} th:isTopConcept #{old_ref.uri.to_ref} .
      }
    }
    partial_update(query, [:th, :bo])
  end

  # Select Children. Select 1 or more child items that are managed
  #
  # @params [Hash] params the parameters
  # @option params [String] :id_set the array of ids to be added
  # @return [Void] the created object. May contain errors if unsuccesful.
  def select_children(params)
    ordinal = next_ordinal(:is_top_concept_reference)
    self.is_top_concept_reference_objects
    tx = transaction_begin
    params[:id_set].each do |id|
      uri = Uri.new(id: id)
      refs = self.is_top_concept_reference.select {|x| x.reference == uri}
      next if refs.any?
      ref = OperationalReferenceV3::TmcReference.create({reference: uri, ordinal: ordinal, transaction: tx}, self)
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
        {
          VALUES ?x { #{params[:id_set].map {|x| Uri.new(id: x).to_ref}.join(" ")} }
          #{self.uri.to_ref} th:isTopConceptReference ?s .
          ?s bo:reference ?x .
          ?s ?p ?o
        } UNION
        {
          VALUES ?x { #{params[:id_set].map {|x| Uri.new(id: x).to_ref}.join(" ")} }
          BIND ( #{self.uri.to_ref} as ?s )
          BIND ( th:isTopConceptReference as ?p ) .
          #{self.uri.to_ref} th:isTopConceptReference ?o .
          ?o bo:reference ?x .
        } UNION
        {
          VALUES ?x { #{params[:id_set].map {|x| Uri.new(id: x).to_ref}.join(" ")} }
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
    tc = Thesaurus::ManagedConcept.find_full(id)
    object = tc.create_extension
    ordinal = next_ordinal(:is_top_concept_reference)
    ref = OperationalReferenceV3::TmcReference.create({reference: object, ordinal: ordinal, transaction: transaction}, self)
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
    transaction = transaction_begin
    tc = Thesaurus::ManagedConcept.find_full(mc_id)
    object = tc.create_subset
    ordinal = next_ordinal(:is_top_concept_reference)
    ref = OperationalReferenceV3::TmcReference.create({reference: object, ordinal: ordinal, transaction: transaction}, self)
    self.add_link(:is_top_concept, object.uri)
    self.add_link(:is_top_concept_reference, ref.uri)
    transaction_execute
    object
  end

  # Clone. Clone the thesaurus taking care over the reference objects
  #
  # @return [Thesaurus] a clone of the object
  def clone
    self.is_top_concept_links
    self.is_top_concept_reference_objects
    self.reference_objects
    object = super
    object.is_top_concept_reference = []
    self.is_top_concept_reference.each do |ref|
      object.is_top_concept_reference << ref.clone
    end
    object.reference = self.reference.clone
    object
  end

  def self.impact_to_csv(first_version, new_version, sponsor_version)
    results = []
    have_i_seen = []
    items = first_version.changes_impact_v2(new_version, sponsor_version)
    items.each do |item|
        recursion(item[:id], results, sponsor_version, have_i_seen)
    end
    headers = ["Code", "Codelist Extensible (Yes/No)", "Codelist Name",
      "CDISC Submission Value", "CDISC Definition"]
    CSVHelpers.format(headers, results)
  end

  # Compare_to_csv. Get the differences between two versions in csv format
  #
  # @params [] first version
  # @params [] second_version
  # @return
  def self.compare_to_csv(first_version, second_version)
    results = first_version.differences(second_version)
    headers = ["Status","Code", "Codelist Name","CDISC Submission Value"]
    new_results = []
      results.each do |key, value|
        next if key == :versions
         value.each do |x|
          x.delete(:last_id)
          x.delete(:id)
          item = x.map{|k,v| v.to_s}.to_a
          new_results <<  item.insert(0,key.to_s)
         end
        results.delete(:versions)
      end
       CSVHelpers.format(headers, new_results)
  end

  # Audit Type. Text for the type to be used in an audit message
  #
  # @return [String] the type for the audit message
  def audit_type
    "Terminology"
  end

private

  def self.recursion(item_id, results, sponsor_version, have_i_seen)
    tc = Thesaurus::ManagedConcept.find_with_properties(item_id)
    #tc.synonyms_and_preferred_terms
    if !have_i_seen.include? item_id
      results.push(tc.to_a_by_key(:identifier, :extensible, :label, :notation, :definition))
      have_i_seen.push(item_id)
      arr = tc.impact(sponsor_version)
    else
      arr = []
    end
    return 0 if arr.empty?
    arr.each do |item|
      recursion(item[:id], results, sponsor_version, have_i_seen)
    end
  end

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

end
