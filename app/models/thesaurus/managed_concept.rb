class Thesaurus::ManagedConcept < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#ManagedConcept",
            uri_property: :identifier,
            key_property: :identifier
            
  data_property :identifier
  data_property :notation
  data_property :definition
  data_property :extensible
  object_property :narrower, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept", children: true
  object_property :extends, cardinality: :one, model_class: "Thesaurus::ManagedConcept", delete_exclude: true
  object_property :subsets, cardinality: :one, model_class: "Thesaurus::ManagedConcept", delete_exclude: true
  object_property :preferred_term, cardinality: :one, model_class: "Thesaurus::PreferredTerm"
  object_property :synonym, cardinality: :many, model_class: "Thesaurus::Synonym"
  
  validates_with Validator::Field, attribute: :identifier, method: :valid_tc_identifier?
  validates_with Validator::Field, attribute: :notation, method: :valid_submission_value?
  validates_with Validator::Field, attribute: :definition, method: :valid_terminology_property?
  validates_with Validator::Uniqueness, attribute: :identifier, on: :create

  # config = 
  # {
  #   relationships: 
  #   [
  #     Thesaurus::UnmanagedConcept.rdf_type.to_ref, 
  #     Thesaurus::Synonym.rdf_type.to_ref, 
  #     Thesaurus::PreferredTerm.rdf_type.to_ref,
  #     Thesaurus::Subset.rdf_type.to_ref
  #   ]
  # } 
  # self.class.instance_variable_set(:@configuration, config)

  include Thesaurus::BaseConcept
  include Thesaurus::Identifiers
  include Thesaurus::Synonyms

  # Extended? Is this item extended
  #
  # @result [Boolean] return true if extended
  def extended?
    !extended_by.nil?
  end

  # Extended By. Get the URI of the extension item if it exists. 
  #
  # @result [Uri] the Uri or nil if not present.
  def extended_by
    query_string = %Q{SELECT ?s WHERE { #{self.uri.to_ref} ^th:extends ?s }}
    query_results = Sparql::Query.new.query(query_string, "", [:th])
    return query_results.empty? ? nil : query_results.by_object_set([:s]).first[:s]
  end

  # Extension? Is this item extending another managed concept
  #
  # @result [Boolean] return true if extending another
  def extension?
    !extension_of.nil?
  end

  # Extension Of. Get the URI of the item being extended, if it exists. 
  #
  # @result [Uri] the Uri or nil if not present.
  def extension_of
    query_string = %Q{SELECT ?s WHERE { #{self.uri.to_ref} th:extends ?s }}
    query_results = Sparql::Query.new.query(query_string, "", [:th])
    return query_results.empty? ? nil : query_results.by_object_set([:s]).first[:s]
  end

  def replace_if_no_change(previous)
    return self if previous.nil?
    return previous if !self.diff?(previous, {ignore: [:has_state, :has_identifier, :origin, :change_description, :creation_date, :last_change_date, :explanatory_comment]})
    replace_children_if_no_change(previous)
    return self
  rescue => e
    byebug
  end

  # Changes Count
  #
  # @param [Integer] window_size the required window size for changes
  # @return [Integer] the number of changes
  def changes_count(window_size)
    items = self.class.history_uris(identifier: self.has_identifier.identifier, scope: self.scope).reverse
    first_index = items.index {|x| x == self.uri}    
    if first_index.nil? 
      first_index = 0
      start_index = 0 
    elsif first_index == 0 
      start_index = 0 
    else
      start_index = first_index - 1
    end    
    last_index = first_index + window_size - 1
    last_index = last_index < items.count ? last_index : items.count - 1
    count = last_index - first_index + 1
    count += 1 if deleted_from_ct?(items.last)
    count
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
    # Get the version set. Work out if we need a dummy first one. Note the identifier
    items = self.class.history_uris(identifier: self.has_identifier.identifier, scope: self.scope).reverse
    first_index = items.index {|x| x == self.uri}    
    if first_index.nil? 
      first_index = 0
      start_index = 0 
      raw_results["dummy"] = {version: 0, date: "", children: []} if first_index == 0
    elsif first_index == 0 
      start_index = 0 
      raw_results["dummy"] = {version: 0, date: "", children: []} if first_index == 0
    else
      start_index = first_index - 1
      raw_results = {}
    end    
    length = items.count < window_size ? items.count : window_size
    version_set = items[start_index..(first_index + length - 1)]

    # Get the raw results
    query_string = %Q{SELECT ?e ?v ?d ?i ?cl ?l ?n WHERE
{
  #{version_set.map{|x| "{ #{x.to_ref} th:narrower ?cl . #{x.to_ref} isoT:creationDate ?d . #{x.to_ref} isoT:hasIdentifier ?si1 . ?si1 isoI:version ?v . BIND (#{x.to_ref} as ?e)} "}.join(" UNION\n")}
  ?cl th:identifier ?i .
  ?cl isoC:label ?l .
  ?cl th:notation ?n .
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
    triples = query_results.by_object_set([:e, :v, :d, :i, :cl, :l, :n])
    triples.each do |entry|
      uri = entry[:e].to_s
      raw_results[uri] = {version: entry[:v].to_i, date: entry[:d].to_time_with_default.strftime("%Y-%m-%d"), children: []} if !raw_results.key?(uri)
      raw_results[uri][:children] << DiffResult[key: entry[:i], uri: entry[:cl], label: entry[:l], notation: entry[:n]]
    end

    # Item deleted?
    item_was_deleted_info = deleted_from_ct_version(items.last)

    # Get the version array
    raw_results.sort_by {|k,v| v[:version]}
    raw_results.each {|k,v| versions << v[:date]}
    versions = versions.drop(1)

    
    # Build the skeleton final results with a default value.
    initial_status = [{ status: :not_present}] * versions.length
    if item_was_deleted_info[:deleted]
      versions << item_was_deleted_info[:ct].creation_date.strftime("%Y-%m-%d") 
      initial_status << { status: :deleted}
    end
    raw_results.each do |uri, version|
      version[:children].each do |entry|
        key = entry[:key].to_sym
        next if final_results.key?(key)
        final_results[key] = {key: entry[:key], identifier: entry[:key], id: entry[:uri].to_id, label: entry[:label] , notation: entry[:notation], status: initial_status.dup}
      end
    end

    # Process the changes
    previous_version = nil
    version_index = 0
    raw_results.each do |uri, version|
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
        version_index += 1
      end
      previous_version = version
    end

    # And return
    {versions: versions, items: final_results}
  end

  # Changes_summary
  #
  # @param [Integer] window_size the required window size for changes
  # @return [Hash] the changes hash. Consists of a set of versions and the changes for each item and version
  def changes_summary(last, actual_versions)
    raw_results = {}
    final_results = {}
    versions = []
    raw_results = {} 
    # Get the raw results
    query_string = %Q{SELECT ?e ?v ?d ?i ?cl ?l ?n WHERE
{
  { #{self.uri.to_ref} th:narrower ?cl . #{self.uri.to_ref} isoT:creationDate ?d . #{self.uri.to_ref} isoT:hasIdentifier ?si1 . ?si1 isoI:version ?v . BIND (#{self.uri.to_ref} as ?e)} UNION\n
  { #{last.uri.to_ref} th:narrower ?cl . #{last.uri.to_ref} isoT:creationDate ?d . #{last.uri.to_ref} isoT:hasIdentifier ?si1 . ?si1 isoI:version ?v . BIND (#{last.uri.to_ref} as ?e)} 

  ?cl th:identifier ?i .
  ?cl isoC:label ?l .
  ?cl th:notation ?n .
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
    triples = query_results.by_object_set([:e, :v, :d, :i, :cl, :l, :n])

    triples.each do |x|
      uri = x[:e].to_s
      raw_results[uri] = {version: x[:v].to_i, date: x[:d].to_time_with_default.strftime("%Y-%m-%d"), children: []} if !raw_results.key?(uri)
      raw_results[uri][:children] << DiffResult[key: x[:i], uri: x[:cl], label: x[:l], notation: x[:n]]
    end

    # Get the version array
    raw_results.sort_by {|k,v| v[:version]}
    raw_results.each {|k,v| versions << v[:date]}
    
    # # Build the skeleton final results with a default value.
    initial_status = [{ status: :no_change}] * versions.length

    raw_results.each do |uri, version|
      version[:children].each do |entry|
        key = entry[:key].to_sym
        next if final_results.key?(key)
        final_results[key] = {key: entry[:key], identifier: entry[:key], id: entry[:uri].to_id, label: entry[:label] , notation: entry[:notation], status: initial_status.dup}
      end
    end

    # Process the changes
    previous_version = nil
    version_index = 0
  
    raw_results.each do |uri, version|
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
          final_results[entry[:key].to_sym][:status][version_index-1] = {status: :not_present}
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
      version_index += 1
      previous_version = version
    end

    # And return
    {versions: actual_versions, items: final_results}
  end

  # Differences_summary
  #
  # @return [Hash] the differences hash. Consists of a set of versions and the differences for each item and version
  def differences_summary (last, actual_versions)
    results =[]
    items = self.class.history_uris(identifier: self.has_identifier.identifier, scope: self.scope)
    query_string = %Q{
SELECT DISTINCT ?i ?n ?d ?pt ?e ?date (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{self.class.synonym_separator} \") as ?sys) ?s WHERE\n
{
  SELECT DISTINCT ?i ?n ?d ?pt ?e ?del ?s ?sy ?date WHERE   
  {        
    VALUES ?s { #{self.uri.to_ref} #{last.uri.to_ref} }
    {
      ?s th:identifier ?i .
      ?s isoT:creationDate ?date .
      ?s th:notation ?n .
      ?s th:definition ?d .
      ?s th:extensible ?e .
      OPTIONAL {?s th:preferredTerm/isoC:label ?pt .}
      OPTIONAL {?s th:synonym/isoC:label ?sy .}
    }
  } ORDER BY ?i ?sy
} GROUP BY ?i ?n ?d ?pt ?e ?s ?date ORDER BY ?date
}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC, :isoT])

    x = query_results.by_object_set([:i, :n, :d, :e, :pt, :sys, :s, :date]).first
    first = {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], extensible: x[:e].to_bool, definition: x[:d]}
    diffs = x[:s] == items.last ? difference_record_baseline(first) : difference_record_summary_baseline(first)
    results << {id: x[:s].to_id, date: actual_versions[0], differences: diffs}

    x = query_results.by_object_set([:i, :n, :d, :e, :pt, :sys, :s, :date]).last
    last = {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], extensible: x[:e].to_bool, definition: x[:d]}
    diffs = difference_record(last, first)
    results << {id: x[:s].to_id, date: actual_versions[-1], differences: diffs}
    results
  end

  # Differences
  #
  # @return [Hash] the differences hash. Consists of a set of versions and the differences for each item and version
  def differences
    results =[]
    items = self.class.history_uris(identifier: self.has_identifier.identifier, scope: self.scope)
    item_was_deleted_info = deleted_from_ct_version(items.first)
    query_string = %Q{
SELECT DISTINCT ?i ?n ?d ?pt ?e ?date (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{self.class.synonym_separator} \") as ?sys) ?s WHERE\n
{
  SELECT DISTINCT ?i ?n ?d ?pt ?e ?del ?s ?sy ?date WHERE   
  {        
    VALUES ?s { #{items.map{|x| x.to_ref}.join(" ")} }
    {
      ?s th:identifier ?i .
      ?s isoT:creationDate ?date .
      ?s th:notation ?n .
      ?s th:definition ?d .
      ?s th:extensible ?e .
      OPTIONAL {?s th:preferredTerm/isoC:label ?pt .}
      OPTIONAL {?s th:synonym/isoC:label ?sy .}
    }
  } ORDER BY ?i ?sy
} GROUP BY ?i ?n ?d ?pt ?e ?s ?date ORDER BY ?date
}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC, :isoT])
    previous = nil
    x = query_results.by_object_set([:i, :n, :d, :e, :pt, :sys, :s, :date])
    x.each do |x|
      current = {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], extensible: x[:e].to_bool, definition: x[:d]}
      diffs = previous.nil? ? difference_record_baseline(current) : difference_record(current, previous)
      results << {id: x[:s].to_id, date: x[:date].to_time_with_default.strftime("%Y-%m-%d"), differences: diffs}
      previous = current
    end
    if item_was_deleted_info[:deleted]
      results << {id: nil, date: item_was_deleted_info[:ct].creation_date.strftime("%Y-%m-%d"), differences: difference_record_deleted} 
    end
    results
  end

  # Add Extensions 
  #
  # @param uris [Array] set of uris of the items to be added
  # @return [Void] no return
  def add_extensions(uris)
    transaction = transaction_begin
    uris.each {|x| add_link(:narrower, x)}
    transaction_execute
  end

  # Delete Extensions 
  #
  # @param uris [Array] set of uris of the items to be deleted
  # @return [Void] no return
  def delete_extensions(uris)
    transaction = transaction_begin
    uris.each {|x| delete_link(:narrower, x)}
    transaction_execute
  end

  # To CSV. The code list as a set of CSV record with a header.
  #
  # @return [Array] the set of CSV record, each is an array of stirngs
  def to_csv
    headers = ["Code", "Codelist Code", "Codelist Extensible (Yes/No)", "Codelist Name", 
      "CDISC Submission Value", "CDISC Synonym(s)", "CDISC Definition", "NCI Preferred Term"]
    CSVHelpers.format(headers, to_csv_data)
  end

  # To CSV No Header. A CSV record with no header
  #
  # @param parent [String] the parent identifier
  # @return [Array] the results as an array of array of strings
  def to_csv_data
    this = to_a_by_key(:identifier, :extensible, :label, :notation, :definition)
    this.insert(4, self.synonyms_to_s)
    this.insert(6, self.preferred_term.label)
    results = [this.insert(1, self.identifier)]
    children.each do |c|
      data = c.to_csv_data
      data.insert(1, self.identifier)
      data[2] = ""
      data[3] = ""
      results << data
    end
    return results
  end

private

  # Class for a difference result
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

  def deleted_from_ct_version(last_item)
    ct_history = Thesaurus.history_uris(identifier: CdiscTerm::C_IDENTIFIER, scope: IsoRegistrationAuthority.cdisc_scope)
    used_in = thesarus_set(last_item)
    item_was_deleted = used_in.first != ct_history.first
    return {deleted: item_was_deleted, ct: nil} if !item_was_deleted
    deleted_version = ct_history.index{|x| x == used_in.first} - 1
    ct = Thesaurus.find_minimum(ct_history[deleted_version])
    {deleted: item_was_deleted, ct: ct}
  end

  def deleted_from_ct?(last_item)
    ct_history = Thesaurus.history_uris(identifier: CdiscTerm::C_IDENTIFIER, scope: IsoRegistrationAuthority.cdisc_scope)
    used_in = thesarus_set(last_item)
    used_in.first != ct_history.first
  end

  def thesarus_set(last_item)
    query_string = %Q{
      SELECT ?s WHERE {
        #{last_item.to_ref} ^(th:isTopConceptReference/bo:reference) ?s .
        ?s isoT:hasIdentifier ?si . 
        ?si isoI:version ?v 
      } ORDER BY DESC (?v)
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :th, :bo])
    query_results.by_object(:s)
  end

  # Replace children if no change
  def replace_children_if_no_change(previous)
    self.narrower.each_with_index do |child, index|
      previous_child = previous.narrower.select {|x| x.identifier == child.identifier}
      next if previous_child.empty?
      self.narrower[index] = child.replace_if_no_change(previous_child.first)
    end
  end

  # Find parent query. Used by BaseConcept
  def parent_query
    "SELECT DISTINCT ?i WHERE \n" +
    "{ \n" +     
    "  ?s th:narrower #{self.uri.to_ref} .  \n" +
    "  ?s th:identifier ?i . \n" +
    "}"
  end

end