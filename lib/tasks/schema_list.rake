namespace :schema do

  desc "Schema Listing"

  # Triples present?
  def schema_list_query
    query_string = %Q{
      SELECT DISTINCT ?s ?l ?v WHERE 
      {
        ?s rdf:type owl:Ontology .
        ?s rdfs:label ?l
        ?s owl:versionInfo ?v
      }      
    }
    query_results = Sparql::Query.new.query(query_string, "", [:owl])
    query_results.by_object_set([:s, :l, :v]).each do |x|
      puts("Uri: #{x[:s]}, label: #{x[:l]}, version: #{x[:v]}")
    end
  end

  # Execute task
  def schema_list_execute
    schema_list_query
  rescue => e
    msg = "Schema list error."
    abort("#{msg}\n\n#{e}\n\n#{e.backtrace}")
  end

  # Actual rake task
  task :list => :environment do
    schema_list_execute
  end

end