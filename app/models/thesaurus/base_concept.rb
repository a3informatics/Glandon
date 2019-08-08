class Thesaurus

  module BaseConcept

    C_NOT_SET = "Not Set"

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
    
      def empty_concept
        {label: C_NOT_SET, identifier: C_NOT_SET, notation: C_NOT_SET, definition: C_NOT_SET, extensible: false, preferred_term: Thesaurus::PreferredTerm.where_only_or_create(C_NOT_SET)}
      end

    end

    # Children?
    #
    # @return [Boolean] True if there are children, false otherwise
    def children?
      return extended_with.any? || narrower.any? || !is_subset.blank?
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

    # Update. Specific update to control synonyms, PT and prevent identifier being updatedf.
    #
    # @param params [Hash] the new properties
    # @return [Void] no return
    def update(params)
      self.synonym = where_only_or_create_synonyms(params[:synonym]) if params.key?(:synonym)
      if params.key?(:preferred_term)
        self.preferred_term = Thesaurus::PreferredTerm.where_only_or_create(params[:preferred_term]) 
        params[:label] = self.preferred_term.label # Always force the label to be the same as the PT.
      end
      self.properties.assign(params.slice!(:synonym, :preferred_term, :identifier)) # Note, cannot change the identifier once set!!!
      save
    end

    # Parent
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

    def difference_record(current, previous)
      result = {}
      [:identifier, :notation, :definition, :extensible, :synonym, :preferred_term].each do |x|
        status = current[x] == previous[x] ? :no_change : :updated
        diff = status == :updated ? Diffy::Diff.new(previous[x], current[x]).to_s(:html) : ""
        result[x] = {status: status, previous: previous[x], current: current[x], difference: diff }
      end
      result
    end

    def difference?(current, previous)
      result = {}
      [:identifier, :notation, :definition, :extensible, :synonym, :preferred_term].each do |x|
        return true if current[x] != previous[x]
      end
      false
    end

    def difference_record_baseline(current)
      result = {}
      [:identifier, :notation, :definition, :extensible, :synonym, :preferred_term].each do |x|
        result[x] = {status: :created, previous: "", current: current[x], difference: ""} 
      end
      result
    end

    def simple_to_h
      {identifier: self.identifier, definition: self.definition, label: self.label, notation: self.notation, preferred_term: self.preferred_term.label, synonym: synonyms_to_s, extensible: self.extensible, id: self.uri.to_id}
    end

  end

end