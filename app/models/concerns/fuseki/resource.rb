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
      #add_to_properties(:rdf_type, {default: Uri.new(uri: opts[:rdf_type]), cardinality: :one, model_class: "", type: :object})

      # Define class method for the RDF Type
      define_singleton_method :rdf_type do
        Uri.new(uri: opts[:rdf_type])
      end

      # Define instance method for the RDF Type
      define_method :rdf_type do
        self.class.rdf_type
      end

      # Save the base URI
      if opts[:base_uri]
        define_singleton_method :base_uri do
          Uri.new(uri: opts[:base_uri])
        end
      end

    end

    # Object Property
    #
    # @param name [Symbol] the property name
    # @param opts [Hash] the option hash
    # @option opts [Symbol] :cardinality the cardinality, either :one or :many
    # @option opts [Symbol] :model_class the model class handling the other end of the relationship
    # @return [Void] no return
    def object_property(name, opts = {})
      Errors.application_error(self.name, __method__.to_s, "No cardinality specified for object property.") if !opts.key?(:cardinality)
      Errors.application_error(self.name, __method__.to_s, "No model class specified for object property.") if !opts.key?(:model_class)
      opts[:default] = opts[:cardinality] == :one ? nil : []
      opts[:type] = :object 
      add_to_properties(name, opts)

      define_method "#{name}_objects" do
        generic_objects(name, opts[:model_class].constantize)
      end

      define_method "#{name}_objects?" do
        generic_objects?(name)
      end

    end

    # Data Property
    #
    # @param name [Symbol] the property name
    # @param opts [Hash] the option hash. Currently empty
    # @return [Void] no return
    def data_property(name, opts = {})
      add_to_properties(name, {default: "", cardinality: :one, model_class: "", type: :data})
    end

  private
  
    # Create the instance variable. Set the info for the instance variable.
    def add_to_properties(name, opts)
      self.send(:attr_accessor, "#{name}")
      @properties ||= {}
      opts[:name] = name
      @properties["@#{name}".to_sym] = opts
    end
    
  end

end