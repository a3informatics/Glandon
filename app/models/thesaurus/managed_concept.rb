class Thesaurus::ManagedConcept < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#ManagedConcept",
            uri_property: :identifier,
            key_property: :identifier

  data_property :identifier
  data_property :notation
  data_property :definition
  data_property :extensible, default: false
  object_property :narrower, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept", children: true
  object_property :extends, cardinality: :one, model_class: "Thesaurus::ManagedConcept", delete_exclude: true
  object_property :subsets, cardinality: :one, model_class: "Thesaurus::ManagedConcept", delete_exclude: true
  object_property :preferred_term, cardinality: :one, model_class: "Thesaurus::PreferredTerm"
  object_property :synonym, cardinality: :many, model_class: "Thesaurus::Synonym"
  object_property :is_ordered, cardinality: :one, model_class: "Thesaurus::Subset"

  validates_with Validator::Field, attribute: :identifier, method: :valid_tc_identifier?
  validates_with Validator::Field, attribute: :notation, method: :valid_submission_value?
  validates_with Validator::Field, attribute: :definition, method: :valid_terminology_property?
  #validates_with Validator::Uniqueness, attribute: :identifier, on: :create

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

  # Subset? Is this item subsetting another managed concept
  #
  # @result [Boolean] return true if this instance is a subset of another
  def subset?
    !self.subset_of.nil?
  end

  def subset_of
    query_string = %Q{SELECT ?s WHERE { #{self.uri.to_ref} th:subsets ?s }}
    query_results = Sparql::Query.new.query(query_string, "", [:th])
    return query_results.empty? ? nil : query_results.by_object_set([:s]).first[:s]
  end

  # Finds the subsets of this Thesaurus::ManagedConcept
  #
  # @return [Array] Uri of subsets referring to this instance, nil if none found
  def subsetted_by
    query_string = %Q{SELECT ?s WHERE { #{self.uri.to_ref} ^th:subsets ?s }}
    query_results = Sparql::Query.new.query(query_string, "", [:th])
    return query_results.empty? ? nil : query_results.by_object_set([:s])
  end

  # Replace If No Change. Replace the current with the previous if no differences.
  #
  # @param previous [Thesaurus::UnmanagedConcept] previous item
  # @return [Thesaurus::UnmanagedConcept] the new object if changes, otherwise the previous object
  def replace_if_no_change(previous)
    return self if previous.nil?
    return previous if !self.diff?(previous, {ignore: [:has_state, :has_identifier, :origin, :change_description,
      :creation_date, :last_change_date, :explanatory_comment, :tagged]})
    replace_children_if_no_change(previous)
    return self
  end

  # Add additional tags
  #
  # @param previous [Thesaurus::UnmanagedConcept] previous item
  # @param set [Array] set of tags objects
  # @return [Void] no return
  def add_additional_tags(previous, set)
    return if previous.nil?
    missing =  previous.tagged.map{|x| x.uri.to_s}  - self.tagged.map{|x| x.uri.to_s}
    missing.each {|x| set << {subject: self.uri, object: Uri.new(uri: x)}}
    add_child_additional_tags(previous, set)
  end

  # Merge. Merge two concepts. Concepts must be the same with common children being the same.
  #
  # @result [Boolean] returns true if the concepts merged.
  def merge(other)
    self.errors.clear
    return false if diff_self?(other)
    self_ids = self.narrower.map{|x| x.identifier}
    other_ids = other.narrower.map{|x| x.identifier}
    common_ids = self_ids & other_ids
    missing_ids = other_ids - self_ids
    common_ids.each do |identifier|
      this_child = self.narrower.find{|x| x.identifier == identifier}
      other_child = other.narrower.find{|x| x.identifier == identifier}
      next if children_are_the_same?(this_child, other_child)
      uri = Uri.new(uri: "http://www.temp.com/") # Temporary nasty
      this_child.uri = uri
      other_child.uri = uri
      record = this_child.difference_record(this_child.simple_to_h, other_child.simple_to_h)
      msg = "When merging #{self.identifier} a difference was detected in child #{identifier}\n#{record.map {|k, v| "#{k}: #{v[:previous]} -> #{v[:current]}" if v[:status] != :no_change}.compact.join("\n")}"
      errors.add(:base, msg)
      ConsoleLogger.info(self.class.name, __method__.to_s, msg)
    end
    missing_ids.each do |identifier|
      other_child = other.narrower.find{|x| x.identifier == identifier}
      self.narrower << other_child
    end
    self.tagged = self.tagged | other.tagged
    self.errors.empty?
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
  # @param [Thesaurus::ManagedConcept] last Reference to the second terminology from the timeline selection
  # @param [Array] actual_versions the actual versions (dates) chosen by the user on the timeline
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
      if !previous_version.nil?
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
  # @param [Thesaurus::ManagedConcept] last Reference to the second terminology from the timeline selection
  # @param [Array] actual_versions the actual versions (dates) chosen by the user on the timeline
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

    # FIRST
    x = query_results.by_object_set([:i, :n, :d, :e, :pt, :sys, :s, :date]).first
    first = {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], extensible: x[:e].to_bool, definition: x[:d]}
    diffs = difference_record_baseline(first)
    results << {id: x[:s].to_id, date: actual_versions[0], differences: diffs}

    # SECOND (LAST)
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

  # Create. Create a managed concept
  #
  # @return [Object] the created object. May contain errors if unsuccesful.
  def self.create
    child = Thesaurus::ManagedConcept.empty_concept
    # Following is a check to ensure only generated identifiers for the current implementation.
    Errors.application_error(self.name, "create", "Not configured to generate a code list identifier.") unless Thesaurus::ManagedConcept.generated_identifier?
    child[:identifier] = Thesaurus::ManagedConcept.generated_identifier? ? Thesaurus::ManagedConcept.new_identifier : params[:identifier]
    super(child)
  end

  # Clone. Clone the object taking care over the type of concept
  #
  # @return [Thesaurus::ManagedConcept] a clone of the object
  def clone
    self.narrower_links
    self.preferred_term_links
    self.synonym_links
    if self.subset?
      self.is_ordered_objects
      self.is_ordered = self.is_ordered.clone
      self.subsets_links
    elsif self.extension?
      self.extends_links
    end
    object = super
  end

  # Delete or Unlink. Delete the managed concept. Processing depends on the type of the concept.
  #
  # @return [Void] no return
  def delete_or_unlink(parent_object=nil)
    self.children_objects
    if parent_object.nil? && no_parents?
      # No parent specified and no parents linked to this item, delete
      delete_with
    elsif parent_object.nil?
      # No parent specified and parents, do nothing, as we cannot 
      self.errors.add(:base, "The code list cannot be deleted as it is in use.") # error, in use
      0
    elsif multiple_parents? 
      # Deselect from quoted parent
      parent_object.deselect_children({id_set: [self.uri.to_id]})
      1
    elsif self.children? && !self.extension? && !self.subset?
      # Parent specified, not extension or subset but children present. Dont delete.
      self.errors.add(:base, "The code list cannot be deleted as there are children present.") # error, children present for normal code list
      0
    else
      # Parent specified, no children, delete
      delete_with(parent_object)
    end
  end

  # Set With Indicators Paginated
  #
  # @params [Hash] params the params hash
  # @option params [String] :type the type, either :all, :normal, :subsets, :extensions. 
  #   note that :all does not filter on owner while the others filter on the repository owner.
  # @option params [String] :offset the offset to be obtained
  # @option params [String] :count the count to be obtained
  # @return [Array] array of hashes containing the child data
  def self.set_with_indicators_paginated(params) 
    owner = ::IsoRegistrationAuthority.repository_scope.uri.to_ref
    filter_clause = "FILTER (?so = false && ?eo = false)"
    owner_clause = "?x isoT:hasIdentifier/isoI:hasScope #{owner} . BIND (#{owner} as ?ns)"
    case params[:type].to_sym
      when :all
        filter_clause = ""
        owner_clause = "?x isoT:hasIdentifier/isoI:hasScope ?ns ."
      when :normal
        # default
      when :subsets
        filter_clause = "FILTER (?so = true && ?eo = false)"
      when :extensions
        filter_clause = "FILTER (?eo = true && ?so = false)"
      else
        # default
    end
    results =[]
    query_string = %Q{
      SELECT DISTINCT ?s ?i ?n ?d ?pt ?e ?eo ?ei ?so ?si ?o ?v ?sci ?ns ?count
        (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{self.synonym_separator} \") as ?sys) 
        (GROUP_CONCAT(DISTINCT ?t ;separator=\"#{IsoConceptSystem.tag_separator} \") as ?gt) WHERE
      {
        SELECT DISTINCT ?i ?n ?d ?pt ?e ?s ?sy ?t ?eo ?ei ?so ?si ?o ?v ?sci ?ns ?count WHERE
        {
          ?s rdf:type th:ManagedConcept .
          ?s isoT:hasIdentifier/isoI:version ?v .
          ?s isoT:hasIdentifier/isoI:identifier ?sci .
          {               
            SELECT DISTINCT ?sci ?ns (max(?lv) AS ?v) (count(?lv) AS ?count) WHERE              
            {               
              ?x rdf:type th:ManagedConcept .           
              ?x isoT:hasIdentifier/isoI:version ?lv . 
              ?x isoT:hasIdentifier/isoI:identifier ?sci . 
              #{owner_clause}
            } group by ?sci ?ns    
          }           
          BIND (EXISTS {?s th:extends ?xe1} as ?eo)
          BIND (EXISTS {?s th:subsets ?xs1} as ?so)
          BIND (EXISTS {?s ^th:extends ?xe2} as ?ei)
          BIND (EXISTS {?s ^th:subsets ?xs2} as ?si)
          #{filter_clause}
          ?s th:identifier ?i .
          ?s th:notation ?n .
          ?s th:definition ?d .
          ?s th:extensible ?e .
          ?s th:preferredTerm/isoC:label ?pt .
          ?s isoT:hasIdentifier/isoI:hasScope/isoI:shortName ?o .
          OPTIONAL {?s th:synonym/isoC:label ?sy }
          OPTIONAL {?s isoC:tagged/isoC:prefLabel ?t }
        } ORDER BY ?i ?sy ?t
      } GROUP BY ?i ?n ?d ?pt ?e ?s ?eo ?ei ?so ?si ?o ?v ?sci ?ns ?count ORDER BY ?i OFFSET #{params[:offset].to_i} LIMIT #{params[:count].to_i}
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC, :isoT, :isoI])
    query_results.by_object_set([:i, :n, :d, :e, :pt, :sys, :gt, :s, :o, :eo, :ei, :so, :si, :sci, :ns, :count]).each do |x|
  begin
      indicators = {current: false, extended: x[:ei].to_bool, extends: x[:eo].to_bool, version_count: x[:count].to_i, subsetted: x[:si].to_bool, subset: x[:so].to_bool}
      results << {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], extensible: x[:e].to_bool, 
        definition: x[:d], id: x[:s].to_id, tags: x[:gt], indicators: indicators, owner: x[:o], scoped_identifier: x[:sci], scope_id: x[:ns].to_id}
  rescue => e
    #byebug
puts colourize("+++++ Selection Query Exception +++++\n#{x}\n+++++", "red")
  end
    end
    results
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

  def valid_collection?
    notations = self.narrower.map{|x| x.notations}
    notations.uniq.length == notations.length
  end

  # Change notes paginated query
  def change_notes_paginated(params)
    results = []
    count = params[:count].to_i 
    offset = params[:offset].to_i 
    query_string = %Q{
      SELECT ?s ?e ?d ?r ?txt ?i ?n ?l WHERE { 
        {
        #{self.uri.to_ref} th:identifier ?i .
        #{self.uri.to_ref} th:notation ?n .
        #{self.uri.to_ref} isoC:label ?l .
        #{self.uri.to_ref} ^(ba:current/bo:reference) ?s . 
        ?s ba:userReference ?e .
        ?s ba:timestamp ?d .
        ?s ba:reference ?r .
        ?s ba:description ?txt .
        } 
        UNION 
        { 
        #{self.uri.to_ref} th:narrower ?c . 
        ?c ^(ba:current/bo:reference) ?s .
        ?s ba:userReference ?e .
        ?s ba:timestamp ?d .
        ?s ba:reference ?r .
        ?s ba:description ?txt .
        ?c th:identifier ?i .
        ?c th:notation ?n .
        ?c isoC:label ?l .
        } 
    } ORDER BY (?i) LIMIT #{count} OFFSET #{offset} 
  }

    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :th, :bo, :ba])
    query_results.by_object_set([:s, :e, :d, :r, :txt, :i, :n, :l]).each do |x|
      results << {cn: x[:s].to_id, user_reference: x[:e], date: x[:d], reference: x[:r], description: x[:txt], identifier: x[:i], notation: x[:n], label: x[:l] }
    end
    results

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

  # Delete with all child items (extensions, subset and child code list items)
  def delete_with(parent_object=nil)
    parts = []
    parts << "{ BIND (#{uri.to_ref} as ?s) . ?s ?p ?o }"
    parts << "{ #{uri.to_ref} isoT:hasIdentifier ?s . ?s ?p ?o}" 
    parts << "{ #{uri.to_ref} isoT:hasState ?s . ?s ?p ?o }"
    parts << "{ #{self.uri.to_ref} (th:isOrdered*/th:members*/th:memberNext*) ?s . ?s ?p ?o }"
    parts << "{ #{self.uri.to_ref} th:narrower ?s . ?s ?p ?o . FILTER NOT EXISTS { ?e th:narrower ?s . }}"
    if !parent_object.nil?
      parts << "{ #{parent_object.uri.to_ref} th:isTopConceptReference ?s . ?s rdf:type ?t . ?t rdfs:subClassOf bo:Reference . ?s bo:reference #{uri.to_ref} . ?s ?p ?o }" 
      parts << "{ #{parent_object.uri.to_ref} th:isTopConceptReference ?o . ?o rdf:type ?t . ?t rdfs:subClassOf bo:Reference . ?o bo:reference #{uri.to_ref} . 
        BIND (#{parent_object.uri.to_ref} as ?s) . BIND (th:isTopConceptReference as ?p) .}"
      parts << "{ BIND (#{parent_object.uri.to_ref} as ?s) . BIND (th:isTopConceptReference as ?p) . BIND (#{uri.to_ref} as ?o) }" 
    end
    query_string = "DELETE { ?s ?p ?o } WHERE {{ #{parts.join(" UNION\n")} }}"
  puts "*****\n#{query_string}\n*****"
    results = Sparql::Update.new.sparql_update(query_string, uri.namespace, [:isoT, :th, :bo])
    1  
  end

  # Are children are the same
  def children_are_the_same?(this_child, other_child)
    result = this_child.diff?(other_child, {ignore: [:tagged]})
    return false if result
    this_child.tagged = this_child.tagged | other_child.tagged
    return true
  end

  # Was the item deleted from CT version
  def deleted_from_ct_version(last_item)
    ct_history = Thesaurus.history_uris(identifier: CdiscTerm::C_IDENTIFIER, scope: IsoRegistrationAuthority.cdisc_scope)
    used_in = thesarus_set(last_item)
    item_was_deleted = used_in.first != ct_history.first
    return {deleted: item_was_deleted, ct: nil} if !item_was_deleted
    deleted_version = ct_history.index{|x| x == used_in.first} - 1
    ct = Thesaurus.find_minimum(ct_history[deleted_version])
    {deleted: item_was_deleted, ct: ct}
  end

  # Deleted from CT
  def deleted_from_ct?(last_item)
    ct_history = Thesaurus.history_uris(identifier: CdiscTerm::C_IDENTIFIER, scope: IsoRegistrationAuthority.cdisc_scope)
    used_in = thesarus_set(last_item)
    used_in.first != ct_history.first
  end

  # Thesaurus set
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

  # Different from self
  def diff_self?(other)
    return false if !diff?(other, {ignore: [:has_state, :has_identifier, :origin, :change_description, :creation_date, :last_change_date,
      :explanatory_comment, :narrower, :extends, :subsets, :tagged]})
    msg = "When merging #{self.identifier} a difference was detected in the item"
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

  # Add additional tags
  def add_child_additional_tags(previous, set)
    self.narrower.each_with_index do |child, index|
      previous_child = previous.narrower.select {|x| x.identifier == child.identifier}
      next if previous_child.empty?
      child.add_additional_tags(previous_child.first, set)
    end
  end

  # Find parent query. Used by BaseConcept
  def parent_query
    "SELECT DISTINCT ?s WHERE \n" +
    "{ \n" +
    "  #{self.uri.to_ref} ^(th:isTopConceptReference/bo:reference) ?s .  \n" +
    "}"
  end

end
