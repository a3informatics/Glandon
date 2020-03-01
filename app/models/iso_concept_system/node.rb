class IsoConceptSystem::Node < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode",
            base_uri: "http://#{ENV["url_authority"]}/CSN",
            uri_unique: true

  data_property :pref_label
  data_property :description
  object_property :narrower, cardinality: :many, model_class: "IsoConceptSystem::Node"

  validates_with Validator::Field, attribute: :pref_label, method: :valid_non_empty_label?
  validates_with Validator::Field, attribute: :description, method: :valid_long_name?

  include IsoConceptSystem::Core

  # Destroy this object. Prevents delete if children are present or items are tagged with it or a child.
  #
  # @return [Integer] the count of objects deleted. Will be 1 or 0
  def delete
    query_results = Sparql::Query.new.query(check_delete_query, "", [:isoC])
    items = query_results.by_object_set([:i])
    if items.empty?
      delete_with_links
      return 1
    else
      self.errors.add(:base, "Cannot destroy tag as it has children tags or the tag or a child tag is currently in use.")
      return 0
    end
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
    %Q{ SELECT ?i WHERE 
      {
        { 
          #{self.uri.to_ref} #{predicate.to_ref} ?i 
        } 
        UNION 
        { 
          #{self.uri.to_ref} #{predicate.to_ref}* ?i .
          ?x isoC:tagged ?i 
        }
      }
    }
  end

end
