namespace :r3_1_0 do

  desc "R3.1.0 Schema Update"

  # Check for success?
  def r3_1_0_schema_success?(base)
    su = Sparql::Utility.new
    sparql_ask = %Q{
      th:pairedWith rdfs:label "Paired with relationship"^^xsd:string .
      bc:ComplexDatatype rdfs:label "Biomedical Concept Complex Datatype"^^xsd:string .
    }
    su.ask?(sparql_ask, [:th, :bc]) && su.triple_count == (base + 126 - 6)
  end

  # Should we migrate?
  def r3_1_0_schema_migrate?
    # New schema should not be present, th triple to be removed present and the old BC triple should not have been loaded
    new_triple = Sparql::Utility.new.ask?("bc:ComplexDatatype rdfs:label \"Biomedical Concept Complex Datatype\"^^xsd:string", [:bc])
    old_triple = Sparql::Utility.new.ask?("th:narrowerReference ?p ?o", [:th])
    never_triple = Sparql::Utility.new.ask?("?s ?p ?o . FILTER( strStarts(STR(?s), \"http://www.assero.co.uk/CDISCBiomedicalConcept\"))", [])
    !new_triple && old_triple && !never_triple
  end

  # Execute migation
  def r3_1_0_schema_execute
    # Base triple count
    step = 0
    base = Sparql::Utility.new.triple_count

    # Load thesaurus schema migration and new BC schema
    puts "Load Thesaurus schema updates ..."
    step = 1
    full_path = Rails.root.join "db/load/schema/thesaurus_migration_20200705.ttl"
    sparql = Sparql::Upload.new.send(full_path)
    puts "Load new BC schema ..."
    step = 2
    full_path = Rails.root.join "db/load/schema/biomedical_concept.ttl"
    sparql = Sparql::Upload.new.send(full_path)

    # Remove old BC schema. Will only happen if file loads raised no errors
    puts "Make Thesaurus schema corrections ..."
    step = 3
    sparql = Sparql::Update.new
    sparql_update = %Q{
      DELETE 
      {
        th:narrowerReference ?p ?o
      }      
      WHERE 
      {
        th:narrowerReference ?p ?o
      }      
    }
    sparql.sparql_update(sparql_update, "", [:th])

    # Checks and finish
    abort("Schema migration not succesful, checks failed") unless r3_1_0_schema_success?(base)
    puts "Schema migration succesful"

  rescue => e
    msg = "Schema migration error, step: #{step}"
    abort("#{msg}\n\n#{e}\n\n#{e.backtrace}")
  end

  # Actual rake task
  task :schema => :environment do
    abort("Schema migration not required") unless r3_1_0_schema_migrate?
    r3_1_0_schema_execute
  end

end