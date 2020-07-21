namespace :v3_2_0 do

  desc "V3.2.0 Schema Update"

  C_CHECK_TRIPLES = [ 
    "<http://www.assero.co.uk/ISO11179Types> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string",
    "<http://www.assero.co.uk/BusinessForm> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string",
    "<http://www.assero.co.uk/ISO11179Concepts> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string",
    "<http://www.assero.co.uk/ISO11179Registration> owl:versionInfo \"Created with TopBraid Composer\"^^xsd:string",
  ]

  # Triples present?
  def v3_2_0_triples_present?
    C_CHECK_TRIPLES.each do |triple|
      return false unless Sparql::Utility.new.ask?(triple, [:fr, :cdt])
    end
    true
  end

  # Check for success?
  def v3_2_0_schema_success?(base)
    v3_2_0_triples_present? && Sparql::Utility.new.triple_count == (base + 62)
  end

  # Should we migrate?
  def v3_2_0_schema_migrate?
    !v3_2_0_triples_present?
  end

  # Execute migation
  def v3_2_0_schema_execute
    # Base triple count
    step = 0
    base = Sparql::Utility.new.triple_count

    puts "Load schema updates ..."
    ["complex_datatype.ttl", "framework.ttl"].each do |filename|
      step += 1
      sparql = Sparql::Upload.new.send(Rails.root.join("db/load/schema/#{filename}"))
    end

    # Checks and finish
    abort("Schema migration not succesful, checks failed") unless v3_2_0schema_success?(base)
    puts "Schema migration succesful"

  rescue => e
    msg = "Schema migration error, step: #{step}"
    abort("#{msg}\n\n#{e}\n\n#{e.backtrace}")
  end

  # Actual rake task
  task :schema => :environment do
    abort("Schema migration not required") unless v3_2_0schema_migrate?
    v3_2_0_schema_execute
  end

end