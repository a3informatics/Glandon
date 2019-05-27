# URI Namespace. Handles the various namespaces and prefixes.
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class Uri

  class Namespace

    # Get the optional namespaces
    #
    # @return [Hash] The set of optional namespaces
    def optional_namespaces
      return Rails.configuration.namespaces[:optional]
    end

    # Get the required namespaces
    #
    # @return [Hash] the set of required namespaces
    def required_namespaces
      return Rails.configuration.namespaces[:required]
    end

    # Prefix a required one?
    #
    # @return [Boolean] true if a required namespace
    def required_prefix?(prefix)
      !Rails.configuration.namespaces[:required][prefix.to_sym].nil?
    end

    # Get Prefix for a namespace
    #
    # @param namespace [String] The namespace
    # @return [string] The prefix
    def prefix_from_namespace(namespace)
      prefix = Rails.configuration.namespaces[:optional].key(namespace)
      prefix = Rails.configuration.namespaces[:required].key(namespace) if prefix == nil
      return prefix
    end
      
    def owl_prefix
      return Rails.configuration.namespaces[:required].key("http://www.w3.org/2002/07/owl")
    end
    
    # Get Namespace for a prefix
    #
    # @param prefix [Symbol] The prefix
    # @return [string] The namespace
    def namespace_from_prefix(prefix)
      l_prefix = prefix.to_sym # Just play safe in case sent in as a string.
      namespace = Rails.configuration.namespaces[:optional][l_prefix]
      namespace = Rails.configuration.namespaces[:required][l_prefix] if namespace == nil 
      return namespace
    end

  end

end
