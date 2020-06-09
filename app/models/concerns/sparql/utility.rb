# SPARQL Utility. A simple set of utility functions
#
# @author Dave Iberson-Hurst
# @since 2.40.0
module Sparql

  class Utility

    # Triple Count
    #
    # @return [Integer] count of triples
    def triple_count
      Sparql::Query.new.query("SELECT (COUNT(?s) as ?count) WHERE {?s ?p ?o}", "", []).by_object(:count).first.to_i
    end

    # Ask? Simple triples exist
    #
    # @param [String] triples a string of triples
    # @param [Array] prefixes an array of prefixes
    # @return [Boolean] true is triples exist
    def ask?(triples, prefixes)
      sparql_ask = "ASK {#{triples}}"
      Sparql::Query.new.query(sparql_ask, "", prefixes).ask?
    end

  end

end