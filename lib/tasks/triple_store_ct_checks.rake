namespace :triple_store do

  desc "Draft Updates"

  # Format results as a simple table
  def display_results(items, labels, widths=[])
    results = [labels]
    results += items.map { |x| x.values }
    max_lengths = results[0].map { |x| x.length }
    unless widths.empty?
      results.each_with_index do |x, j|
        x.each_with_index do |e, i|
          next if widths[i] == 0 
          results[j][i]= "#{e.to_s[0..widths[i]-1]}[...]" if e.to_s.length > widths[i]
        end
      end
    end
    results.each do |x|
      x.each_with_index do |e, i|
        s = e.to_s.length
        max_lengths[i] = s if s > max_lengths[i]
      end
    end
    format = max_lengths.map {|y| "%#{y}s"}.join(" " * 3)
    puts format % results[0]
    puts format % max_lengths.map { |x| "-" * x }
    results[1..-1].each do |x| 
      puts format % x 
    end
    puts "\n\n"
  end

  # Custom Property Errors
  def cp_errors
    query_string = %Q{
      SELECT ?cli ?cl ?e ?l WHERE 
      {            
        ?e rdf:type isoC:CustomProperty .
        ?e isoC:appliesTo ?cli .          
        ?e isoC:context ?cl . 
        FILTER ( NOT EXISTS { ?cl th:narrower ?cli } )
        ?e isoC:customPropertyDefinedBy/isoC:label ?l         
      }  
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    items = query_results.by_object_set([:cl, :cli, :e])
    display_results(items, ["CL Uri", "CLI Uri", "Custom Property", "Name"], [0, 0, 0, 0])
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
    display_results(items, ["CL Uri", "CLI Uri", "Label"], [0, 0, 0])
    items
  end

  # Actual rake task
  task :ct_checks => :environment do
    cp_errors
    subset_errors
  end

end