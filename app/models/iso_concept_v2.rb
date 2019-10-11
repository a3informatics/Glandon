# ISO Concept (V2) 
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoConceptV2 < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Concept",
            base_uri: "http://#{ENV["url_authority"]}/IC",
            uri_unique: :label
  
  data_property :label
  object_property :tagged, cardinality: :many, model_class: "IsoConceptSystem::Node"

  validates_with Validator::Field, attribute: :label, method: :valid_label?
  
  # Where Only Or Create
  #    
  # @param label [String] the label required or to be created
  # @return [Thesaurus::Synonym] the found or new synonym object      
  def self.where_only_or_create(label)
    super({label: label}, {uri: create_uri(base_uri), label: label})
  end

  # Add Tags. Add tags if not already present
  #    
  # @param tags [Array] array of IsoConceptSystem items
  # @return [Void] no return
  def add_tags(tags)
    uris = self.tagged.map{|x| x.uri}
    tags.each do |tag|
      self.tagged << tag if !uris.include?(tag.uri)
    end
  end

  # Add Tag. Add a tag if not already present
  #    
  # @param tag [IsoConceptSystem] a single IsoConceptSystem item
  # @return [Void] no return
  def add_tag(tag)
    self.tagged << tag if !self.tagged.map{|x| x.uri}.include?(tag.uri)
  end

end