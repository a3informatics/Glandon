class IsoConceptSystem::Node < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode",
            base_uri: "http://#{ENV["url_authority"]}/CSN",
            uri_unique: true
  
  data_property :pref_label
  data_property :description
  object_property :narrower, cardinality: :many, model_class: "IsoConceptSystem::Node"

  validates_with Validator::Field, attribute: :pref_label, method: :valid_label?
  validates_with Validator::Field, attribute: :description, method: :valid_long_name?
 
  include IsoConceptSystem::Core

  # Destroy this object. Prevents delete if children are present or items are tagged with it.
  #
  # @return [Integer] the count of objects deleted. Will be 1
  def delete
    query_results = Sparql::Query.new.query(check_delete_query, "", [:isoC])
    items = query_results.by_object_set([:i])
    items.empty? ? delete_with_links : self.errors.add(:base, "Cannot destroy tag as it has children tags or is currently in use.")
    1
  end

  # Child Property. The child property
  #
  # @return [Symbol] the :narrower property
  def children_property
    :narrower
  end

private

  # Query for checking if a node can be deleted
  def check_delete_query
    predicate = self.properties.property(:narrower).predicate
    %Q{ SELECT ?i WHERE {
      { #{self.uri.to_ref} #{predicate.to_ref} ?i } UNION { ?i isoC:tagged #{self.uri.to_ref} }
    }}
  end

end