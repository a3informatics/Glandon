class Thesaurus::UnmanagedConcept < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept",
            uri_property: :identifier,
            key_property: :identifier

  data_property :identifier
  data_property :notation
  data_property :definition
  data_property :extensible
  object_property :extended_with, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept"
  object_property :narrower, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept", children: true
  object_property :is_subset, cardinality: :one, model_class: "Thesaurus::Subset"
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
  #{version_set.map{|x| "{ #{x.uri.to_ref} th:narrower ?cl . #{x.uri.to_ref} ^th:narrower+ ?r . ?r rdf:type th:ManagedConcept . ?r isoT:creationDate ?d . ?r isoT:hasIdentifier ?si1 . ?si1 isoI:version ?v . BIND (#{x.uri.to_ref} as ?e)} "}.join(" UNION\n")}
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
        final_results[key] = {key: entry[:key], id: entry[:uri].to_id, label: entry[:label] , notation: entry[:notation], status: initial_status.dup}
      end
    end
  end

  # Differences
  #
  # @return [Hash] the changes hash. Consists of a set of versions and the changes for each item and version
  def differences
    results =[]
    query_string = %Q{
SELECT DISTINCT ?p WHERE\n
{        
  {
    ?p th:identifier ?pi .
    {
      SELECT DISTINCT ?pi 
      {
        ?parent th:narrower #{self.uri.to_ref} .
        ?parent th:identifier ?pi .
      }
    }
  }
}
}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC, :isoT])
    items = query_results.by_object_set([:p])
    query_string = %Q{
SELECT DISTINCT ?s ?n ?d ?pt ?e ?s ?date (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{self.class.synonym_separator} \") as ?sys) WHERE\n
{        
  VALUES ?p { #{items.map{|x| x[:p].to_ref}.join(" ")} }
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
    results
  end

  # Replace If No Change. Replace the current with the previous if no differences.
  #
  # @return [Thesaurus::UnmanagedConcept] the new object if changes, otherwise the previous object
  def replace_if_no_change(previous)
    return self if previous.nil?
    return previous if !self.diff?(previous)
    replace_children_if_no_change(previous)
    return self
  end

private

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