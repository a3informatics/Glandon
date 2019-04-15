# Thesaurus Synonym
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class Thesaurus::Synonym < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Synonym",
            base_uri: "http://#{ENV["url_authority"]}/SYN",
            uri_unique: :true

  # Where Only Or Create
  #    
  # @param [String] :label the label required or to be created
  # @return [Thesaurus::Synonym] the found or new synonym object      
  def self.where_only_or_create(label)
    super({label: label}, {uri: create_uri(base_uri), label: label})
  end
  
end