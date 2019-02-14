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
      sparql = "#{build_clauses(default, prefixes)}#{query}"
      response = CRUD.query(sparql)
      raise_error(sparql) if !response.success?
      Sparql::Query::Results.new(response.body)
    end

  private

    def raise_error(sparql)
      base = "Failed to query the database. SPARQL query failed."
      message = "#{base}\nSPARQL: #{sparql}"
      ConsoleLogger.info(C_CLASS_NAME, __method__.to_s, message)
      raise Errors::ReadError.new(base)
    end

  end

end