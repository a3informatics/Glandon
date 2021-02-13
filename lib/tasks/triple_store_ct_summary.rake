namespace :triple_store do

  desc "Triple Store CT Summary"

  # Identify Code Lists
  def identify_code_lists(short_name)
    query_string = %Q{
      SELECT DISTINCT ?s ?l ?v ?i ?n ?sv (COUNT(?x) as ?c) WHERE 
      {
        ?s rdf:type #{Thesaurus::ManagedConcept.rdf_type.to_ref} .
        ?s isoT:hasState ?st .
        ?s isoT:hasIdentifier ?si .
        ?si isoI:hasScope/isoI:shortName "#{short_name}" .
        ?s isoC:label ?l .
        ?si isoI:version ?v .
        ?si isoI:identifier ?i .
        ?si isoI:semanticVersion ?sv .
        ?s th:notation ?n .
        ?s th:narrower ?x
      } GROUP BY ?s ?l ?v ?i ?sv ?n ORDER BY ?i ?v ?l 
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    items = query_results.by_object_set([:s, :l, :v, :i, :n, :sv, :c])
    display_results("Code List Summary", items, ["Uri", "Label", "Ver", "Identifier", "Submission", "Semantic Ver", "Items"], [0, 100, 0, 0, 0, 0, 0])
    items
  end

  # Inspect Coe List
  def inspect_code_list(uri, identifier, notation, version)
    query_string = %Q{
      SELECT DISTINCT ?cli ?l ?i ?n WHERE 
      {
        #{uri.to_ref} th:narrower ?cli .
        ?cli th:identifier ?i .
        ?cli isoC:label ?l .
        ?cli th:notation ?n .
      } ORDER BY ?i
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    items = query_results.by_object_set([:cli, :l, :i, :n])
    display_results("Code List #{identifier}, #{notation}, V#{version}", items, ["Uri", "Label", "Identifier", "Submission"])
    items
  end

  # Actual rake task
  task :ct_summary => :environment do
    
    include RakeDisplay
    include RakeFile

    ARGV.each { |a| task a.to_sym do ; end }
    abort("A short name$ should be supplied") if ARGV.count == 1
    abort("Only a single parameter (a short name) should be supplied") unless ARGV.count == 2
    results = Hash.new { |h,k| h[k] = [] }
    errors = []
    cls = identify_code_lists(ARGV[1])
    cls.each do |cl|
      version = { uri: cl[:s].to_s, label: cl[:l], version: cl[:v], identifier: cl[:i], submission: cl[:n], semantic_version: cl[:sv] }
      items = inspect_code_list(cl[:s], cl[:i], cl[:n], cl[:v])
      version[:items] = items.map { |x| { uri: x[:cli].to_s, label: x[:l], identifier: x[:i], submission: x[:n]} }
      results[cl[:i]] << version
      errors << { error: "item count mismatch for #{cl[:i]}", version: "#{cl[:v]}", cl: "#{cl[:c]}", query: "#{version[:items].count}", difference: "#{cl[:c].to_i - version[:items].count}" } unless cl[:c].to_i == version[:items].count
    end
    write_data_as_yaml(results, "code_list_summary")
    display_results("Errors", errors, ["Error", "Version", "Cl Count", "Query Count", "Difference"])
  end

end