require 'rails_helper'

describe Sparql::Query do
	
  include DataHelpers
  
  def sub_dir
    return "models/concerns/sparql/query"
  end

  before :each do
    clear_triple_store
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
  end

  it "execute query, default namespace" do
    item = Sparql::Query.new
    query = %Q{ SELECT ?a WHERE\n
      {\n
        ?a isoI:ofOrganization ?b . \n
        ?b isoB:shortName "AAA"^^xsd:string . \n
      }\n
    }
    expected = [[{:name=>"a", :value=>"http://www.assero.co.uk/MDRItems#NS-AAA"}]]
    result = item.query(query, "http://www.assero.co.uk/MDRItems", [:isoI, :isoB])
    expect(result.to_hash).to eq(expected)  
  end

  it "execute query, default prefix" do
    item = Sparql::Query.new
    query = %Q{ SELECT ?a WHERE\n
      {\n
        ?a :ofOrganization ?b . \n
        ?b isoB:shortName "AAA"^^xsd:string . \n
      }\n
    }
    expected = [[{:name=>"a", :value=>"http://www.assero.co.uk/MDRItems#NS-AAA"}]]
    result = item.query(query, :isoI, [:isoB])
    expect(result.to_hash).to eq(expected)  
  end

end