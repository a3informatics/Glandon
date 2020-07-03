# Thesaurus base Concept. Common methods for thesaurus concept handling. 
#
# @author Dave Iberson-Hurst
# @since 2.21.0
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

      # Children Set. Get the children in pagination manner
      #
      # @params [Array] uris an array of uris
      # @return [Array] array of hashes containing the child data
      def children_set(uris)
        results =[]
        # Get the final result
        query_string = %Q{
          SELECT DISTINCT ?i ?n ?d ?pt ?e ?del (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{self.synonym_separator} \") as ?sys) ?s WHERE
          {
            SELECT DISTINCT ?i ?n ?d ?pt ?e ?del ?s ?sy WHERE
            {
              VALUES ?s { #{uris.map{|x| x.to_ref}.join(" ")} }
              {
                ?s th:identifier ?i .
                ?s th:notation ?n .
                ?s th:definition ?d .
                ?s th:extensible ?e .
                OPTIONAL {?s th:preferredTerm/isoC:label ?pt .}
                OPTIONAL {?s th:synonym/isoC:label ?sy .}
              }
            } ORDER BY ?i ?sy
          } GROUP BY ?i ?n ?d ?pt ?e ?s ?del ORDER BY ?i
          }
        query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC])
        query_results.by_object_set([:i, :n, :d, :e, :pt, :sys, :s, :del]).each do |x|
          results << {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], extensible: x[:e].to_bool, definition: x[:d], delete: false, uri: x[:s].to_s, id: x[:s].to_id}
        end
        results
      end

    end

    # Synonyms and Preferred Terms. Reads the synonyms and preferred terms
    #
    # @return [Void] no return
    def synonyms_and_preferred_terms
      self.synonym_objects
      self.preferred_term_objects
    end

    # Add Child. Add a single child concept. This concept will be "owned" by the parent.
    #
    # @params params [Hash] the params hash containing the concept data {:notation. :preferredTerm, :synonym, :definition, :identifier}
    # @return [Thesaurus::UnmanagedConcept] the object created. Errors set if create failed.
    def add_child(params)
      child = Thesaurus::UnmanagedConcept.empty_concept
      child.merge!(params)
      child[:identifier] = Thesaurus::UnmanagedConcept.generated_identifier? ? Thesaurus::UnmanagedConcept.new_identifier : params[:identifier]
      child[:transaction] = transaction_begin
      child = Thesaurus::UnmanagedConcept.create(child, self)
      self.valid_child?(child) # Errors placed into child.
      return child if child.errors.any?
      self.add_link(:narrower, child.uri)
      set_rank(self, child) if self.class.name == "Thesaurus::ManagedConcept" && self.ranked?
      transaction_execute
      child
    end

    # Add Children Based On. Create "owned" child concepts based on exisiting synonyms
    #
    # @params params [Object] the object on which the children are based 
    # @return [Thesaurus::UnmanagedConcept] the children created
    def add_children_based_on(object)
      pt = object.preferred_term_objects
      synonyms = object.synonym_objects
      tx = transaction_begin
      synonyms.each do |syn|
        child = Thesaurus::UnmanagedConcept.create({
          identifier: Thesaurus::UnmanagedConcept.new_identifier,
          notation: syn.label,
          label: syn.label ,
          preferred_term: Thesaurus::PreferredTerm.where_only_or_create(syn.label),
          synonym: synonyms,
          definition: object.definition,
          tagged: object.tagged,
          transaction: tx
        }, self)
        self.valid_child?(child) # Errors placed into child.
        return [child] if child.errors.any?
        self.add_link(:narrower, child.uri)
      end
      transaction_execute
      self.narrower_objects
    end

    # Children Pagination. Get the children in pagination manner
    #
    # @params [Hash] params the params hash
    # @option params [String] :offset the offset to be obtained
    # @option params [String] :count the count to be obtained
    # @option params [Array] :tags the tag to be displayed
    # @return [Array] array of hashes containing the child data
    def children_pagination(params)
      results =[]
      count = params[:count].to_i
      offset = params[:offset].to_i
      tags = params.key?(:tags) ? params[:tags] : []

      # Get the URIs for each child
      query_string = %Q{
        SELECT ?e WHERE
        {
          #{self.uri.to_ref} th:narrower ?e .
          ?e th:identifier ?v
        } ORDER BY (?v) LIMIT #{count} OFFSET #{offset}
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th, :bo])
      uris = query_results.by_object_set([:e]).map{|x| x[:e]}
      # Get the final result
      tag_clause = tags.empty? ? "" : "VALUES ?t { '#{tags.join("' '")}' } "
      query_string = %Q{
        SELECT DISTINCT ?i ?n ?d ?pt ?e ?del ?sp ?rank (count(distinct ?ci) AS ?countci) (count(distinct ?cn) AS ?countcn) (GROUP_CONCAT(DISTINCT ?sy;separator=\"#{self.class.synonym_separator} \") as ?sys) (GROUP_CONCAT(DISTINCT ?t ;separator=\"#{IsoConceptSystem.tag_separator} \") as ?gt) ?s WHERE\n
        {
          SELECT DISTINCT ?i ?n ?d ?pt ?e ?del ?sp ?s ?sy ?t ?ci ?cn ?rank WHERE
          {
            VALUES ?s { #{uris.map{|x| x.to_ref}.join(" ")} }
            {
              ?s th:identifier ?i .
              ?s th:notation ?n .
              ?s th:definition ?d .
              ?s th:extensible ?e .
              OPTIONAL {?ci (ba:current/bo:reference)|(ba:previous/bo:reference) ?s .?ci rdf:type ba:ChangeInstruction .}
              OPTIONAL {?s ^(ba:current/bo:reference) ?cn . ?cn rdf:type ba:ChangeNote }
              OPTIONAL {?s ^(th:item) ?rank_member . #{self.uri.to_ref} th:isRanked/th:members/th:memberNext* ?rank_member . ?rank_member th:rank ?rank }
              BIND(EXISTS {#{self.uri.to_ref} th:extends ?src} && NOT EXISTS {#{self.uri.to_ref} th:extends/th:narrower ?s} as ?del)
              BIND(EXISTS {#{self.uri.to_ref} th:refersTo ?s} as ?sp)
              OPTIONAL {?s th:preferredTerm/isoC:label ?pt .}
              OPTIONAL {?s th:synonym/isoC:label ?sy .}
              OPTIONAL {?s isoC:tagged/isoC:prefLabel ?t . #{tag_clause}}
            }
          } ORDER BY ?i ?sy ?t
        } GROUP BY ?i ?n ?d ?pt ?e ?s ?del ?sp ?countci ?countcn ?rank ORDER BY ?i
      }
# BIND(NOT EXISTS {?s ^th:narrower ?r . FILTER (?r != #{self.uri.to_ref})} as ?sp)
      query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC, :ba])
      query_results.by_object_set([:i, :n, :d, :e, :pt, :sys, :s, :del, :sp, :gt, :rank]).each do |x|
        indicators = {annotations: {change_notes: x[:countcn].to_i, change_instructions: x[:countci].to_i}}
        results << {identifier: x[:i], notation: x[:n], preferred_term: x[:pt], synonym: x[:sys], tags: x[:gt], extensible: x[:e].to_bool, definition: x[:d], delete: x[:del].to_bool, referenced: x[:sp].to_bool, uri: x[:s].to_s, id: x[:s].to_id,rank: x[:rank], indicators: indicators}
      end
      results
    end

    # Filtered Tag Labels. Get the tags labels filtered by the tags in the quoted CT if the CT is owned by CDISC
    #
    # @params [Thesaurus] ct the CT. Can be nil resulting in no filtering.
    # @return [Array] the resulting array of tags
    def filtered_tag_labels(ct)
      return self.tag_labels if ct.nil?
      return self.tag_labels & ct.tag_labels if ct.is_owned_by_cdisc?
      self.tag_labels
    end

    # Update. Specific update to control synonyms, PT and prevent identifier being updated.
    #
    # @param params [Hash] the new properties
    # @return [Object] the updated object
    def update(params)
      update_synonyms(params)
      update_preferred_term(params)
      self.properties.assign(params.slice!(:synonym, :preferred_term, :identifier)) # Note, cannot change the identifier once set!!!
      self.save
    end

    # Parents
    #
    # @return [Void] no return
    def parents
      results = Sparql::Query.new.query(parent_query, "", [:th, :bo])
      return results.by_object(:s)
    end

    # Multiple Parents. Check if concept has multiple parents (used in multiple collections)
    #
    # @return [Boolean] true if used multiple times, false otherwise
    def multiple_parents?
      parents.count > 1
    end

    # Multiple Parents. Check if concept has multiple parents (used in multiple collections)
    #
    # @return [Boolean] true if used multiple times, false otherwise
    def no_parents?
      parents.empty?
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

    def difference_record_deleted
      result = {}
      [:identifier, :notation, :definition, :extensible, :synonym, :preferred_term].each do |x|
        result[x] = {status: :deleted, previous: "", current: "", difference: ""}
      end
      result
    end

    # Simple To Hash. Output the concept as a simple hash.
    #
    # @return [Hash] the hash for the object
    def simple_to_h
      {identifier: self.identifier, definition: self.definition, label: self.label, notation: self.notation, preferred_term: preferred_term_to_s, synonym: synonyms_to_s, extensible: self.extensible, id: self.uri.to_id}
    end

    # To Json
    #
    # @return [Hash] the hash for the object
    alias :to_json :simple_to_h

    # Preferred Term To String
    #
    # @return [String] the label or empty string if no preferred term
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

    # Linked Change Instructions. Find all items linked by change instructions
    #
    # @return [Hash] the results hash
    def linked_change_instructions
      results = {description: nil, previous: [], current: []}
      query_string = %Q{
  SELECT DISTINCT ?c ?p ?desc ?p_n ?p_id ?c_n ?c_id ?p_d ?t WHERE
  {
    {
      ?ci (ba:previous/bo:reference) #{self.uri.to_ref} .
      ?ci (ba:current/bo:reference) ?c .
      ?ci (ba:current/bo:context) ?th .
      BIND ("current" as ?t)
    } UNION
    {
      ?ci (ba:current/bo:reference) #{self.uri.to_ref} .
      ?ci (ba:previous/bo:reference) ?c .
      ?ci (ba:previous/bo:context) ?th .
      BIND ("previous" as ?t)
    }
    ?ci ba:description ?desc .
    OPTIONAL {
      ?th th:isTopConceptReference/bo:reference ?p .
      ?p rdf:type th:ManagedConcept .
      ?p th:narrower ?c .
      ?p th:notation ?p_n .
      ?p th:identifier ?p_id .
      ?p isoT:lastChangeDate ?p_d .
      ?c th:notation ?c_n .
      ?c th:identifier ?c_id
    }
    OPTIONAL {
      ?c rdf:type th:ManagedConcept .
      ?c th:identifier ?p_id .
      ?c th:notation ?p_n .
      ?c isoT:lastChangeDate ?p_d .
      BIND (?c as ?p)
      BIND ("" as ?c_n)
      BIND ("" as ?c_id)
    }
  }}
      query_results = Sparql::Query.new.query(query_string, "", [:ba, :th, :bo, :isoC, :isoT])
      query_results.by_object_set([:c, :p, :desc, :p_id, :c_id, :p_n, :c_n, :t]).each do |x|
        results[:description] = x[:desc] if results[:description].nil?
        results[x[:t].to_sym] << {parent: {id: x[:p].to_id ,identifier: x[:p_id], notation: x[:p_n], date: x[:p_d]}, child: {identifier: x[:c_id], notation: x[:c_n]}, id: x[:c].to_id}
      end
      results
    end

  private

    # Update preferred term with checks
    def update_preferred_term(params)
      return unless params.key?(:preferred_term) && !params[:preferred_term].empty? # Preferred Term must not be cleared
      new_pt = Thesaurus::PreferredTerm.where_only_or_create(params[:preferred_term])
      if new_pt.errors.empty?
        params[:label] = new_pt.label # Always force the label to be the same as the PT.
      end
      new_pt.errors.clear
      self.preferred_term = new_pt
    end

    # Update synonyms with checks
    def update_synonyms(params)
      return unless params.key?(:synonym)
      synonyms = where_only_or_create_synonyms(params[:synonym]) if params.key?(:synonym)
      synonyms.each {|x| x.errors.clear}
      self.synonym = synonyms
    end

    # Set Rank. 
    #
    # @param mc [String] the id of the cli to be updated
    # @param child [Integer] the rank to be asigned to the cli
    def set_rank(mc, child)
      rank = mc.is_ranked
      query_string = %Q{
        SELECT (max(?rank) as ?maxrank) WHERE {
          #{rank.to_ref} (th:members/th:memberNext*) ?s .
          ?s th:rank ?rank .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      max_rank = query_results.by_object(:maxrank)
      max_rank.empty? ? max_rank = 0 : max_rank = max_rank[0].to_i
      sparql = Sparql::Update.new
      sparql.default_namespace(rank.namespace)
      member = Thesaurus::RankMember.new(item: Uri.new(id: child.uri.to_id), rank: max_rank + 1)
      member.uri = member.create_uri(mc.uri)
      member.to_sparql(sparql)
      last_sm = Thesaurus::Rank.find(rank).last
      last_sm.nil? ? sparql.add({uri: rank}, {namespace: Uri.namespaces.namespace_from_prefix(:th), fragment: "members"}, {uri: member.uri}) : sparql.add({uri: last_sm.uri}, {namespace: Uri.namespaces.namespace_from_prefix(:th), fragment: "memberNext"}, {uri: member.uri})
      #filename = sparql.to_file
      sparql.create
    end

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
        results[x[:syn]][:references] << {parent: {id: x[:p].to_id, identifier: x[:p_id], notation: x[:p_n], date: x[:p_d]}, child: {identifier: x[:c_id], notation: x[:c_n]}, id: x[:c].to_id}
      end
      results
    end

  end

end
