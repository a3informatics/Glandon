# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.22.0
module Fuseki
  
  module Persistence
  
    extend ActiveSupport::Concern
    
    # -------------
    # Class Methods
    # -------------

    module ClassMethods

      # Find. Simple find for the subject. Will cache if indicated in class definition.
      #
      # @param [Uri|id] the identifier, either a URI or the id
      # @return [Object] a class object.
      def find(id)
        uri = id.is_a?(Uri) ? id : Uri.new(id: id)
        results = subject_cache(uri)
        raise Errors::NotFoundError.new("Failed to find #{uri} in #{self.name}.") if results.empty?
        from_results(uri, results.by_subject[uri.to_s])
      end

      # Find Children. Find object and one-level of child
      #
      # @param [Uri|id] the identifier, either a URI or the id
      # @return [Object] a class object.
      def find_children(id)
        parts = [0]
        uri = id.is_a?(Uri) ? id : Uri.new(id: id)
        properties = resources
        parts[0] = "  { #{uri.to_ref} ?p ?o .  BIND (#{uri.to_ref} as ?s) . BIND ('#{self.name}' as ?e) }" 
        properties.each do |name, value|
          next if properties[name][:type] != :object
          klass = properties[name][:model_class]
          predicate = properties[name][:predicate]
          parts << "  { #{uri.to_ref} #{predicate.to_ref} ?ref .  BIND (?ref as ?s) .  BIND ('#{klass}' as ?e) .  ?ref ?p ?o . }"
        end
        query_string = "SELECT ?s ?p ?o ?e WHERE { #{parts.join(" UNION\n")} }"
        results = Sparql::Query.new.query(query_string, uri.namespace, [])
        raise Errors::NotFoundError.new("Failed to find #{uri} in #{self.name}.") if results.empty?
        from_results_recurse(uri, results.by_subject)
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
        triples.each {|triple| property = object.properties.property_from_triple(triple)}
        object.set_persisted
        object
      end

      def from_results_recurse(uri, triples)
        object = new
        object.instance_variable_set("@uri", uri)
        triples[uri.to_s].each do |triple|
          property = object.properties.property_from_triple(triple)
          next if property.nil?
          value = triple[:object]
          if property.object? && !triples[value.to_s].empty?
            property.replace_with_object(property.klass.from_results_recurse(value, triples))
          end
        end
        object.set_persisted
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

      # The Type. Get the type for a URI
      # 
      # @params [Uri] uri the uri
      # @raise [Errors::ApplicationLogicError] raised if no type found.
      # @return [Uri] the RDF type
      def the_type(uri)
        results = []
        query_string = "SELECT ?t WHERE { #{uri.to_ref} rdf:type ?t }"
        query_results = Sparql::Query.new.query(query_string, "", [])
        Errors.application_error(self.class.name, __method__.to_s, "Unable to find the RDF type for #{uri}.") if query_results.empty?
        query_results.by_object(:t).first
      end

      # Same Type. A set of URIs are of the same type
      # 
      # @params [Array] uris the set of uris
      # @params [Uri] rdf_type the RDF type to be checked against
      # @raise [Errors::ApplicationLogicError] raised if no types found
      # @return [Boolean] true if all of the specified type
      def same_type(uris, rdf_type)
        results = []
        query_string = "SELECT ?t WHERE { VALUES ?s { #{uris.map{|x| x.to_ref}.join(" ")} } . ?s rdf:type ?t }"
        query_results = Sparql::Query.new.query(query_string, "", [])
        Errors.application_error(self.class.name, __method__.to_s, "Unable to find the RDF type for the set of URIs.") if query_results.empty?
        results = query_results.by_object(:t)
        results.map{|x| x.to_s}.uniq.count == 1 && results.first == rdf_type
      end

      # URI Unique
      # 
      # @params [Uri] the_uri the uri
      # @return [Boolean] true if URI unique
      def uri_unique(the_uri)
        query_string = "SELECT ?p WHERE { #{the_uri.to_ref} ?p ?o }"
        query_results = Sparql::Query.new.query(query_string, "", [])
        query_results.empty?
      end

      # -----------------
      # Test Only Methods
      # -----------------

      if Rails.env.test?

        # Check if cache has a key.
        def cache_has_key?(uri)
          return false if !Fuseki::Base.class_variable_defined?(:@@subjects) || Fuseki::Base.class_variable_get(:@@subjects).nil?
          Fuseki::Base.class_variable_get(:@@subjects).key?(uri.to_s)
        end

      end

    end

    # ----------------
    # Instance Methods
    # ----------------

    # Persisted? Is the record persisted (in the DB)
    #
    # @return [Boolean] true if persisted, otherwise false
    def persisted?
      !(@new_record || @destroyed)
    end
      
    # New Record? Is the record a new record.
    #
    # @return [Boolean] true if new, otherwise false
    def new_record?
      @new_record
    end

    # Destroyed? Has the record been destroyed
    #
    # @return [Boolean] true if destroyed, otherwise false
    def destroyed?
      @destroyed
    end

    # Set Persisted. Sets the flags to indicate the record is in the database
    #
    # @return [Void] no return
    def set_persisted
      self.instance_variable_set(:@new_record, false)
      self.instance_variable_set(:@destroyed, false)
      self.properties.saved
    end

    # Id. Gets the id for an object
    #
    # @return [Stirng] the id string
    def id
      self.uri.nil? ? nil : self.uri.to_id
    end

    # UUID. Alias for id
    #
    # @return [Stirng] the id string
    alias uuid id

    # My Type. Get the type for the insance
    # 
    # @raise [Errors::ApplicationLogicError] raised if no type found.
    # @return [Uri] the RDF type
    def true_type
      results = []
      query_string = "SELECT ?t WHERE { #{self.uri.to_ref} rdf:type ?t }"
      query_results = Sparql::Query.new.query(query_string, "", [])
      Errors.application_error(self.class.name, __method__.to_s, "Unable to find true type for #{self.uri}.") if query_results.empty?
      query_results.by_object(:t).first
    end

    # Deprecate true_type
    alias :my_type :true_type

    def transaction_begin
      @transaction = Sparql::Transaction.new
    end

    def transaction_set(transaction)
      @transaction = transaction
    end
    
    def transaction_execute
      @transaction.execute
    end
    
    def transaction_clear
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

    # Update. Update the object with the specified properties if valud
    #
    # @param [Hash] params a hash of properties to be updated
    # @return [Object] returns the object. Not saved if errors are returned.      
    def update(params={})
      @properties.assign(params) if !params.empty?
      selective_update if valid?(:update)
      self
    end

    # Save. Will save the object
    #
    # @return [Object] returns the object. Not saved if errors are returned.      
    def save
      return self if !valid?(persisted? ? :update : :create)
      persisted? ? selective_update : create_or_update(:create)
      self
    end

    def delete
      clear_cache
      Sparql::Update.new.delete(self.uri)
      @destroyed = true
      return 1
    end

    # Generic Links. Gets the links for the named property. Gets as URIs
    #
    # @param name [Symbol] the property name
    # @return [URI|Array] single or array of URIs
    def generic_links(name)
      property = self.properties.property(name)
      property.clear
      query_string = "SELECT ?s ?p ?o WHERE { #{uri.to_ref} #{property.predicate.to_ref} ?s }"
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object(:s).each do |link|
        property.set(link)
      end
      property.get
    end

    # Generic Links? Property populated with URIs
    #
    # @param name [Symbol] the property name
    # @return [Boolean] true if not empty
    def generic_links?(name)
      property = self.properties.property(name)
      property_status(property) != :empty
    end

    # Generic Objects. Gets the objects for the named property.
    #
    # @param name [Symbol] the property name
    # @return [Object|Array] single or array of objects
    def generic_objects(name)
      property = self.properties.property(name)
      property.clear
      query_string = "SELECT ?s ?p ?o WHERE { #{uri.to_ref} #{property.predicate.to_ref} ?s .\n ?s ?p ?o }"
      results = Sparql::Query.new.query(query_string, "", [])
      results.by_subject.each do |subject, triples|
        property.set(property.klass.from_results(Uri.new(uri: subject), triples))
      end
      property.get
    end

    # Generic Objects? Property populated with Objects
    #
    # @param name [Symbol] the property name
    # @return [Boolean] true if not empty and not URIs
    def generic_objects?(name)
      property = self.properties.property(name)
      property_status(property) == :object
    end

    # Add Link. Add a object to a collection
    #
    # @param [Symbol] name the name of the property holding the collection
    # @param [Uri] uri the uri of the object to be linked. 
    # @return [Void] no return
    def add_link(name, uri)
      predicate = self.properties.property(name).predicate
      update_query = %Q{ INSERT { #{self.uri.to_ref} #{predicate.to_ref} #{uri.to_ref} . } WHERE {} }
      partial_update(update_query, [])
    end

    # Delete Link. Delete an object from the collection. Does not delete the object.
    #
    # @param [Symbol] name the name of the property holding the collection
    # @param [Uri] uri the uri of the object to be unlinked. Does not delete the object
    # @return [Void] no return
    def delete_link(name, uri)
      predicate = self.properties.property(name).predicate
      update_query = %Q{ DELETE WHERE { #{self.uri.to_ref} #{predicate.to_ref} #{uri.to_ref} . }}
      partial_update(update_query, [])
    end
  
    # Replace Link. Replace an object in the collection. Does not delete any object.
    #
    # @param [Symbol] name the name of the property holding the collection
    # @param [Uri] old_uri the uri of the object to be unlinked. Does not delete the object
    # @param [Uri] new_uri the uri of the object to be unlinked. Does not delete the object
    # @return [Void] no return
    def replace_link(name, old_uri, new_uri)
      predicate = self.properties.property(name).predicate
      update_query = %Q{ 
        DELETE 
          { #{self.uri.to_ref} #{predicate.to_ref} #{old_uri.to_ref} . }
        INSERT
          { #{self.uri.to_ref} #{predicate.to_ref} #{new_uri.to_ref} . }
        WHERE 
          { #{self.uri.to_ref} #{predicate.to_ref} #{old_uri.to_ref} . }
      }
      partial_update(update_query, [])
    end
  
    # Delete With Links. Delete the object and any links to the object
    #
    # @return [Integer] Number of records deleted
    def delete_with_links
      update_query = %Q{ 
        DELETE {
          #{self.uri.to_ref} ?p1 ?o .
          ?s ?p2 #{self.uri.to_ref} .
        }
        WHERE
        {
          #{self.uri.to_ref} ?p1 ?o .
          ?s ?p2 #{self.uri.to_ref} .
        }
      }
      partial_update(update_query, [])
      1
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

    # To Selective Update. Perform a selective update
    #
    # @return [Object] returns the object
    def selective_update
      clear_cache
      sparql = Sparql::Update.new(@transaction)
      sparql.default_namespace(@uri.namespace)
      predicates = to_selective_sparql(sparql)
      sparql.selective_update(predicates, @uri)
      @new_record = false
      self.properties.saved
      self
    end

    def to_sparql(sparql, recurse=false)
      sparql.add({uri: @uri}, {prefix: :rdf, fragment: "type"}, {uri: self.class.rdf_type})
      self.properties.each do |property|
        next if object_empty?(property)
        property.to_triples(sparql, @uri)
        object_to_triple(sparql, property) if recurse
      end
    end      

    # To Selective Sparql. The SPARQL for a selective update
    #
    # @param [Sparql::Update] sparql the update class
    # @return [Array] the set of predicate URIs
    def to_selective_sparql(sparql)
      results = []
      self.properties.each do |property|
        next if !property.to_be_saved?
        property.to_triples(sparql, @uri)
        results << property.predicate
      end
      results
    end      

    def generate_uri(parent)
      self.uri = create_uri(parent) # Dynamic method 
      properties.each do |property|
        value = property.get
        next if object_empty?(property)
        object_create_uri(property)
      end
    end   

    # Clone. Clones an object copying each property.
    #
    # @return [Object] returns the cloned object
    def clone
      object = self.class.new
      object_properties = object.properties
      properties.each do |property|
        object_property = object_properties.property(property.name)
        object_property.set_raw(property.get.dup)
      end
      object
    end   

    # -----------------
    # Test Only Methods
    # -----------------

    if Rails.env.test?

      # Check if cache has a key.
      def inspect_persistence
        return {new: @new_record, destroyed: @destroyed}
      end

    end

  private

    # Get status of a property
    def property_status(property)
      value = property.get
      if property.array?
        return :empty if value.empty?
        return :uri if value.first.is_a?(Uri)
        return :object if value.first.is_a?(property.klass)
      else
        return :empty if value.nil?
        return :uri if value.is_a?(Uri)
        return :object if value.is_a?(property.klass)        
      end
    end

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
      Fuseki::Base.class_variable_set(:@@subjects, Hash.new {|h, k| h[k] = {}}) if !Fuseki::Base.class_variable_defined?(:@@subjects) || Fuseki::Base.class_variable_get(:@@subjects).nil?
      Fuseki::Base.class_variable_get(:@@subjects).delete(self.uri.to_s)
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

    def object_empty?(property)
      return false if !property.object? 
      value = property.get
      return true if value.nil?
      return true if property.array? && value.empty?
      return false
    end

  end

end