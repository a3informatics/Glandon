# Namespace
#
# Handles the various namespaces and prefixes.
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql::Namespace

  # Constants
  C_CLASS_NAME = self.name

  
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

  # Get Prefix for a namespace
  #
  # @param namespace [string] The namespace
  # @return [string] The prefix
  def prefix_from_namespace(namespace)
    prefix = Rails.configuration.namespaces[:optional].key(namespace)
    prefix = Rails.configuration.namespaces[:required].key(namespace) if prefix == nil
    return prefix
  end
    
  # Get Namespace for a prefix
  #
  # @param prefix [string] The prefix
  # @return [string] The namespace
  def namespace_from_prefix(prefix)
    namespace = Rails.configuration.namespaces[:optional][prefix]
    namespace = Rails.configuration.namespaces[:required][prefix] if namespace == nil 
    return namespace
  end

end
