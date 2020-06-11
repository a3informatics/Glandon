class TsAddRankSchema < ActiveRecord::Migration[4.2]

  def change

    # Load thesaurus schema extension
    puts "Load extension ..."
    step = 1
    full_path = Rails.root.join "db/load/schema/thesaurus_extension_one.ttl"
    sparql = Sparql::Upload.new.send(full_path)

    # Thesaurus schema fix triples. Will only happen if file load raised no errors
    puts "Load fixes ..."
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
    puts "Migration succesful"

  rescue => e
    msg = "Migration error, step: #{step}"
    puts msg
    raise Errors::UpdateError.new("#{msg}\n\n#{e}")
  end

end
