# Thesaurus Search
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus

  module Search

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      @@column_map = 
      {
        "0" => "?pi",   # parent identifier
        "1" => "?pl",   # parent label
        "2" => "?i",    # identifier
        "3" => "?n",    # notation
        "4" => "?pt",   # preferred term
        "5" => "?sy",   # synonym
        "6" => "?d",    # definition
        "7" => "?t",    # tags
      }  

      @@order_map = 
      {
        "desc" => "DESC",
        "asc" => "ASC"
      }
      
      # Search Current. Search the current set. 
      # 
      # @param params [Hash] the hash sent by datatables for a search.
      # @return [Hash] a hash containing :count with the number of records that could be returned and
      #    :items which is an array of results.
      # def search_current(params)
      #   #search_multiple(params, self.current_set)
      #   search_multiple(params, self.current_and_latest_set.map{|k,v| v.last[:uri]}) # Note, current will the second (last) entry, latest first.
      # end

      # Empty Search? No search parameters
      # 
      # @param params [Hash]  the hash sent by datatables for a search.
      # @return [Boolean] true if empty, otherwise false
      def empty_search?(params)
        params[:columns].each {|key, column| return false if !column[:search][:value].blank?}
        return false if !params[:search][:value].blank?
        return true
      end

      # Search Multiple
      # 
      # @param params [Hash] the hash sent by datatables for a search.
      # @param uris [Array] an array of URIs of the items to be searched.
      # @return [Hash] a hash containing :count with the number of records that could be returned and
      #    :items which is an array of results.
      def search_multiple(params, uris)
        results = []
        query_results = Sparql::Query.new.query(search_query_string(params, uris), "", [:bo, :th, :isoC, :isoT, :isoI])
        triples = query_results.by_object_set([:pi, :i, :n, :d, :pt, :sys, :uri, :thi, :thv])
        triples.each do |t|
          results << {id: t[:uri].to_id, uri: t[:uri].to_s, parent_identifier: t[:pi], parent_label: t[:pl], identifier: t[:i], notation: t[:n], 
            definition: t[:d], preferred_term: t[:pt], synonym: t[:sys], tags: t[:gt], thesaurus_identifier: t[:thi], thesaurus_version: t[:thv]}
        end
        return { count: search_count(params, uris), items: results }
      end

    private

      # Search resut count
      def search_count(params, uris)
        results = []
        query_results = Sparql::Query.new.query(search_query_string(params, uris, false), "", [:bo, :th, :isoC, :isoT, :isoI])
        query_results.results.count
      end

      # Build the search query string
      def search_query_string(params, uris, limit=true)
        search = params[:search]
        columns = params[:columns]
        variable = get_order_variable(params[:order]["0"][:column])
        order = get_order(params[:order]["0"][:dir])

        # Search Clauses
        # 1. Column Filters
        # 2. Overall Filter
        search_clauses = ""
        columns.each do |column|
          next if column[1][:search][:value].blank?
          if column[0] == "7"
            search_clauses += "  FILTER(UCASE(#{get_order_variable(column[0])}) IN (  #{get_tags_filter(column[1][:search][:value])}  )  ) .\n" #Tags filter
          else
            column_filter = Thesaurus::Syntax.new("#{column[1][:search][:value]}")
            search_clauses += column_filter.array_to_sparql(get_order_variable(column[0]))
          end
        end
        if !search[:value].blank?
          overall_filter = Thesaurus::Syntax.new("#{search[:value]}")
          search_clauses += "  ?uri (th:identifier|th:notation|th:preferredTerm/isoC:label|th:synonym/isoC:label|th:definition|isoC:tagged/isoC:prefLabel) ?x "
          search_clauses += overall_filter.array_to_sparql("?x") #Advanced overall search
        end
        #search_clauses += "  ?uri (th:identifier|th:notation|th:preferredTerm/isoC:label|th:synonym/isoC:label|th:definition|isoC:tagged/isoC:prefLabel) ?x . FILTER regex(?x, \"" + search[:value] + "\", 'i') . \n" if !search[:value].blank?
        # Main SPARQL
        main_part = %Q{
          {
            SELECT DISTINCT ?pi ?pl ?i ?n ?d ?pt ?uri ?thi ?thv ?t ?sy
            {
              VALUES ?e { #{uris.map{|x| x.to_ref}.join(" ")} }
              ?e th:isTopConceptReference/bo:reference ?mc .
              ?e isoT:hasIdentifier/isoI:identifier ?thi .
              ?e isoT:hasIdentifier/isoI:semanticVersion ?thv .
              {
                {
                  ?mc th:narrower+ ?uc .
                  ?mc th:identifier ?pi .
                  ?mc isoC:label ?pl .
                  ?uc th:identifier ?i .
                  ?uc th:notation ?n .
                  ?uc th:definition ?d .
                  ?uc th:preferredTerm/isoC:label ?pt .
                  OPTIONAL {?uc th:synonym/isoC:label ?sy .}
                  OPTIONAL {?uc isoC:tagged/isoC:prefLabel ?t .}
                  BIND (?uc as ?uri)
                } UNION
                {
                  ?mc th:identifier ?pi .
                  ?mc th:identifier ?i .
                  ?mc isoC:label ?pl .
                  ?mc th:notation ?n .
                  ?mc th:definition ?d .    
                  ?mc th:preferredTerm/isoC:label ?pt .
                  OPTIONAL {?mc th:synonym/isoC:label ?sy .}
                  OPTIONAL {?mc isoC:tagged/isoC:prefLabel ?t .}
                  BIND (?mc as ?uri)
                }
              }
              #{search_clauses}
            } ORDER BY ?sy ?t  
          }
        }
        tag_grp = %Q{(GROUP_CONCAT(DISTINCT ?t;separator=\"#{IsoConceptSystem.tag_separator} \") as ?gt)}
        synonym_grp = %Q{(GROUP_CONCAT(DISTINCT ?sy;separator=\"#{Thesaurus::ManagedConcept.synonym_separator} \") as ?sys)}
        query = "SELECT DISTINCT ?pi ?pl ?i ?n ?d ?pt ?uri ?thi ?thv #{synonym_grp} #{tag_grp} WHERE\n"
        query += "{\n"
        query += "  #{main_part}"
        query += "}" 
        query += " GROUP BY ?pi ?pl ?i ?n ?d ?pt ?uri ?thi ?thv"
        query += " ORDER BY #{order} (#{variable}) OFFSET #{params[:start]} LIMIT #{params[:length]}" if limit
        query
      end

      # Get the correct variable to order on
      def get_order_variable(col)
        variable = @@column_map["0"] # Default
        variable = @@column_map[col] if @@column_map.has_key?(col)
      end  
      
      # Get the right ordering for SPARQL
      def get_order(dir)
        order = @@order_map["asc"]
        order = @@order_map[dir] if @@order_map.has_key?(dir)
      end

      # Get tags ready for search
      def get_tags_filter(text)
        text.trim('"').split(IsoConceptSystem.tag_separator).map{|x| "'#{x.trim(' ').upcase}'"}.join(", ")
      end

    end

    # Search. 
    # 
    # @param params [Hash] the hash sent by datatables for a search.
    # @return [Hash] a hash containing :count with the number of records that could be returned and
    #    :items which is an array of results.
    def search(params)
      self.class.search_multiple(params, [self.uri])
    end

  end

end