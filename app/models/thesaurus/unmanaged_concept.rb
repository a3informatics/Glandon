# Thesaurus UNmanaged Concept.
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Thesaurus::UnmanagedConcept < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept",
            uri_property: :identifier,
            key_property: :identifier

  data_property :identifier
  data_property :notation
  data_property :definition
  data_property :extensible, default: false
  object_property :narrower, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept", children: true
  object_property :preferred_term, cardinality: :one, model_class: "Thesaurus::PreferredTerm"
  object_property :synonym, cardinality: :many, model_class: "Thesaurus::Synonym"

  validates_with Validator::Field, attribute: :identifier, method: :valid_tc_identifier?
  validates_with Validator::Field, attribute: :notation, method: :valid_submission_value?
  validates_with Validator::Field, attribute: :definition, method: :valid_terminology_property?
  validates_with Validator::Klass, property: :preferred_term, presence: true
  validates_with Validator::Klass, property: :synonym
  validate :valid_parent_child?

  include Thesaurus::BaseConcept
  include Thesaurus::Identifiers
  include Thesaurus::Synonyms
  include Thesaurus::Validation

  # Valid Parent Child? Check this child in the context of the parent
  #
  # @return [Boolean] true if valid, false otherwise
  def valid_parent_child?
    return true if @parent_for_validation.nil? # Don't validate if we don't know about a parent
    @parent_for_validation.valid_child?(self)
  end

  # Allowed To Update? Final checker to make sure we can really update the item
  #
  # @params [Hash] params the parameters as passed to update
  # @return [Boolean] true if ok, false otherwise
  def allowed_to_update?(params)
    ra_owner = IsoRegistrationAuthority.owner
    return true unless Sparql::Query.new.query("ASK {#{self.uri.to_ref} ^th:narrower+/isoT:hasState/isoR:byAuthority ?ra . FILTER (?ra != #{ra_owner.uri.to_ref}) }", "", [:th, :isoT, :isoR]).ask?
    keys = params.slice(:synonym, :preferred_term, :notation, :definition).keys
    self.errors.add(keys.empty? ? :base : keys.first, "not allowed to update this item, it is not owned by the repository")
    false
  end

  # Create. Create an object
  #
  # @param [Hash] params the parameters
  # @param [Object] parent the parent object
  # @return [Thesaurus::UnmanagedConcept] the resulting object
  def self.create(params, parent)
    params[:parent_uri] = parent.uri
    super(params, parent)
  end

  # Delete or Unlink. Delete or Unlink child
  #
  # @param [Object] parent_object the parent object
  # @return [Void] no return
  def delete_or_unlink(parent_object)
    #return 0 if self.has_children? # @todo will be required for hierarchical terminologies
    Errors.application_error(self.class.name, __method__.to_s, "Attempting to delete from code list that is not owned.") unless parent_object.owned?
    if multiple_parents?
      delete_or_unlink_references(parent_object)
      delete_rank_member(self, parent_object) if parent_object.ranked?
      parent_object.delete_link(:narrower, self.uri)
      #parent_object.delete_link(:refers_to, self.uri)
      1
    elsif referred_to?(parent_object)
      delete_or_unlink_references(parent_object)
      delete_rank_member(self, parent_object) if parent_object.ranked?
      parent_object.delete_link(:narrower, self.uri)
      parent_object.delete_link(:refers_to, self.uri)
      1
    else
      Errors.application_error(self.class.name, __method__.to_s, "Attempting to delete an code list item that is not owned.") if not_owned?
      self.delete_references
      delete_rank_member(self, parent_object) if parent_object.ranked?
      self.delete_with_links
    end
  end

  # Update With Clone. Update the object. Clone if there are multiple parents,
  #
  # @param [Hash] params the parameters to be updated
  # @param [Object] parent_object the parent object
  # @return [Thesarus::UnmanagedConcept] the object, either new or the cloned new object with updates
  def update_with_clone(params, parent_object)
    return self unless allowed_to_update?(params)
    @parent_for_validation = parent_object
    if multiple_parents?
      object = self.clone(parent_object.uri)
      object.uri = object.create_uri(parent_object.uri)
      tx = transaction_begin
      object.update(params)
      self.create_custom_properties(object, parent_object, tx)
      self.remove_context(parent_object, tx)
      parent_object.replace_link(:narrower, self.uri, object.uri)
      parent_object.replace_link(:refers_to, self.uri, object.uri)
      transaction_execute
      object
    else
      self.update(params)
    end
  end

  # Changes Count
  #
  # @param [Integer] window_size the required window size for changes
  # @return [Integer] the number of changes
  def changes_count(window_size)
    items = self.class.where(identifier: self.identifier)
    items.count < window_size ? items.count : window_size
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
  # @param previous [Thesaurus::UnmanagedConcept] previous item
  # @return [Thesaurus::UnmanagedConcept] the new object if changes, otherwise the previous object
  def replace_if_no_change(previous, add_properties=[])
    return self if previous.nil?
    if !self.custom_properties_diff?(previous) && !self.diff?(previous, {ignore: []})
      add_properties.each{|x| previous.instance_variable_set("@#{x}", self.instance_variable_get("@#{x}"))}
      return previous
    else
      replace_children_if_no_change(previous)
      return self
    end
  end

  # To CSV No Header. A CSV record with no header
  #
  # @return [Array] array of items
  def to_csv_data
    data = to_a_by_key(:identifier, :extensible, :label, :notation, :definition)
    data.insert(4, self.synonyms_to_s)
    data.insert(6, self.preferred_term.label)
    data
  end

  # Supporting Edit? Can the item be edited for supporting information, e.g. tags, change notes etc.
  #
  # @return [Boolean] true if edit permitted, false otherwise
  def supporting_edit?
    !not_owned?
  end

  # Referred To?
  #
  # @param [Thesaurus::ManagedConcept] parent the parent
  # @return [Boolean] true if there is a refered to relationship froom the parent, false otherwise
  def referred_to?(parent)
    Sparql::Utility.new.ask?("#{parent.uri.to_ref} th:refersTo #{self.uri.to_ref}", [:th])
  end

  # Not Owned?
  #
  # @return [Boolean] true if not owned, false otherwise
  def not_owned?
    parents.each {|uri| return true unless Thesaurus::ManagedConcept.find_minimum(uri).owned?}
    false
  end

  # Latest Parent
  #
  # @return [URI] the latest parent
  def latest_parent
    results = Sparql::Query.new.query(ordered_parent_query, "", [:th, :isoT, :isoI])
    return results.by_object(:s).last
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
    return {deleted: false, ct: nil} if Thesaurus::ManagedConcept.find_minimum(parents.first).owned?
    ct_history = Thesaurus.history_uris(identifier: CdiscTerm.identifier, scope: IsoRegistrationAuthority.cdisc_scope)
    used_in = thesarus_set(last_item)
    item_was_deleted = used_in.first != ct_history.first
    return {deleted: item_was_deleted, ct: nil} if !item_was_deleted
    deleted_version = ct_history.index{|x| x == used_in.first} - 1
    ct = Thesaurus.find_minimum(ct_history[deleted_version])
    {deleted: item_was_deleted, ct: ct}
  end

  def deleted_from_ct?(last_item)
    return false if Thesaurus::ManagedConcept.find_minimum(parents.first).owned?
    ct_history = Thesaurus.history_uris(identifier: CdiscTerm.identifier, scope: IsoRegistrationAuthority.cdisc_scope)
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
  def replace_children_if_no_change(previous, add_properties=[])
    self.narrower.each_with_index do |child, index|
      previous_child = previous.narrower.select {|x| x.identifier == child.identifier}
      next if previous_child.empty?
      self.narrower[index] = child.replace_with_no_change(previous_child)
    end
  end

  # Find parent query. Used by BaseConcept. Note the query is looking for actual parents
  # and not references to it. Parents are different versions of the same item.
  def parent_query
    %Q{
      SELECT DISTINCT ?s WHERE
      {
        #{self.uri.to_ref} ^th:narrower ?s .
        FILTER(NOT EXISTS {?s th:refersTo #{self.uri.to_ref}})
      }
    }
  end

  # Find parent query ordered by version. Note the query is looking for actual parents
  # and not references to it. Parents are different versions of the same item.
  def ordered_parent_query
    %Q{
      SELECT DISTINCT ?s WHERE
      {
        #{self.uri.to_ref} ^th:narrower ?s .
        FILTER(NOT EXISTS {?s th:refersTo #{self.uri.to_ref}})
        ?s isoT:hasIdentifier ?si .
        ?si isoI:version ?v .
      } ORDER BY (?v)
    }
  end

  # Delete rank member.
  def delete_rank_member(uc, parent_uc)
    rank_uri = parent_uc.is_ranked
    rank = Thesaurus::Rank.find(rank_uri)
    rank.remove_member(rank.member(uc, parent_uc).first)
  end

end
