# Prefix Clauses. Handles the creation of the SPARQL prefix clsauses 
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql

  module PrefixClauses

    include Sparql::Namespace

    # Build Clauses. Build the prefix clauses
    #
    # @param default [String|Symbol] either the namespace (string) or the prefix (symbol) for the default namespace.
    # @param prefixes [Array] array of prefixes (symbols)
    # @return [String] the prefix clauses as a string
    def build_clauses(default, prefixes)
      result = default_namespace_clause(default)
      prefixes.each do |key| 
        namespace = namespace_from_prefix(key)
        next if namespace.nil?
        result += prefix_clause(key, namespace) 
      end
      required_namespaces.each {|key, value| result += prefix_clause(key, value)}
      return result
    end

  private

    # Set default namespace, either quoted or using prefix
    def default_namespace_clause(default)
      return "" if default.blank?
      return prefix_clause("", namespace_from_prefix(default)) if default.is_a? Symbol
      return prefix_clause("", default)  
    end

    # Single prefix cluase
    def prefix_clause(prefix, namespace)
      return "PREFIX #{prefix}: <#{namespace}#>\n"
    end

  end

end