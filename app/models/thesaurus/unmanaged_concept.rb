class Thesaurus::UnmanagedConcept < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept",
            uri_property: :identifier,
            key_property: :identifier

  data_property :identifier
  data_property :notation
  data_property :definition
  data_property :extensible
  object_property :narrower, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept", children: true
  object_property :preferred_term, cardinality: :one, model_class: "Thesaurus::PreferredTerm"
  object_property :synonym, cardinality: :many, model_class: "Thesaurus::Synonym"
  
  validates_with Validator::Field, attribute: :identifier, method: :valid_tc_identifier?
  validates_with Validator::Field, attribute: :notation, method: :valid_submission_value?
  validates_with Validator::Field, attribute: :definition, method: :valid_terminology_property?
  validates_with Validator::Uniqueness, attribute: :identifier, on: :create

  include Thesaurus::BaseConcept
  include Thesaurus::Identifiers
  include Thesaurus::Synonyms

  def self.create(params, parent)
    object = new(params)
    object.uri = object.create_uri(parent.uri)
    object.create_or_update(:create) if object.valid?(:create)
    object
  end
  
  # Changes Count
  #
  # @param [Integer] window_size the required window size for changes
  # @return [Integer] the number of changes
  def changes_count(window_size)
    items = self.class.where(identifier: self.identifier)
    items.count < window_size ? items.count : window_size
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
    items = self.class.where(identifier: self.identifier)
    first_index = items.index {|x| x.uri == self.uri}    
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
  #{version_set.map{|x| "{ #{x.uri.to_ref} ^th:narrower ?cl . #{x.uri.to_ref} ^th:narrower+ ?r . ?r rdf:type th:ManagedConcept . ?r isoT:creationDate ?d . ?r isoT:hasIdentifier ?si1 . ?si1 isoI:version ?v . BIND (#{x.uri.to_ref} as ?e)} "}.join(" UNION\n")}
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
        final_results[key] = {key: entry[:key], identifier: entry[:key], id: entry[:uri].to_id, label: entry[:label] , notation: entry[:notation], status: initial_status.dup}
      end
    end
    final_results
  end

  # Differences
  #
  # @return [Hash] the changes hash. Consists of a set of versions and the changes for each item and version
  def differences
    results = []
    items = item_set
    item_was_deleted_info = deleted_from_ct_version(items.first)
    query_string = %Q{
SELECT DISTINCT ?s ?n ?d ?pt ?e ?s ?date (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{self.class.synonym_separator} \") as ?sys) WHERE\n
{
  SELECT DISTINCT ?i ?n ?d ?pt ?e ?del ?s ?sy ?date WHERE   
  {      
    VALUES ?p { #{items.map{|x| x.to_ref}.join(" ")} }
    {
      ?p th:narrower ?s .
      ?p isoT:creationDate ?date .
      ?s th:identifier '#{self.identifier}' .
      ?s th:notation ?n .
      ?s th:definition ?d .
      ?s th:extensible ?e .
      OPTIONAL {?s th:preferredTerm/isoC:label ?pt .}
      OPTIONAL {?s th:synonym/isoC:label ?sy .}
    }
  } ORDER BY ?i ?sy
} GROUP BY ?s ?n ?d ?pt ?e ?s ?date ORDER BY ?date
}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC, :isoT])
    previous = nil
    x = query_results.by_object_set([:n, :d, :e, :pt, :sys, :s, :date])
    x.each do |x|
      current = {identifier: self.identifier, notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], extensible: x[:e].to_bool, definition: x[:d]}
      if !ignore?(current, previous)  
        diffs = previous.nil? ? difference_record_baseline(current) : difference_record(current, previous)
        results << {id: x[:s].to_id, date: x[:date].to_time_with_default.strftime("%Y-%m-%d"), differences: diffs}
      end
      previous = current
    end
    if item_was_deleted_info[:deleted]
      results << {id: nil, date: item_was_deleted_info[:ct].creation_date.strftime("%Y-%m-%d"), differences: difference_record_deleted} 
    end
    results
  end

  # Replace If No Change. Replace the current with the previous if no differences.
  #
  # @return [Thesaurus::UnmanagedConcept] the new object if changes, otherwise the previous object
  def replace_if_no_change(previous)
    return self if previous.nil?
    return previous if !self.diff?(previous, {ignore: [:tagged]})
    replace_children_if_no_change(previous)
    return self
  end

  def add_additional_tags(previous, set)
    return if previous.nil?
    missing = previous.tagged - self.tagged
    missing.each {|x| set << {subject: self.uri, object: x.uri}}
  end

  # To CSV No Header. A CSV record with no header
  def to_csv_data
    data = to_a_by_key(:identifier, :extensible, :label, :notation, :definition)
    data.insert(4, self.synonyms_to_s)
    data.insert(6, self.preferred_term.label)
    data
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

  def item_set
    query_string = %Q{
      SELECT DISTINCT ?s WHERE\n
      {        
        #{self.uri.to_ref} ^th:narrower+ ?p .
        ?p th:identifier ?pi .
        ?s th:identifier ?pi .
        ?s th:narrower+/th:identifier "#{self.identifier}" .
        ?s isoT:hasIdentifier ?si . 
        ?si isoI:version ?v 
      } ORDER BY DESC (?v)
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :th, :bo])
    query_results.by_object(:s)
  end

  # Ignore for no change
  def ignore?(current, previous)
    return false if previous.nil?
    !difference?(current, previous)  
  end

  # Replace the child if no change.
  def replace_children_if_no_change(previous)
    self.narrower.each_with_index do |child, index|
      previous_child = previous.narrower.select {|x| x.identifier == child.identifier}
      next if previous_child.empty?
      self.narrower[index] = child.replace_with_no_change(previous_child)
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