class Thesaurus

  module BaseConcept

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      # Exists?
      #
      # @param identifier [String] The identifier to be found
      # @return [Boolean] true if found, false otherwise
      def exists?(identifier)
        !where_only({identifier: identifier}).nil?
      end
    
    end

    # Add a child concept
    #
    # @params params [Hash] the params hash containig the concept data {:label, :notation. :preferredTerm, :synonym, :definition, :identifier}
    # @return [Thesaurus::UnmanagedConcept] the object created. Errors set if create failed.
    def add_child(params)
      object = Thesaurus::UnmanagedConcept.from_h(params)
      return object if !object.valid?(:create)
      sparql = Sparql::Update.new
      sparql.default_namespace(self.uri.namespace)
      object.to_sparql(sparql, true)
      sparql.add({:uri => self.uri}, {:prefix => :th, :fragment => "narrower"}, {:uri => object.uri})
      sparql.create
      object
    end

    # Delete. Don't allow if children present.
    #
    # @return [Integer] the number of rows deleted.
    def delete
      return super if !children?
      self.errors.add(:base, "Cannot delete terminology concept with identifier #{self.identifier} due to the concept having children")
      return 0
    end

    # Set Parent
    #
    # @return [Void] no return
    def parent
      results = Sparql::Query.new.query(parent_query, "", [:th])
      Errors.application_error(self.class.name, __method__.to_s, "Failed to find parent for #{identifier}.") if results.empty?
      return results.by_object(:i).first
    end

    # To CSV No Header. A CSV record with no header
    #
    # @return [Array] the CSV record
    def to_csv_no_header
      to_csv_by_key(:identifier, :label, :notation, :synonym, :definition, :preferredTerm)
    end

  end

end