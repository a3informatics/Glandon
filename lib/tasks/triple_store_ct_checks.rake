namespace :triple_store do

  desc "Triple Store CT Checks"

  # Custom Property Not in CL Errors
  def cp_not_in_cl_errors
    query_string = %Q{
      SELECT ?cli ?cl ?e ?l ?v WHERE 
      {            
        ?e rdf:type isoC:CustomProperty .
        ?e isoC:appliesTo ?cli .          
        ?e isoC:context ?cl . 
        FILTER ( NOT EXISTS { ?cl th:narrower ?cli } )
        ?e isoC:customPropertyDefinedBy/isoC:label ?l .
        ?e isoC:value ?v  
      }  
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    items = query_results.by_object_set([:cl, :cli, :e, :l, :v])
    display_results("Custom Properties Not In CL Errors", items, ["CL Uri", "CLI Uri", "Custom Property", "Name", "Value"], [0, 0, 0, 20, 40])
    items
  end

  # Custom Property No CLI Errors
  def cp_no_cli_errors
    query_string = %Q{
      SELECT ?cli ?cl ?e ?l ?v WHERE 
      {            
        ?e rdf:type isoC:CustomProperty .
        ?e isoC:context ?cl . 
        FILTER ( NOT EXISTS { ?e isoC:appliesTo ?x } )
        ?e isoC:customPropertyDefinedBy/isoC:label ?l .
        ?e isoC:value ?v  
      }  
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    items = query_results.by_object_set([:cl, :cli, :e, :l, :v])
    display_results("Custom Properties No CL Item Errors", items, ["CL Uri", "CLI Uri", "Custom Property", "Name", "Value"], [0, 0, 0, 20, 40])
    items
  end

  # Custom Property Duplicate Errors
  def cp_duplicate_errors
    keys = {}
    results = Hash.new {|h,k| h[k] = [] }
    query_string = %Q{
      SELECT DISTINCT ?cli ?e ?d ?c WHERE 
      {            
        ?e isoC:appliesTo ?cli .
        ?e isoC:customPropertyDefinedBy ?d .
        ?e isoC:context ?c .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    items = query_results.by_object_set([:cli, :e, :d, :c])
    items.each_with_index do |x, index|
      print "." if index % 100 == 0
      the_key = "#{x[:cli]}.#{x[:d]}}"
      if keys.key?(the_key) 
        if keys[the_key][:e] != x[:e] && keys[the_key][:c] == x[:c]
          results[the_key] << keys[the_key] if results[the_key].empty?
          results[the_key] << x 
        end
      else
        keys[the_key] = x
      end
    end
    final_results = []
    results.each { |k, v|  final_results += v}
    display_results("Custom Properties Duplicate Errors", final_results, ["CLI Uri", "Custom Property Uri", "Definition Uri", "Context"], [0, 0, 0, 0])
    items
  end

  # Subset Errors
  def subset_errors
    query_string = %Q{
      SELECT ?cli ?cl ?l WHERE 
      {            
        ?cl rdf:type th:ManagedConcept .
        ?cl th:subsets ?m .          
        ?cl th:narrower ?cli . 
        ?cl isoC:label ?l .
        FILTER ( NOT EXISTS { ?cl th:refersTo ?cli } )
      }  
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    items = query_results.by_object_set([:cl, :cli, :l])
    display_results("Subset Errors", items, ["CL Uri", "CLI Uri", "Label"], [0, 0, 0])
    items
  end

  # Actual rake task
  task :ct_checks => :environment do
    
    include RakeDisplay

    cp_not_in_cl_errors
    cp_no_cli_errors
    cp_duplicate_errors
    subset_errors
  end

end