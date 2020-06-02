class AddRankExtensions < ActiveRecord::Migration

  def change

    # Load rank extensions
    puts "Load extensions ..."
    step = 1
    full_path = Rails.root.join "db/load/data/sponsor_one/ct/rank_extensions_V2-6.ttl"
    sparql = Sparql::Upload.new.send(full_path)

    # Thesaurus extensions fix triples. Will only happen if file load raised no errors
    puts "Load fixes ..."
    step = 2
    sparql = Sparql::Update.new
    sparql_update = %Q{
      DELETE
      {
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66784/V34#C66784> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C87162/V33#C87162> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66768/V28#C66768> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66769/V17#C66769> .
        ?s1 bo:reference <http://www.cdisc.org/C66784/V34#C66784> .
        ?s2 bo:reference <http://www.cdisc.org/C87162/V33#C87162> .
        ?s3 bo:reference <http://www.cdisc.org/C66768/V28#C66768> .
        ?s4 bo:reference <http://www.cdisc.org/C66769/V17#C66769> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66768/V28#C66768> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66769/V17#C66769> .
        ?s5 bo:reference <http://www.cdisc.org/C66768/V28#C66768> .
        ?s6 bo:reference <http://www.cdisc.org/C66769/V17#C66769> 
      }      
      INSERT 
      {
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66784/V1#C66784> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C87162/V1#C87162> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66768/V1#C66768> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66769/V1#C66769> .
        ?s1 bo:reference <http://www.sanofi.com/C66784/V1#C66784> .
        ?s2 bo:reference <http://www.sanofi.com/C87162/V1#C87162> .
        ?s3 bo:reference <http://www.sanofi.com/C66768/V1#C66768> .
        ?s4 bo:reference <http://www.sanofi.com/C66769/V1#C66769> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66768/V1#C66768> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66769/V1#C66769> .
        ?s5 bo:reference <http://www.sanofi.com/C66768/V1#C66768> .
        ?s6 bo:reference <http://www.sanofi.com/C66769/V1#C66769> 
      }
      WHERE 
      {
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s1 .
        ?s1 bo:reference <http://www.cdisc.org/C66784/V34#C66784> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s2 .
        ?s2 bo:reference <http://www.cdisc.org/C87162/V33#C87162> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s3 .
        ?s3 bo:reference <http://www.cdisc.org/C66768/V28#C66768> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s4 .
        ?s4 bo:reference <http://www.cdisc.org/C66769/V17#C66769> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConceptReference ?s5 .
        ?s5 bo:reference <http://www.cdisc.org/C66768/V28#C66768> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConceptReference ?s6 .
        ?s6 bo:reference <http://www.cdisc.org/C66769/V17#C66769>
      }         
    }
    sparql.sparql_update(sparql_update, "", [:th, :bo])
    puts "Migration succesful"

  rescue => e
    msg = "Migration error, step: #{step}"
    puts msg
    raise Errors::UpdateError.new("#{msg}\n\n#{e}")
  end

end