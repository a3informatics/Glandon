# SPARQL Utility. A simple set of utility functions
#
# @author Dave Iberson-Hurst
# @since 2.40.0
module Sparql

  class Utility

    include Sparql::CRUD

    # Triple Count
    #
    # @return [Integer] count of triples
    def triple_count()
      Sparql::Query.new.query("SELECT (COUNT(?s) as ?count) WHERE {?s ?p ?o}", "", []).by_object(:count).first.to_i
    end

  end

end