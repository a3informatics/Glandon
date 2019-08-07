# Thesaurus Search
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus

  module Synonyms

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      # Where Only Or Create Set. Checks the synonym set and creates any new ones. 
      #  Returns the new set as a set of URIs
      #     
      # @param params [String] the set of synonyms as a ";" separated list
      # @return [String] the separator character for a synonym list
      def synonym_separator 
        ";"
      end

    end

    # Where Only Or Create Set. Checks the synonym set and creates any new ones. 
    #  Returns the new set as a set of URIs
    #     
    # @param params [String] the set of synonyms as a ";" separated list
    # @return [Array] array of URIs of the existing or new synonyms
    def where_only_or_create_synonyms(synonyms)
      synonym_parts = synonyms.split(self.class.synonym_separator).map(&:strip) # Split and strip any white space
      results = []
      objects = []
      present = {}
      query_string = %Q{SELECT ?s ?p ?o WHERE
  {
    ?s rdf:type #{Thesaurus::Synonym.rdf_type.to_ref} .
    ?s isoC:label ?l .
    VALUES ?l { #{synonym_parts.map{|x| "'#{x}'"}.join(" ")} }
    ?s ?p ?o .
  }}
      query_results = Sparql::Query.new.query(query_string, "", [:isoC])
      query_results.by_subject.each do |subject, triples|
        objects << Thesaurus::Synonym.from_results(Uri.new(uri: subject), triples)
      end
      objects.map{|x| present[x.label] = x}
      synonym_parts.each do |synonym|
        object = present.key?(synonym) ? present[synonym] : Thesaurus::Synonym.create({uri: Thesaurus::Synonym.create_uri(Thesaurus::Synonym.base_uri), label: synonym})
        results << object
      end
      results
    end

    def synonyms_to_s
      self.synonym.map {|x| x.label}.join("#{self.class.synonym_separator} ")
    end

  end

end