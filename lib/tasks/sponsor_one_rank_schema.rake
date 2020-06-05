namespace :sponsor_one do

  desc "Update Rank Schema"

  # Should we migrate?
  def rank_schema_migrate?
    Sparql::Query.new.query("ASK {th:SubsetMember rdfs:label \"Subset\"}", "", [:th]).ask? 
  end

  # Execute migation
  def rank_schema_execute
    # Load thesaurus schema migration
    puts "Load new schema ..."
    step = 1
    full_path = Rails.root.join "db/load/schema/thesaurus_migration_20200519.ttl"
    sparql = Sparql::Upload.new.send(full_path)

    # Thesaurus schema fix triples. Will only happen if file load raised no errors
    puts "Load schema corrections ..."
    step = 2
    sparql = Sparql::Update.new
    sparql_update = %Q{
      DELETE 
      {
        th:Subset skos:definition ?o1 .
        th:SubsetMember rdfs:label ?o2 .
        th:SubsetMember skos:definition ?o3 .
      }      
      INSERT 
      {
        th:Subset skos:definition "The head of the list by which a code list is ordered."^^xsd:string .
        th:SubsetMember rdfs:label "Subset Member"^^xsd:string .
        th:SubsetMember skos:definition "Ordered list member."^^xsd:string .
      }
      WHERE 
      {
        th:Subset skos:definition ?o1 .
        th:SubsetMember rdfs:label ?o2 .
        th:SubsetMember skos:definition ?o3 .
      }      
    }
    sparql.sparql_update(sparql_update, "", [:th])
    puts "Schema migration succesful"

  rescue => e
    msg = "Schema migration error, step: #{step}"
    abort("#{msg}\n\n#{e.backtrace}")
  end

  # Actual rake task
  task :rank_schema => :environment do
    abort("Schema migration not required") unless rank_schema_migrate?
    rank_schema_execute
  end

end