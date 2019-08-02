# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Persistence
  
    extend ActiveSupport::Concern
    
    # -------------
    # Class Methods
    # -------------

    module ClassMethods

      # Find
      #
      # @param [Uri|id] the identifier, either a URI or the id
      # @return [Object] a class object.
      def find(id)
        uri = id.is_a?(Uri) ? id : Uri.new(id: id)
        results = subject_cache(uri)
        raise Errors::NotFoundError.new("Failed to find #{uri} in #{self.name}.") if results.empty?
        from_results(uri, results.by_subject[uri.to_s])
      end

      # Find Children
      #
      # @param [Uri|id] the identifier, either a URI or the id
      # @return [Object] a class object.
      def find_children(id)
        parts = [0]
        #klass_map = {}
        uri = id.is_a?(Uri) ? id : Uri.new(id: id)
        properties = resources
        parts[0] = "  { #{uri.to_ref} ?p ?o .  BIND (#{uri.to_ref} as ?s) . BIND ('#{self.name}' as ?e) }" 
        properties.each do |name, value|
          #next if name == :@rdf_type
          next if properties[name][:type] != :object
          klass = properties[name][:model_class]
          #klass_map[klass.name] = properties[name]
          predicate = properties[name][:predicate]
          parts << "  { #{uri.to_ref} #{predicate.to_ref} ?ref .  BIND (?ref as ?s) .  BIND ('#{klass}' as ?e) .  ?ref ?p ?o . }"
        end
        query_string = "SELECT ?s ?p ?o ?e WHERE { #{parts.join(" UNION\n")} }"
        results = Sparql::Query.new.query(query_string, uri.namespace, [])
        raise Errors::NotFoundError.new("Failed to find #{uri} in #{self.name}.") if results.empty?
        #objects = []
        #map = results.subject_map
        from_results_recurse(uri, results.by_subject)
        #parent = from_results(uri, results.by_subject[uri.to_s])
        # results.by_subject.each do |subject, triples|
        #   next if subject == parent.uri.to_s
        #   klass = map[subject.to_s].constantize
        #   properties = klass_map[klass.name]
        #   name = properties[:name]
        #   object = klass.new.class.from_results(Uri.new(uri: subject), triples)
        #   #properties[:cardinality] == :one ? parent.instance_variable_set("@#{name}".to_sym, object) : parent.instance_variable_get("@#{name}".to_sym).push(object)
        #   parent.replace_uri("@#{name}".to_sym, object)
        # end
        #parent
      end

      def where(params)
        properties = resources
        sparql = Sparql::Query.new()
        query_string = "SELECT ?s ?p ?o WHERE {" +
          "  ?s rdf:type #{rdf_type.to_ref} ."
        params.each do |name, value|
          predicate = properties["#{name}".to_sym][:predicate]
          literal = self.schema_metadata.datatype(predicate) == BaseDatatype.to_xsd(BaseDatatype::C_STRING) ? value.dup.inspect.trim_inspect_quotes : value
          query_string += "  ?s #{predicate.to_ref} \"#{literal}\"^^xsd:#{self.schema_metadata.datatype(predicate)} ."
        end
        query_string += "  ?s ?p ?o ."
        query_string += "}"
        results = Sparql::Query.new.query(query_string, "", [])
        objects = []
        results.by_subject.each do |subject, triples|
          objects << from_results(Uri.new(uri: subject), triples)
        end
        objects
      end

      def where_only(params)
        Errors.application_error(self.class.name, __method__.to_s, "Multiple properties specified.") if params.count != 1
        results = where(params)
        return nil if results.empty?
        Errors.application_error(self.class.name, __method__.to_s, "Multiple objects found for #{params}.") if results.count > 1
        return results.first
      end

      def where_only_or_create(where_params, create_params)
        object = where_only(where_params)
        return object if !object.nil?
        return create(create_params)
      end

      # Find all objects
      #
      # @return [Array] Array of objects
      def all
        where({})
      end

      def create(params)
        object = new(params)
        object.create_or_update(:create) if object.valid?(:create)
        object
      end

      def object_results(query_string, params)
        default_namespace = params.key?(:default_namespace) ? params[:default_namespace] : ""
        prefixes = params.key?(:prefixes) ? params[:prefixes] : []
        Sparql::Query.new.query(query_string, default_namespace, prefixes)
      end

      def from_results(uri, triples)
        object = new
        object.instance_variable_set("@uri", uri)
        triples.each do |triple|
          property = object.properties.property_from_triple(triple)
          next if property.nil?
          property.object? ? property.set_uri(triple[:object]) : property.set_value(triple[:object])
        end
        object.instance_variable_set(:@new_record, false)
        object.instance_variable_set(:@destroyed, false)
        object
      end

      def from_results_recurse(uri, triples)
        object = new
        object.instance_variable_set("@uri", uri)
        triples[uri.to_s].each do |triple|
          property = object.properties.property_from_triple(triple)
          next if property.nil?
          value = triple[:object]
          if property.object?
            child = triples[value.to_s].empty? ? value : property.klass.from_results_recurse(value, triples)
            property.set_value(child)
          else
            property.set_value(value)
          end
        end
        object.instance_variable_set(:@new_record, false)
        object.instance_variable_set(:@destroyed, false)
        object
      end

      def subject_cache(uri)
        query_string = "SELECT ?s ?p ?o WHERE {#{uri.to_ref} ?p ?o . BIND (#{uri.to_ref} as ?s) .}"
        return Sparql::Query.new.query(query_string, uri.namespace, []) if !cache?
        Fuseki::Base.class_variable_set(:@@subjects, Hash.new {|h, k| h[k] = {}}) if !Fuseki::Base.class_variable_defined?(:@@subjects) || Fuseki::Base.class_variable_get(:@@subjects).nil?
        uri_as_s = uri.to_s
        cache = Fuseki::Base.class_variable_get(:@@subjects)
        return cache[uri_as_s] if cache.key?(uri_as_s) 
        results = Sparql::Query.new.query(query_string, uri.namespace, [])
        cache[uri_as_s] = results if !results.empty?
        results
      end

    end

    # ----------------
    # Instance Methods
    # ----------------

    def persisted?
      !(@new_record || @destroyed)
    end
      
    def new_record?
      @new_record
    end

    def destroyed?
      @destroyed
    end

    def set_persisted
      self.instance_variable_set(:@new_record, false)
      self.instance_variable_set(:@destroyed, false)
    end

    def id
      self.uri.nil? ? nil : self.uri.to_id
    end

    alias uuid id

    def transaction_begin
      @transaction = Sparql::Transaction.new
    end

    def transaction_execute
      @transaction.execute
      @transaction = nil
    end
    
    def where_child(params)
      where_clauses = ""
      params.each {|name, value| where_clauses += "  ?s :#{name} \"#{value}\" .\n" }
      properties = properties_instance
      unions = []
      properties.object_relationships.map.each do |relationship|
        unions << "{ #{uri.to_ref} #{relationship[:predicate].to_ref} ?s .\n#{where_clauses}?s ?p ?o .\nBIND ('#{relationship[:model_class]}' as ?e) . }"
      end
      query_string = "SELECT ?s ?p ?o ?e WHERE {#{unions.join(" UNION\n")}}"
      results = Sparql::Query.new.query(query_string, self.rdf_type.namespace, [])
      objects = []
      map = results.subject_map
      results.by_subject.each do |subject, triples|
        klass = map[subject.to_s].constantize
        objects << klass.from_results(Uri.new(uri: subject), triples)
      end
      objects
    end
      
    def update
      create_or_update(:update) if valid?(:update)
    end

    def delete
      clear_cache
      Sparql::Update.new.delete(self.uri)
      @destroyed = true
      return 1
    end

    def generic_objects(name)
      objects = []
      property = self.properties.property(name)
      sparql = Sparql::Query.new()
      query_string = "SELECT ?s ?p ?o WHERE {" +
        "  #{uri.to_ref} #{property.predicate.to_ref} ?s ." +
        "  ?s ?p ?o ." +
        "}"
      results = Sparql::Query.new.query(query_string, "", [])
      objects = []
      results.by_subject.each do |subject, triples|
        property.set_value(property.klass.from_results(Uri.new(uri: subject), triples))
      end
      property.get
    end

    def generic_objects?(name)
      !uri?(name)
    end

    def not_used?
      query_string = "SELECT ?s WHERE {" +
          "  ?s ?p #{instance_variable_get(:@uri).to_ref} ." +
          "}"
      results = Sparql::Query.new.query(query_string, "", [])
      results.empty? 
    end

    def used?
      !not_used?
    end

    def partial_update(query, prefixes)
      Sparql::Update.new(@transaction).sparql_update(query, self.rdf_type.namespace, prefixes)
    end

    def create_or_update(operation, recurse=false)
      clear_cache
      sparql = Sparql::Update.new(@transaction)
      sparql.default_namespace(@uri.namespace)
      to_sparql(sparql, recurse)
      operation == :create ? sparql.create : sparql.update(@uri)
      @new_record = false
      self
    end

    def to_sparql(sparql, recurse=false)
      sparql.add({uri: @uri}, {prefix: :rdf, fragment: "type"}, {uri: self.class.rdf_type})
      self.properties.each do |property|
        next if object_empty?(property)
        property_to_triple(sparql, property, @uri)
        object_to_triple(sparql, property) if recurse
      end
    end      

    def generate_uri(parent)
      self.uri = create_uri(parent) # Dynamic method 
      properties.each do |property|
        value = property.get
        next if object_empty?(property)
        object_create_uri(property)
      end
    end      

  private

    # Set a simple typed value
    def self.to_typed(base_type, value)
      if base_type == BaseDatatype.to_xsd(BaseDatatype::C_STRING)
        "#{value}"
      elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_BOOLEAN)
        value.to_bool
      elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_DATETIME)
        value.to_time_with_default
      elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_INTEGER)
        value.to_i
      elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_POSITIVE_INTEGER)
        value.to_i
      else
        "#{value}"
      end
    rescue => e
    end

    def clear_cache
      return if !self.class.cache?
puts "***** CLEARING CACHE #{self.uri} *****"
      Fuseki::Base.class_variable_set(:@@subjects, Hash.new {|h, k| h[k] = {}}) if !Fuseki::Base.class_variable_defined?(:@@subjects) || Fuseki::Base.class_variable_get(:@@subjects).nil?
      Fuseki::Base.class_variable_get(:@@subjects).delete(self.uri.to_s)
    end

    # Create the triple for the property
    def property_to_triple(sparql, property, subject) #, predicate, objects)
      objects = property.get
      objects = [objects] if !objects.is_a? Array
      objects.each do |object|
        datatype = self.class.schema_metadata.datatype(property.predicate)
        statement = property.object? ? {uri: object_uri(object)} : {literal: "#{object_literal(datatype, object)}", primitive_type: datatype}
        sparql.add({:uri => subject}, {:uri => property.predicate}, statement)
      end
    rescue => e
byebug
    end

    def object_to_triple(sparql, property)
      return if !property.object?
      objects = property.get
      objects = [objects] if !objects.is_a? Array
      objects.each do |object|
        next if object.respond_to?(:persisted?) ? object.persisted? : true
        object.to_sparql(sparql, true)
      end
    end

    def object_create_uri(property)
      return if !property.object?
      objects = property.get
      objects = [objects] if !objects.is_a? Array
      objects.each do |object|
        next if object.respond_to?(:persisted?) ? object.persisted? : false
        object.generate_uri(self.uri) if object.respond_to?(:generate_uri)
      end
    end

    def object_uri(object)
      return object if object.is_a? Uri
      result = object.uri if object.respond_to?(:uri)
      return result if !result.nil?
byebug
      Errors.application_error(self.class.name, __method__.to_s, "The URI for an object has not been set or cannot be accessed: #{object.to_h}")
    end

    def object_empty?(property)
      return false if !property.object? 
      value = property.get
      return true if value.nil?
      return true if property.array? && value.empty?
      return false
    end

    # Build the object literal as a string
    def object_literal(type, value)
      return type == BaseDatatype.to_xsd(BaseDatatype::C_DATETIME) ? value.iso8601 : value
    end
  end

end