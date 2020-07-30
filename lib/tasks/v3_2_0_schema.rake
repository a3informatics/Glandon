namespace :v3_2_0 do

  desc "V3.2.0 Schema Update"

  C_V320_CHECK_TRIPLES = [ 
    "<http://www.assero.co.uk/ISO11179Types> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string",
    "<http://www.assero.co.uk/ISO11179Concepts> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string",
    "<http://www.assero.co.uk/ISO11179Registration> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string",
    "<http://www.assero.co.uk/BusinessForm> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string",
    "<http://www.assero.co.uk/BiomedicalConcept#BiomedicalConcept> rdfs:subClassOf <http://www.assero.co.uk/ISO11179Concepts#Concept>"
  ]

  # Triples present?
  def v3_2_0_old_triples_present?
    result = true
    C_V320_CHECK_TRIPLES.each do |triple|
      present = Sparql::Utility.new.ask?(triple, [:owl])
      puts "Checking triples #{triple} present ... #{present}"
      result = result && present
    end
    result
  end

  # Triples deleted?
  def v3_2_0_old_triples_deleted?
    result = true
    C_V320_CHECK_TRIPLES.each do |triple|
      present = Sparql::Utility.new.ask?(triple, [:owl])
      puts "Checking triples #{triple} present ... #{present}"
      result = result && !present
    end
    result
  end

  # Check for success?
  def v3_2_0_schema_success?(base)
    triples_deleted = v3_2_0_old_triples_deleted?
    expected = base + 22 - 4
    actual = Sparql::Utility.new.triple_count
    count_correct = actual == expected
    return true if triples_deleted && count_correct
    puts "Old triples still present ..." unless triples_deleted
    puts "Expected count not correct [actual=#{actual}, expected=#{expected}] ..." unless count_correct
    false
  end

  # Should we migrate?
  def v3_2_0_schema_migrate?
    v3_2_0_old_triples_present?
  end

  # Execute migation
  def v3_2_0_schema_execute
    # Base triple count
    step = 0
    base = Sparql::Utility.new.triple_count

    # Remove old BC schema. Will only happen if file loads raised no errors
    puts "Remove old owl:versionInfo schema annotations ..."
    step = 1
    sparql = Sparql::Update.new
    sparql_update = %Q{
      DELETE DATA
      {
        <http://www.assero.co.uk/ISO11179Types> owl:versionInfo "Created with TopBraid Composer"^^xsd:string .
        <http://www.assero.co.uk/ISO11179Concepts> owl:versionInfo "Created with TopBraid Composer"^^xsd:string .
        <http://www.assero.co.uk/ISO11179Registration> owl:versionInfo "Created with TopBraid Composer"^^xsd:string .
        <http://www.assero.co.uk/BusinessForm> owl:versionInfo "Created with TopBraid Composer"^^xsd:string .
        <http://www.s-cubed.dk/ComplexDatatypes#> rdf:type owl:Ontology .
        <http://www.assero.co.uk/BiomedicalConcept#BiomedicalConcept> rdfs:subClassOf <http://www.assero.co.uk/ISO11179Concepts#Concept> ;
      }      
    }
    sparql.sparql_update(sparql_update, "", [:owl])

    puts "Load schema migrations ..."
    [
      "annotations_migration_20200720.ttl",
      "biomedical_concept_migration_20200720.ttl",
      "business_form_migration_20200720.ttl",
      "business_operational_migration_20200720.ttl",
      "complex_datatype_migration_20200720.ttl",
      "framework_migration_20200720.ttl",
      "iso11179_concepts_migration_20200720.ttl",
      "iso11179_identification_migration_20200720.ttl",
      "iso11179_registration_migration_20200720.ttl",
      "iso11179_types_migration_20200720.ttl",
      "thesaurus_migration_20200720.ttl"
    ].each do |filename|
      step += 1
      puts "Loading #{filename} ..."
      sparql = Sparql::Upload.new.send(Rails.root.join("db/load/schema/#{filename}"))
    end

    # Checks and finish
    abort("Schema migration not succesful, checks failed") unless v3_2_0_schema_success?(base)
    puts "Schema migration succesful"

  rescue => e
    msg = "Schema migration error, step: #{step}"
    abort("#{msg}\n\n#{e}\n\n#{e.backtrace}")
  end

  # Actual rake task
  task :schema => :environment do
    abort("Schema migration not required") unless v3_2_0_schema_migrate?
    v3_2_0_schema_execute
  end

end