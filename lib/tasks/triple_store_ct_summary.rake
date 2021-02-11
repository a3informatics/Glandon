namespace :triple_store do

  desc "Triple Store CT Summary"

  # Identify Code Lists
  def identify_code_lists(short_name)
    query_string = %Q{
      SELECT DISTINCT ?s ?l ?v ?i ?sv (COUNT(?x) as ?c) WHERE 
      {
        ?s rdf:type #{Thesaurus::ManagedConcept.rdf_type.to_ref} .
        ?s isoT:hasState ?st .
        ?s isoT:hasIdentifier ?si .
        ?si isoI:hasScope/isoI:shortName "#{short_name}" .
        ?s isoC:label ?l .
        ?si isoI:version ?v .
        ?si isoI:identifier ?i .
        ?si isoI:semanticVersion ?sv .
        ?s th:narrower ?x
      } GROUP BY ?s ?l ?v ?i ?sv ORDER BY ?l ?v 
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    items = query_results.by_object_set([:s, :l, :v, :i, :sv, :c])
    display_results("Code List Summary", items, ["Uri", "Label", "Ver", "Identifier", "Semantic Ver", "Items"], [0, 100, 0, 0, 0, 0])
    items
  end

  # Actual rake task
  task :ct_summary => :environment do
    
    include RakeDisplay

    ARGV.each { |a| task a.to_sym do ; end }
    abort("A short name$ should be supplied") if ARGV.count == 1
    abort("Only a single parameter (a short name) should be supplied") unless ARGV.count == 2
    actions = identify_code_lists(ARGV[1])
  end

end