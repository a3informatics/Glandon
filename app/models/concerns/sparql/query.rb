# SPARQL Query. Handles the execution of sparql querries
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql

  class Query

    include Sparql::Namespace
    include Sparql::PrefixClauses
    
    # Execute Query
    #
    # @param query [String] the query string.
    # @param default [Symbol|String] the default namespace either as a symbol prefix or a full namespace as string
    # @param prefixes [Array] an array of prefixes for building the namespaces
    # @return [Array] array of nokogiri nodes containiing the results.
    def query(query, default, prefixes)
      response = CRUD.query("#{build_clauses(default, prefixes)}#{query}")
      Sparql::Query::Results.new(response.body)
    end

  end

end