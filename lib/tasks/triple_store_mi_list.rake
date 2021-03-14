namespace :triple_store do

  desc "Managed Item Listing"

  # MI list
  def triple_store_mi_list
    query_string = %Q{
      SELECT DISTINCT ?s ?t ?l ?sv ?v ?i WHERE 
      {
        ?s rdf:type ?t .
        ?s isoC:label ?l .
        ?s isoT:hasIdentifier/isoI:semanticVersion ?sv .
        ?s isoT:hasIdentifier/isoI:hasScope/isoI:shortName ?owner .
        ?s isoT:hasIdentifier/isoI:version ?v .
        ?s isoT:hasIdentifier/isoI:identifier ?i .
      } ORDER BY ?t ?i ?l ?v
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoT, :isoI, :isoC])
    query_results.by_object_set([:s, :t, :i, :l, :v, :sv])
  end

  # Actual rake task
  task :mi_list => :environment do

    include RakeDisplay
    include RakeFile

    headers = ["Uri", "Type", "Identifier", "Label", "Version", "Semantic Version"]
    items = triple_store_mi_list
    display_results("Managed Item List", items, headers, [40, 40, 0, 20, 0, 0])
    write_data_as_csv(items, headers, "mi_list")
  end

end