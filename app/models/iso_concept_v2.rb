# ISO Concept (V2) 
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoConceptV2 < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Concept",
            base_uri: "http://#{ENV["url_authority"]}/IC",
            uri_unique: :label
  
  data_property :label

  validates_with Validator::Field, attribute: :label, method: :valid_label?
  
  # Where Only Or Create
  #    
  # @param label [String] the label required or to be created
  # @return [Thesaurus::Synonym] the found or new synonym object      
  def self.where_only_or_create(label)
    super({label: label}, {uri: create_uri(base_uri), label: label})
  end

  # Add Link. Add a object to a collection
  #
  # @param [Symbol] name the name of the property holding the collection
  # @param [Uri] the uri of the object to be unlinked. Does not delete the object
  # @return [Void] no return
  def add_link(name, uri)
    predicate = self.properties.property(name).predicate
    update_query = %Q{
      INSERT
      {
        #{self.uri.to_ref} #{predicate.to_ref} #{uri.to_ref} .
      } WHERE {}
    }
    partial_update(update_query, [])
  end

  # Delete Link. Delete an object from the collection. Does not delete the object.
  #
  # @param [Symbol] name the name of the property holding the collection
  # @param [Uri] the uri of the object to be unlinked. Does not delete the object
  # @return [Void] no return
  def delete_link(name, uri)
    predicate = self.properties.property(name).predicate
    update_query = %Q{ DELETE WHERE { #{self.uri.to_ref} #{predicate.to_ref} #{uri.to_ref} . }}
    partial_update(update_query, [])
  end

end