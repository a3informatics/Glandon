namespace :triple_store do

  desc "Triple Store Schema Listing"

  # Format results as a simple table
  def triple_store_schema_list_results(xs)
    puts "\n\n"
    max_lengths = Array.new(xs[0].length, 0)
    xs.each do |x|
      x.each_with_index do |e, i|
        s = e.size
        max_lengths[i] = s if s > max_lengths[i]
      end
    end
    xs.each do |x|
      format = max_lengths.map {|y| "%#{y}s"}.join(" " * 5)
      puts format % x
    end
    puts "\n\n"
  end

  # Triples present?
  def triple_store_schema_list_query
    results = []
    results << ["Uri", "Label", "Version"]
    results << ["-------------", "--------", "-------"]
    query_string = %Q{
      SELECT DISTINCT ?s ?l ?v WHERE 
      {
        ?s rdf:type owl:Ontology .
        ?s rdfs:label ?l .
        ?s owl:versionInfo ?v
      } ORDER BY ?l
    }
    query_results = Sparql::Query.new.query(query_string, "", [:owl])
    query_results.by_object_set([:s, :l, :v]).each do |x|
      results << ["#{x[:s]}", "#{x[:l]}", "#{x[:v]}"]
    end
    triple_store_schema_list_results(results)
  end

  # Execute task
  def triple_store_schema_list_execute
    triple_store_schema_list_query
  rescue => e
    msg = "Triple store schema list error."
    abort("#{msg}\n\n#{e}\n\n#{e.backtrace}")
  end

  # Actual rake task
  task :schema_list => :environment do
    triple_store_schema_list_execute
  end

end