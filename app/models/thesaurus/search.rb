class Thesaurus

  module Search

    @@column_map = 
    {
      "0" => "?pi",   # parent identifier
      "1" => "?i",    # identifier
      "2" => "?n",    # notation
      "3" => "?pt",   # preferred term
      "4" => "?sy",   # synonym
      "5" => "?d"     # definition
    }  

    @@order_map = 
    {
      "desc" => "DESC",
      "asc" => "ASC"
    }
      
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      # Empty Search? No search parameters
      # 
      # @param params [Hash]  the hash sent by datatables for a search.
      # @return [Boolean] true if empty, otherwise false
      def self.empty_search?(params)
        params[:columns].each {|key, column| return false if !column[:search][:value].blank?}
        return false if !params[:search][:value].blank?
        return true
      end

    end

    # Search. 
    # 
    # @param params [Hash] the hash sent by datatables for a search.
    # @return [Hash] a hash containing :count wiht the number of records that could be returned and
    #    :items which is an array of results.
    def search(params)
      results = []
      query_results = Sparql::Query.new.query(query_string(params), "", [:bo, :th, :isoC])
      triples = query_results.by_object_set([:pi, :i, :n, :d, :pt, :uri])
      triples.each do |t|
        results << {uri: t[:uri].to_s, parent_identifier: t[:pi], identifier: t[:i], notation: t[:n], definition: t[:d], preferred_term: t[:pt], synonym: ""}
      end
      return { count: search_count(params), items: results }
    end

  private

    # Search resut count
    def search_count(params)
      results = []
      query_results = Sparql::Query.new.query(query_string(params, false), "", [:bo, :th, :isoC])
      query_results.results.count
    end

    # Build the search query string
    def query_string(params, limit=true)
      search = params[:search]
      columns = params[:columns]
      variable = get_order_variable(params[:order]["0"][:column])
      order = get_order(params[:order]["0"][:dir])
      main_part = %Q{
        #{self.uri.to_ref} th:isTopConceptReference/bo:reference ?mc .
        {
          ?mc th:narrower+ ?uc .
          ?mc th:identifier ?pi .
          ?uc th:identifier ?i .
          ?uc th:notation ?n .
          ?uc th:preferredTerm/isoC:label ?pt .
          ?uc th:definition ?d .
          BIND (?uc as ?uri)
        } UNION
        {
          ?mc th:identifier ?pi .
          ?mc th:identifier ?i .
          ?mc th:notation ?n .
          ?mc th:preferredTerm/isoC:label ?pt .
          ?mc th:definition ?d .    
          BIND (?mc as ?uri)
        }
      }
      query = "SELECT DISTINCT ?pi ?i ?n ?d ?pt ?uri WHERE\n"
      query += "{\n"
      query += "  #{main_part}"
      
      # Filter by columns
      columns.each do |column|
        next if column[1][:search][:value].blank?
        query += "  FILTER regex(#{get_order_variable(column[0])}, \"#{column[1][:search][:value]}\", 'i') .\n" 
      end
      
      # Overall search
      query += "  ?uri (th:identifier|th:notation|th:preferredTerm|th:definition) ?i . FILTER regex(?i, \"" + search[:value] + "\", 'i') . \n" if !search[:value].blank?

      # And close it all
      query += "}" 
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

  end

end