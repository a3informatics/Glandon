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

  # Where Only Or Create Set. Checks the set and creates any new ones. 
  #  Returns the new set as a set of URIs
  #     
  # @param params [Array] the set of labels as an array of strings
  # @return [Array] array of URIs of the existing or new synonyms
  def self.where_only_or_create_set(params)
    results = []
    present = {}
    query_string = %Q{SELECT ?s ?l WHERE
{
  ?s rdf:type #{rdf_type.to_ref} .
  ?s isoC:label ?l .
  VALUES ?l { #{params.map{|x| "'#{x}'"}.join(" ")} }
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoC])
    triples = query_results.by_object_set([:s, :l])
    triples.each {|e| present[e[:l]] = {uri: e[:s], label: e[:l]}}
    params.each do |param|
      uri = present.key?(param) ? present[param][:uri] : create({uri: create_uri(base_uri), label: param}).uri
      results << uri
    end
    results
  end

end