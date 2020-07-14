namespace :r3_1_1 do

  desc "R3.1.1 Schema Update"

  
  C_CHECK_TRIPLES = [ "fr:definition rdfs:label \"Definition\"^^xsd:string",
                      "cdt:hasProperty rdfs:label \"Property\"^^xsd:string" ]

  # Triples present?
  def r3_1_1_triples_present?
    present = true
    C_CHECK_TRIPLES.each do |triple|
      return false unless Sparql::Utility.new.ask?(triple, [:fr, :cdt])
    end
    true
  end

  # Check for success?
  def r3_1_1_schema_success?(base)
    r3_1_1_triples_present? && Sparql::Utility.new.triple_count == (base + 62)
  end

  # Should we migrate?
  def r3_1_1_schema_migrate?
    !r3_1_1_triples_present?
  end

  # Execute migation
  def r3_1_1_schema_execute
    # Base triple count
    step = 0
    base = Sparql::Utility.new.triple_count

    puts "Load schema updates ..."
    ["complex_datatype.ttl", "framework.ttl"].each do |filename|
      step += 1
      sparql = Sparql::Upload.new.send(Rails.root.join("db/load/schema/#{filename}"))
    end

    # Checks and finish
    abort("Schema migration not succesful, checks failed") unless r3_1_1_schema_success?(base)
    puts "Schema migration succesful"

  rescue => e
    msg = "Schema migration error, step: #{step}"
    abort("#{msg}\n\n#{e}\n\n#{e.backtrace}")
  end

  # Actual rake task
  task :schema => :environment do
    abort("Schema migration not required") unless r3_1_1_schema_migrate?
    r3_1_1_schema_execute
  end

end