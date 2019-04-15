class Thesaurus::UnmanagedConcept < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept",
            uri_property: :identifier

  data_property :identifier
  data_property :notation
  data_property :definition
  data_property :extensible
  object_property :extended_with, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept"
  object_property :narrower, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept"
  object_property :is_subset, cardinality: :one, model_class: "Thesaurus::Subset"
  object_property :preferred_term, cardinality: :one, model_class: "Thesaurus::PreferredTerm"
  object_property :synonym, cardinality: :many, model_class: "Thesaurus::Synonym"
  
  validates_with Validator::Field, attribute: :identifier, method: :valid_tc_identifier?
  validates_with Validator::Field, attribute: :notation, method: :valid_submission_value?
  validates_with Validator::Field, attribute: :definition, method: :valid_terminology_property?
  validates_with Validator::Uniqueness, attribute: :identifier, on: :create

  include Thesaurus::BaseConcept

  # Children?
  #
  # @return [Boolean] True if there are children, false otherwise
  def children?
    return extended_with.any? || narrower.any? || !is_subset.blank?
  end

=begin
  # Exists?
  #
  # @param identifier [String] The identifier to be found
  # @return [Boolean] true if found, false otherwise
  def self.exists?(identifier)
    !where_only({identifier: identifier}).nil?
  end

  # Add a child concept
  #
  # @params params [Hash] the params hash containig the concept data {:label, :notation. :preferredTerm, :synonym, :definition, :identifier}
  # @return [Thesaurus::UnmanagedConcept] the object created. Errors set if create failed.
  def add_child(params)
    object = Thesaurus::UnmanagedConcept.from_h(params)
    return object if !object.valid?(:create)
    sparql = Sparql::Update.new
    sparql.default_namespace(self.uri.namespace)
    object.to_sparql(sparql, true)
    sparql.add({:uri => self.uri}, {:prefix => :th, :fragment => "narrower"}, {:uri => object.uri})
    sparql.create
    object
  end

  # Delete. Don't allow if children present.
  #
  # @return [Integer] the number of rows deleted.
  def delete
    return super if !children?
    self.errors.add(:base, "Cannot delete terminology concept with identifier #{self.identifier} due to the concept having children")
    return 0
  end

  # Set Parent
  #
  # @return [Void] no return
  def parent
    results = Sparql::Query.new.query(parent_query, "", [:th])
    Errors.application_error(self.class.name, __method__.to_s, "Failed to find parent for #{identifier}.") if results.empty?
    return results.by_object(:i).first
  end

  # To CSV No Header. A CSV record with no header
  #
  # @return [Array] the CSV record
  def to_csv_no_header
    to_csv_by_key(:identifier, :label, :notation, :synonym, :definition, :preferredTerm)
  end
=end

private

  # Find parent query
  def parent_query
    "SELECT DISTINCT ?i WHERE \n" +
    "{ \n" +     
    "  ?s th:narrower #{self.uri.to_ref} .  \n" +
    "  ?s th:identifier ?i . \n" +
    "}"
  end

end