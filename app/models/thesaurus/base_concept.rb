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
    # @params params [Hash] the params hash containing the concept data {:notation. :preferredTerm, :synonym, :definition, :identifier}
    # @return [Thesaurus::UnmanagedConcept] the object created. Errors set if create failed.
    def add_child(params)
      child = Thesaurus::UnmanagedConcept.empty_concept
      child.merge!(params)
      child[:identifier] = Thesaurus::UnmanagedConcept.generated_identifier? ? Thesaurus::UnmanagedConcept.new_identifier : params[:identifier]
      child[:transaction] = transaction_begin
      child = Thesaurus::UnmanagedConcept.create(child, self)
      return child if child.errors.any?
      self.add_link(:narrower, child.uri)
      transaction_execute
      child
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
      {identifier: self.identifier, definition: self.definition, label: self.label, notation: self.notation, preferred_term: preferred_term_to_s, synonym: synonyms_to_s, extensible: self.extensible, id: self.uri.to_id}
    end

    def preferred_term_to_s
      return "" if self.preferred_term.nil?
      self.preferred_term.label
    end
    
    # Synonym Links. Find all items within the context that share the synonyms
    #
    # @param [Hash] params the parameters
    # @option params [String] :context_id the identifier of the thesaurus context to work within. 
    #   will find all if not present
    # @return [Hash] the results hash
    def linked_by_synonym(params)
      generic_find_links(params, :synonym)
    end

    # Preferred Term Links. Find all items within the context that share the preferred term
    #
    # @param [Hash] params the parameters
    # @option params [String] :context_id the identifier of the thesaurus context to work within. 
    #   will find all if not present
    # @return [Hash] the results hash
    def linked_by_preferred_term(params)
      generic_find_links(params, :preferred_term)
    end

  private

    # Generic Find Links. Find all items within the context that share synonyms or preferred terms
    #
    # @param [Hash] params the parameters
    # @option params [String] :context_id the identifier of the thesaurus context to work within. 
    #   will find all if not present
    # @param [Symbol] the property name, either :synonym or :preferred_term
    # @return [Hash] the results hash
    def generic_find_links(params, property_name)
      predicate = self.properties.property(property_name).predicate
      context_filter = params.key?(:context_id) ? %Q{?th th:isTopConceptReference/bo:reference ?p .
  FILTER (STR(?th) = "#{Uri.new(id: params[:context_id]).to_s}") .} : ""
      query_string = %Q{
  SELECT DISTINCT ?c ?p ?syn ?p_n ?p_id ?c_n ?c_id ?p_d WHERE
  {          
    {     
      #{self.uri.to_ref} #{predicate.to_ref} ?s .
      ?s isoC:label ?syn .
      ?c #{predicate.to_ref} ?s .
      FILTER (STR(?c) != "#{self.uri.to_s}") .
      {
        ?p th:narrower+ ?c .
        ?p rdf:type th:ManagedConcept .
        #{context_filter}
        ?p th:notation ?p_n .
        ?p th:identifier ?p_id .
        ?p isoT:lastChangeDate ?p_d .
      } UNION
      {
        ?c rdf:type th:ManagedConcept .
        ?c th:identifier ?p_id .
        ?c th:notation ?p_n .
        ?c isoT:lastChangeDate ?p_d .
        BIND (?c as ?p)
        BIND ("" as ?c_n)
        BIND ("" as ?c_id)
      }
      ?c th:identifier ?c_id .
      ?c th:notation ?c_n .
    } 
  }}
      query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC, :isoT])
      results = {}
      if property_name == :synonym 
        self.synonym.each {|s| results[s.label] = {description: s.label, references: []}}
      else
        results[self.preferred_term.label] = {description: self.preferred_term.label, references: []}
      end
      query_results.by_object_set([:c, :p, :syn, :p_id, :c_id]).each do |x|
        results[x[:syn]][:references] << {parent: {identifier: x[:p_id], notation: x[:p_n], date: x[:p_d]}, child: {identifier: x[:c_id], notation: x[:c_n]}, id: x[:c].to_id}
      end
      results
    end

  end

end