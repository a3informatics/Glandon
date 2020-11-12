# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.22.0
require "active_support/core_ext/class"
require "digest"

module Fuseki
  
  module Resource

    # Resource Inherit. Builds the resource through the amcestor classes
    #
    # @return [Boolean] returns true
    def resource_inherit
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

    # Resources. Returns the resources
    #
    # @return [Hash] the resources
    def resources
      resource_inherit
      self.instance_variable_get(:@resources)
    end

    # Object Relationships
    # 
    # @return [Array] array of hash each containing the predicate and class for the object relationships
    def object_relationships
      resources.select{|x,y| y[:type]==:object}.map{|x,y| {predicate: y[:predicate], model_classes: y[:model_classes]}}
    end

    # Property Relationships
    # 
    # @return [Array] array of hash each containing the predicate and class for the property relationships
    def property_relationships
      resources.select{|x,y| y[:type]!=:object}.map{|x,y| {predicate: y[:predicate], model_classes: y[:model_classes]}}
    end

    # Excluded Read Relationships
    # 
    # @return [Array] array of hash each containing the predicate of any relationships marked to be excluded
    def excluded_read_relationships
      excluded_relationships(:read_exclude)
    end

    # Excluded Delete Relationships
    # 
    # @return [Array] array of hash each containing the predicate of any relationships marked to be excluded
    def excluded_delete_relationships
      excluded_relationships(:delete_exclude)
    end

    # Read Paths
    # 
    # @param [Array] rdf_types set of leaf rdf_types. Defaults to empty array which does not restrict.
    # @param [Array] namespaces set of valid namespaces. Defaults to empty array which permits any namespace.
    # @return [Array] array of strings each being the path (SPARQL) from the class to read a managed item
    def read_paths(rdf_types: [], namespaces: [])
      managed_paths({type: :read_exclude, rdf_types: rdf_types, namespaces: namespaces})
    end

    # Read Property Paths
    # 
    # @param [Symbol] property the name of the property
    # @param [Array] rdf_types set of leaf rdf_types. Defaults to empty array which does not restrict.
    # @param [Array] namespaces set of valid namespaces. Defaults to empty array which permits any namespace.
    # @return [Array] array of strings each being the path (SPARQL) from the class to read a managed item
    def read_property_paths(property:, rdf_types: [], namespaces: [])
      property_paths({type: :read_exclude, rdf_types: rdf_types, namespaces: namespaces}, resources[property])
    end

    # Export Paths
    # 
    # @param [Array] rdf_types set of leaf rdf_types. Defaults to empty array which does not restrict.
    # @param [Array] namespaces set of valid namespaces. Defaults to empty array which permits any namespace.
    # @return [Array] array of strings each being the path (SPARQL) from the class to read a managed item
    def export_paths(rdf_types: [], namespaces: [])
      managed_paths({type: :read_exclude, rdf_types: rdf_types, namespaces: namespaces})
    end

    # Delete Paths
    # 
    # @param [Array] rdf_types set of leaf rdf_types. Defaults to empty array which does not restrict.
    # @param [Array] namespaces set of valid namespaces. Defaults to empty array which permits any namespace.
    # @return [Array] array of strings each being the path (SPARQL) from the class to read a managed item
    def delete_paths(rdf_types: [], namespaces: [])
      managed_paths({type: :delete_exclude, rdf_types: rdf_types, namespaces: namespaces})
    end

    # Delete Property Paths
    # 
    # @param [Symbol] property the name of the property
    # @param [Array] rdf_types set of leaf rdf_types. Defaults to empty array which does not restrict.
    # @param [Array] namespaces set of valid namespaces. Defaults to empty array which permits any namespace.
    # @return [Array] array of strings each being the path (SPARQL) from the class to read a managed item
    def delete_property_paths(property:, rdf_types: [], namespaces: [])
      property_paths({type: :delete_exclude, rdf_types: rdf_types, namespaces: namespaces}, resources[property])
    end

    # RDF Type To Klass
    # 
    # @return [Class] name of the class declared as handling the RDF type
    def rdf_type_to_klass(rdf_type)
      Fuseki::Base.instance_variable_get(:@type_map)[rdf_type]
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

      # Add the RDF type to the class map
      add_rdf_type_to_map(opts[:rdf_type])

      # Define instance method for the RDF Type
      define_method :rdf_type do
        self.class.rdf_type
      end

      # Define the base URI method. Class level
      if opts.key?(:base_uri)
        define_singleton_method :base_uri do
          Uri.new(uri: opts[:base_uri])
        end
      end

      # Define the key method. Class level
      if opts.key?(:key_property)
        define_singleton_method :key_property do
          return opts[:key_property]
        end
      end

      # Define the cache method
      define_singleton_method :cache? do
        opts.key?(:cache) ? opts[:cache] : false
      end

      # Define instance method for creating a URI.
      define_method :create_uri do |parent|
        result = Uri.new(uri: parent.to_s) 
        if opts.key?(:uri_unique)
          if opts[:uri_unique].is_a?(TrueClass)
            if opts.key?(:uri_suffix)
              result = Uri.new(namespace: parent.namespace, fragment: "#{opts[:uri_suffix]}")
              result.extend_fragment("#{SecureRandom.uuid}")
            else
              result = Uri.new(namespace: self.class.base_uri.namespace, fragment: SecureRandom.uuid)
            end
          else
            result = Uri.new(namespace: self.class.base_uri.namespace, fragment: Digest::SHA1.hexdigest(self.send(opts[:uri_unique])))
          end
        elsif opts.key?(:uri_suffix) && opts.key?(:uri_property)
          result.extend_fragment("#{opts[:uri_suffix]}#{self.send(opts[:uri_property])}")
        elsif opts.key?(:uri_suffix)
          result.extend_fragment(opts[:uri_suffix])
        elsif opts.key?(:uri_property) 
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
      Errors.application_error(self.name, __method__.to_s, "No model class specified for object property.") unless opts.key?(:model_class) || opts.key?(:model_classes) 
      if opts.key?(:model_classes)
        opts[:model_classes].unshift(opts[:model_class]) if opts.key?(:model_class)
        opts[:model_classes] = opts[:model_classes].map{|x| "#{x}".constantize}
      else
        opts[:model_classes] = [] 
        opts[:model_classes] << "#{opts[:model_class]}".constantize
      end
      opts.except!(:model_class) # Remove the model_class key, use model_classes for all processing
      opts[:default] = opts[:cardinality] == :one ? nil : []
      opts[:type] = :object 
      opts[:read_exclude] = opts.key?(:read_exclude)
      opts[:delete_exclude] = opts.key?(:delete_exclude)
      opts[:base_type] = ""
      add_to_resources(name, opts)

      if opts[:cardinality] != :one 
        define_method("#{name}_push") do |value|
          @properties.property(name.to_sym).set(value)
        end

        define_method("#{name}_replace") do |old_value, new_value|
          @properties.property(name.to_sym).replace_value(old_value, new_value)
        end

        define_method("#{name}_delete") do |value|
          @properties.property(name.to_sym).delete_value(value)
        end
      end

      define_method "#{name}_links" do
        generic_links(name)
      end

      define_method "#{name}_links?" do
        generic_links?(name)
      end

      define_method "#{name}_objects" do
        generic_objects(name)
      end

      define_method "#{name}_objects?" do
        generic_objects?(name)
      end

      # Children properties
      if opts.key?(:children)
        
        # Define a class method to return if children predicate exists
        define_singleton_method "children_predicate?" do
          true
        end

        # Define an instance method to return the children
        define_method "children" do
          instance_variable_get("@#{name}")
        end

        # Define an instance method to return the children objects
        define_method "children_objects" do
          generic_objects(name)
        end

        # Define an instance method to return the children
        define_method "children?" do
          instance_variable_get("@#{name}").any?
        end

        # Define a class method to get the children class
        define_singleton_method "children_klass" do
          #opts[:model_class]
          @resources["#{name}".to_sym][:model_classes].first
        end

        # Define a class method to get the child predicate
        define_singleton_method "children_predicate" do
          @resources["#{name}".to_sym][:predicate]
        end

      else

        # Define a class method to return if children predicate exists
        define_singleton_method "children_predicate?" do
          false
        end

      end

    end

    # Object Property Class. Add a class to a relatinship
    #
    # @param name [Symbol] the property name
    # @param opts [Hash] the option hash
    # @option opts [Symbol] :model_class the model class handling the other end of the relationship
    # @raise [Errors::ApplicationLogicError] raised if model_class not found.
    # @return [Void] no return
    def object_property_class(name, opts = {})
      Errors.application_error(self.name, __method__.to_s, "No model class(es) specified for object property class.") unless opts.key?(:model_class) || opts.key?(:model_classes)
      properties = Fuseki::Resource::Properties.new(self, self.resources)
      properties.property(name).add_klasses(opts[:model_classes].map{|x| "#{x}".constantize}) if opts.key?(:model_classes)
      properties.property(name).add_klasses(["#{opts[:model_class]}".constantize]) if opts.key?(:model_class)
    end

    # Data Property
    #
    # @param name [Symbol] the property name
    # @param [Hash] opts the option hash.
    # @option opts [Symbol] :default the default value. Optional
    # @return [Void] no return
    def data_property(name, opts = {})
      simple_datatype = XSDDatatype.new(self.schema_metadata.datatype(predicate_uri(name)))
      options = 
      { 
        cardinality: :one, 
        model_classes: [], 
        type: :data, 
        base_type: simple_datatype, 
        read_exclude: false, 
        delete_exclude: false 
      }
      options[:default] = opts.key?(:default) ? opts[:default] : simple_datatype.default
      add_to_resources(name, options)
    end

    # Managed Paths. Form the managed paths for the item. This is a set of paths for SPARQL operations
    # 
    # @param [Hash] options the options hash
    # @option options [Symbol] :type the path type to be excluded
    # @option options [Array] :rdf_types array of rdf_types at which path processing is to stop
    # @option options [Array] :namespaces array of permitted namespaces 
    # @param [Array] stack the stack of klasses processed. Used to prevent circular paths
    # @param [String] parent_predicate the set of predicates from the parent. Will be prepended to this predicate
    # @return [Array] array of strings each being the path (SPARQL) from the class to read a managed item
    def managed_paths(options, stack=[], parent_predicate="")
      paths = []
      top = true if stack.empty?
      predicates = resources.select{|x,y| y[:type]==:object}.map{|x,y| {predicate: y[:predicate], model_classes: y[:model_classes], exclude: y[options[:type]]}}
      predicates.each do |predicate| 
        stack = [] if top
        next if predicate[:exclude]
        klasses = predicate[:model_classes]
        klasses.each do |klass|
          is_recursive = false
          if klass == self
            is_recursive = true
            name = "#{klass}.#{predicate[:predicate].fragment}"
          else
            name = "#{klass}.#{predicate[:predicate].fragment}"
          end
          next if stack.include?(name)
          stack.push(name)
          predicate_ref = "#{predicate[:predicate].to_ref}#{is_recursive ? "*" : ""}"
          path = top ? "#{predicate_ref}" : "#{parent_predicate}/#{predicate_ref}"
          paths << path unless ignore_namespaces?(options, klass)
          paths += klass.managed_paths(options, stack, path) unless ignore_types?(options, klass)
          x = stack.pop
        end
      end
      paths = paths.uniq if top
      paths
    end

    # Property Paths. Form the managed paths for the property. This is a set of paths for SPARQL operations
    # 
    # @param [Hash] options the options hash
    # @option options [Symbol] :type the path type to be excluded
    # @option options [Array] :rdf_types array of rdf_types at which path processing is to stop
    # @option options [Array] :namespaces array of permitted namespaces 
    # @param [Hash] property the property hash
    # @return [Array] array of strings each being the path (SPARQL) from the class to read a managed item
    def property_paths(options, property)
      paths = []
      stack = []
      klasses = property[:model_classes]
      klasses.each do |klass|
        is_recursive = false
        if klass == self
          is_recursive = true
          name = "#{klass}.#{property[:predicate].fragment}"
        else
          name = "#{klass}.#{property[:predicate].fragment}"
        end
        next if stack.include?(name)
        stack.push(name)
        predicate_ref = "#{property[:predicate].to_ref}#{is_recursive ? "*" : ""}"
        path = "#{predicate_ref}"
        paths << path
        paths += klass.managed_paths(options, stack, path)
        x = stack.pop
      end
      paths
    end

    # Excluded Relationships
    # 
    # @param type [Symbol] the path type
    # @return [Array] array of hash each containing the predicate of any relationships marked to be excluded
    def excluded_relationships(type)
      resources.select{|x,y| y[:type]==:object && y[type]}.map{|x,y| y[:predicate].to_ref}
    end

  private
  
    # Ignore rdf types? Used to check rdf type.
    def ignore_types?(options, klass)
      options[:rdf_types].any? && options[:rdf_types].include?(klass.rdf_type)
    end

    # Ignore Namespaces? Used to check permitted namespaces.
    def ignore_namespaces?(options, klass)
      options[:namespaces].any? && options[:namespaces].exclude?(klass.rdf_type.namespace)
    end

    # Create the instance variable. Set the info for the instance variable.
    def add_to_resources(name, opts)

      define_method("#{name}=") do |value|
        @properties.property(name.to_sym).set_raw(value)
      end

      define_method("#{name}") do 
        @properties.property(name.to_sym).get
      end
      
      @resources ||= {}
      opts[:name] = name
      opts[:predicate] = predicate_uri(name)
      @resources["#{name}".to_sym] = opts
    end
    
    # Create a unique URI extension
    def unique_extension
      SecureRandom.uuid
    end

    # def prefix_property_extension(opts)
    #   return "" if !opts.key?(:prefix) && !opts.key?(:property)
    #   return "#{opts[:prefix]}" if !opts.key?(:property)
    #   return "#{opts[:prefix]}#{self.send(opts[:property])}"
    # end

    # Builds the URI for a predicate
    def predicate_uri(name)
      Uri.new(namespace: self.rdf_type.namespace, fragment: Fuseki::Resource::Property.schema_predicate_name(name) )
    end

    # Adds to the RDF Type to Klass map
    def add_rdf_type_to_map(rdf_type)
      if !Fuseki::Base.instance_variable_defined?(:@type_map) || Fuseki::Base.instance_variable_get(:@type_map).nil?
        Fuseki::Base.instance_variable_set(:@type_map, {})
      end
      Fuseki::Base.instance_variable_get(:@type_map)[rdf_type] = self
    end

  end

end