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
  #{version_set.map{|x| "{ #{x[:e].to_ref} th:narrower ?cl . #{x[:e].to_ref} ^th:narrower+ ?r . ?r rdf:type th:ManagedConcept . ?r isoT:creationDate ?d . ?r isoT:hasIdentifier ?si1 . ?si1 isoI:version ?v . BIND (#{x[:e].to_ref} as ?e)} "}.join(" UNION\n")}
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

  def differences
    raw_results = {}
    results = []

    # Get the version set. Work out if we need a dummy first one.
    items = self.class.where(identifier: self.identifier)
    version_set = items.map{|x| x.uri}

    # Get the raw results
    query_string = %Q{SELECT ?e ?v ?d ?s WHERE
{
  #{version_set.map{|x| "{ #{x.to_ref} ^th:narrower+ ?e . ?e rdf:type th:ManagedConcept . ?e isoT:creationDate ?d . ?e isoT:hasIdentifier ?si1 . ?si1 isoI:version ?v . BIND (#{x.to_ref} as ?s) } "}.join(" UNION\n")}
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th])
    triples = query_results.by_object_set([:s, :e, :v, :d])
    previous_id = ""
    triples.each do |entry|
      uri = entry[:s]
      next if raw_results.key?(uri.to_s) || previous_id == uri.to_id     
      raw_results[uri.to_s] = {id: uri.to_id, version: entry[:v].to_i, date: entry[:d].to_time_with_default.strftime("%Y-%m-%d")}
      previous_id = uri.to_id 
    end

    # Build results
    previous = nil
    raw_results.each do |uri, version|
      item = items.find {|x| x.uri == uri}
      Errors.application_error(self.class.name, __method__.to_s, "Nil item detected during differences.") if item.nil?
      item.preferred_term_objects
      item.synonym_objects
      version[:differences] = previous.nil? ? item.difference_baseline : item.difference(previous)
      results << version
      previous = item
    end
    results
  end

def replace_if_no_change(previous)
    return self if previous.nil?
    return previous if !self.diff?(previous)
    replace_children_if_no_change(previous)
    return self
  end

private

  #
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