# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
require "active_support/core_ext/class"
require "digest"

module Fuseki
  
  module Resource

    def resource_inherit
#      return true if self.instance_variable_defined?(:@resources)
#puts "****** RESOURCES - #{self.name} ******"
      merged = {}
      klass_ancestors = self.ancestors.grep(Fuseki::Resource).reverse
      klass_ancestors.delete(Fuseki::Base) # Remove the base class
      klass_ancestors.each do |klass| 
        props = klass.instance_variable_get(:@resources)
        next if props.nil?
        merged.merge!(props) 
      end
      self.instance_variable_set(:@resources, (merged))
      true
    end

    def resources
      resource_inherit
      self.instance_variable_get(:@resources)
    end

    # Object Relationships
    # 
    # @return [Array] array of hash each containing the predicate and class for the class' relationships
    def object_relationships
      resources.select{|x,y| y[:type]==:object}.map{|x,y| {predicate: y[:predicate], model_class: y[:model_class]}}
    end

    # Property Relationships
    # 
    # @return [Array] array of hash each containing the predicate and class for the class' relationships
    def property_relationships
      resources.select{|x,y| y[:type]!=:object}.map{|x,y| {predicate: y[:predicate], model_class: y[:model_class]}}
    end

    # Excluded Relationships
    # 
    # @return [Array] array of hash each containing the predicate of any relationships marked to be excluded
    def excluded_relationships
      resources.select{|x,y| y[:type]==:object && y[:path_exclude]}.map{|x,y| y[:predicate].to_ref}
    end

    # Managed Paths
    # 
    # @return [Array] array of strings each being the path (SPARQL) from the class to form a managed item
    def managed_paths(stack=[])
      top = true if stack.empty?
      result = []
      predicates = resources.select{|x,y| y[:type]==:object}.map{|x,y| {predicate: y[:predicate], model_class: y[:model_class], exclude: y[:path_exclude]}}
      predicates.each do |predicate| 
        stack = [] if top
        next if predicate[:exclude]
        klass = predicate[:model_class]
        next if stack.include?(klass)
        stack.push(klass)
        children = klass.managed_paths(stack)
        children.empty? ? result << "#{predicate[:predicate].to_ref}" : children.each {|child| result << "#{predicate[:predicate].to_ref}|#{child}"}
      end
      result
    end

    # Configure
    #
    # @param opts [Hash] the option hash
    # @option opts [Symbol] :rdf_type the RDF type for the class
    # @return [Void] no return
    def configure(opts = {})

      # Clear the properties
      @resources = {}

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

      # Define the base URI method. Class level
      if opts[:base_uri]
        define_singleton_method :base_uri do
          Uri.new(uri: opts[:base_uri])
        end
      end

      # Define the key method. Class level
      if opts[:key_property]
        define_singleton_method :key_property do
          return opts[:key_property]
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
          result = Uri.new(namespace: base_uri.namespace, fragment: SecureRandom.uuid)
          #result.replace_fragment(SecureRandom.uuid)
        elsif opts[:uri_suffix] 
          result.extend_fragment(opts[:uri_suffix])
        end
        result
      end

      # Define instance method for creating a URI.
      define_method :create_uri do |parent|
        result = Uri.new(uri: parent.to_s) 
        if opts[:uri_unique]
          if opts[:uri_unique].is_a?(TrueClass)
            result = Uri.new(namespace: self.class.base_uri.namespace, fragment: SecureRandom.uuid)
          else
            result = Uri.new(namespace: self.class.base_uri.namespace, fragment: Digest::SHA1.hexdigest(self.send(opts[:uri_unique])))
          end
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
      opts[:model_class] = opts[:model_class].constantize
      opts[:default] = opts[:cardinality] == :one ? nil : []
      opts[:type] = :object 
      opts[:path_exclude] = false if !opts.key?(:path_exclude)
      opts[:base_type] = ""
      add_to_resources(name, opts)

      define_method "#{name}_objects" do
        generic_objects(name)
      end

      define_method "#{name}_objects?" do
        generic_objects?(name)
      end

      if opts.key?(:children)
        
        # Define an instance method to return the children
        define_method "children" do
          instance_variable_get("@#{name}")
        end

        # Define an instance method to return the children
        define_method "children?" do
          instance_variable_get("@#{name}").any?
        end

        # Define a class method to get the children class
        define_singleton_method "children_klass" do
          opts[:model_class]
        end

        # Define a class method to get the child predicate
        define_singleton_method "children_predicate" do
          predicate_uri(name)
        end

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
      add_to_resources(name, {default: default, cardinality: :one, model_class: "", type: :data, base_type: self.schema_metadata.datatype(predicate_uri(name))})
    end

  private
  
    # Create the instance variable. Set the info for the instance variable.
    def add_to_resources(name, opts)

      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
        @new_record = true
      end

      define_method("#{name}") do 
        instance_variable_get("@#{name}")
      end
      
      @resources ||= {}
      opts[:name] = name
      opts[:predicate] = predicate_uri(name)
      @resources["#{name}".to_sym] = opts
    end
    
    def unique_extension
      SecureRandom.uuid
    end

    def prefix_property_extension(opts)
      return "" if !opts.key?(:prefix) && !opts.key?(:property)
      return "#{opts[:prefix]}" if !opts.key?(:property)
      return "#{opts[:prefix]}#{self.send(opts[:property])}"
    end

    def predicate_uri(name)
      Uri.new(namespace: self.rdf_type.namespace, fragment: Fuseki::Resource::Property.schema_predicate_name(name) )
    end

  end

end