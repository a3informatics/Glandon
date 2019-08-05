# Thesaurus Synonym
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus::Synonym < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Synonym",
            base_uri: "http://#{ENV["url_authority"]}/SYN",
            uri_unique: :label,
            cache: true,
            key_property: :label

  C_SEPARATOR = ";"

  # Where Only Or Create Set. Checks the synonym set and creates any new ones. 
  #  Returns the new set as a set of URIs
  #     
  # @param params [String] the set of synonyms as a ";" separated list
  # @return [Array] array of URIs of the existing or new synonyms
  def self.where_only_or_create_set(params)
    super(result = params.split(C_SEPARATOR).map(&:strip)) # Split and strip any white space
  end

end