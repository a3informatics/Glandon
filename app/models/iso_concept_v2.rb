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
  # @param [Object] object the object to be linked
  # @return [Void] no return
  def add_link(name, object)
    predicate = self.properties.property(name).predicate
    update_query = %Q{
      INSERT
      {
        #{self.uri.to_ref} #{predicate.to_ref} #{object.uri.to_ref} .
      } WHERE {}
    }
    partial_update(update_query, [])
  end

end