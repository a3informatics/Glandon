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

      # Clear the properties
      @properties = {}

      # Make sure RDF type set
      Errors.application_error(self.name, __method__.to_s, "No RDF type specified when configuring class.") if !opts.key?(:rdf_type)
      
      # Define class method for the RDF Type
      define_singleton_method :rdf_type do
        Uri.new(uri: opts[:rdf_type])
      end

      # Define instance method for the RDF Type
      define_method :rdf_type do
        self.class.rdf_type
      end

      # Define the base URI method
      if opts[:base_uri]
        define_singleton_method :base_uri do
          Uri.new(uri: opts[:base_uri])
        end
      end

      # Define the cache method
      define_singleton_method :cache? do
        opts[:cache] ? opts[:cache] : false
      end

      # Define URI creation method for the class
      define_singleton_method :create_uri do |parent|
        result = Uri.new(uri: parent.to_s) 
        if opts[:uri_unique]
          result.extend_fragment(SecureRandom.uuid)
        elsif opts[:uri_suffix] 
          result.extend_fragment(opts[:uri_suffix])
        end
        result
      end

      # Define instance method for creating a URI.
      define_method :create_uri do |parent|
        result = Uri.new(uri: parent.to_s) 
        if opts[:uri_unique]
          result.extend_fragment(SecureRandom.uuid)
        elsif opts[:uri_suffix] && opts[:uri_property] 
          result.extend_fragment("#{opts[:uri_suffix]}#{self.send(opts[:uri_property])}")
        elsif opts[:uri_suffix] 
          result.extend_fragment(opts[:uri_suffix])
        elsif opts[:uri_property] 
          result.extend_fragment(self.send(opts[:uri_property]))
        end
        result
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
    # @param opts [Hash] the option hash.
    # @option opts [Symbol] :default the default value. Optional
    # @return [Void] no return
    def data_property(name, opts = {})
      default = opts[:default] ? opts[:default] : ""
      add_to_properties(name, {default: default, cardinality: :one, model_class: "", type: :data})
    end

  private
  
    # Create the instance variable. Set the info for the instance variable.
    def add_to_properties(name, opts)
      self.send(:attr_accessor, "#{name}")
      @properties ||= {}
      opts[:name] = name
      opts[:predicate] = Uri.new(namespace: self.rdf_type.namespace, fragment: Fuseki::Persistence::Naming.new(name).as_schema)
      @properties["@#{name}".to_sym] = opts
    end
    
    def unique_extension
      SecureRandom.uuid
    end

    def prefix_property_extension(opts)
      return "" if !opts.key?(:prefix) && !opts.key?(:property)
      return "#{opts[:prefix]}" if !opts.key?(:property)
      return "#{opts[:prefix]}#{self.send(opts[:property])}"
    end

  end

end