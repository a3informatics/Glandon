namespace :sponsor_one do

  desc "Update 3.1.0 Schema"

  # Check for success?
  def r3_1_0_schema_success?(base)
    su = Sparql::Utility.new
    sparql_ask = %Q{
      th:pairedWith rdfs:label "Paired with relationship"^^xsd:string .
      bc:ComplexDatatype rdfs:label "Biomedical Concept Complex Datatype"^^xsd:string .
    }
  puts "COUNT=#{su.triple_count}"
    su.ask?(sparql_ask, [:th, :bc]) && su.triple_count == (base - 9)
  end

  # Should we migrate?
  def r3_1_0_schema_migrate?
    Sparql::Query.new.query("ASK {<http://www.assero.co.uk/CDISCBiomedicalConcept#Node> rdfs:label \"Generic node\"^^xsd:string ;}", "", [:th]).ask? 
  end

  # Execute migation
  def r3_1_0_schema_execute
    # Base triple count
    step = 0
    base = Sparql::Utility.new.triple_count

    # Load thesaurus schema migration and new BC schema
    puts "Load new Thesaurus schema ..."
    step = 1
    full_path = Rails.root.join "db/load/schema/thesaurus_migration_20200705.ttl"
    sparql = Sparql::Upload.new.send(full_path)
    puts "Load new BC schema ..."
    step = 2
    full_path = Rails.root.join "db/load/schema/biomedical_concept.ttl"
    sparql = Sparql::Upload.new.send(full_path)

    # Remove old BC schema. Will only happen if file loads raised no errors
    puts "Load schema corrections ..."
    step = 3
    sparql = Sparql::Update.new
    clauses = []
    [
      :Node, :Datatype, :Item, 
      :Property, :PropertyValue, :BiomedicalConcept, 
      :BiomedicalConceptInstance, :BiomedicalConceptTemplate, :alias, 
      :ordinal, :basedOnTemplate, :hasThesaurusConcept, 
      :hasComplexDatatype, :hasDatatype, :hasItem, 
      :hasProperty, :hasValue, :bridg_class, 
      :bridg_attribute, :iso21090_datatype, :question_text, 
      :prompt_text, :format, :enabled, 
      :collect, :simple_datatype, :bridg_path
    ].each_with_index do |subject, index|
      ordinal = index + 2
      clauses << "{ <http://www.assero.co.uk/CDISCBiomedicalConcept##{subject}> ?p ?o . BIND (<http://www.assero.co.uk/CDISCBiomedicalConcept##{subject}> as ?s )}"
    end
    sparql_update = %Q{
      DELETE 
      {
        ?s ?p ?o
      }      
      WHERE 
      {
        { <http://www.assero.co.uk/CDISCBiomedicalConcept> ?p ?o . BIND (<http://www.assero.co.uk/CDISCBiomedicalConcept> as ?s) } UNION
        #{clauses.join(" UNION \n")}
      }      
    }
    sparql.sparql_update(sparql_update, "", [])

    # Checks and finish
    abort("Schema migration not succesful, checks failed") unless r3_1_0_schema_success?(base)
    puts "Schema migration succesful"

  rescue => e
    msg = "Schema migration error, step: #{step}"
    abort("#{msg}\n\n#{e}\n\n#{e.backtrace}")
  end

  # Actual rake task
  task :r3_1_0_schema => :environment do
    abort("Schema migration not required") unless r3_1_0_schema_migrate?
    r3_1_0_schema_execute
  end

end