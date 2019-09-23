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
    return previous if !self.diff?(previous, {ignore: [:has_state, :has_identifier, :origin, :change_description, 
      :creation_date, :last_change_date, :explanatory_comment]})
    replace_children_if_no_change(previous)
    return self
  rescue => e
    byebug
  end

  def merge(other)
    self.errors.clear
    return false if diff_self?(other)
    self_ids = self.narrower.map{|x| x.identifier}
    other_ids = other.narrower.map{|x| x.identifier}
    common_ids = self_ids & other_ids
    missing_ids = other_ids - self_ids
    common_ids.each do |identifier|
      this_child = self.narrower.find{|x| x.identifier == identifier}
      other_child = self.narrower.find{|x| x.identifier == identifier}
      next if !this_child.diff?(other_child)
      msg = "When merging #{self.identifier} a difference was detected in child #{identifier}."
      errors.add(:base, msg) 
      ConsoleLogger.info(self.class.name, __method__.to_s, msg)
    end
    missing_ids.each do |identifier|
      other_child = self.narrower.find{|x| x.identifier == identifier}
      self.narrower << other_child
    end
    !self.errors.empty?
  end

  # Changes Count
  #
  # @param [Integer] window_size the required window size for changes
  # @return [Integer] the number of changes
  def changes_count(window_size)
    items = self.class.history_uris(identifier: self.has_identifier.identifier, scope: self.scope).reverse
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

  # Differences
  #
  # @return [Hash] the differences hash. Consists of a set of versions and the differences for each item and version
  def differences
    results =[]
    items = self.class.history_uris(identifier: self.has_identifier.identifier, scope: self.scope)
    query_string = %Q{
SELECT DISTINCT ?i ?n ?d ?pt ?e ?date (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{self.class.synonym_separator} \") as ?sys) ?s WHERE\n
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
} GROUP BY ?i ?n ?d ?pt ?e ?s ?date ORDER BY ?i
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

private

  def diff_self?(other)
    return false if !diff?(other, {ignore: [:has_state, :has_identifier, :origin, :change_description, :creation_date, :last_change_date, 
      :explanatory_comment, :narrower, :extends, :subsets]}))
    msg = "When merging #{self.identifier} a difference was detected in the item."
    self.errors.add(:base, msg) 
    ConsoleLogger.info(self.class.name, __method__.to_s, msg)
    true
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