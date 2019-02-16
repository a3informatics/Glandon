# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
require "active_support/core_ext/class"

module Fuseki
  
  module Resource

    # Configure
    #
    # @param opts [Hash] the option hash
    # @option opts [Symbol] :rdf_type the RDF type for the class
    # @return [Void] no return
    def configure(opts = {})
      Errors.application_error(self.name, __method__.to_s, "No RDF type specified when configuring class.") if !opts.key?(:rdf_type)
      create(:rdf_type, Uri.new(uri: opts[:rdf_type]))
    end

    # Object Property
    #
    # @param name [Symbol] the property name
    # @param opts [Hash] the option hash
    # @option opts [Symbol] :cardinality the cardinality, either :one or :many
    # @return [Void] no return
    def object_property(name, opts = {})
      Errors.application_error(self.name, __method__.to_s, "No cardinality specified for object property.") if !opts.key?(:cardinality)
      initial = opts[:cardinality] == :one ? "" : [] 
      create(name, initial)
    end

    # Object Property
    #
    # @param name [Symbol] the property name
    # @param opts [Hash] the option hash. Currently empty
    # @return [Void] no return
    def data_property(name, opts = {})
      create(name, "")
    end

  private
  
    # Create the instance variable. Set the info for the instance variable.
    def create(name, initial)
      self.send(:attr_accessor, "#{name}")
      @properties ||= {}
      @properties[name] = initial
    end
    
  end

end