require 'rails_helper'

describe Sparql::Query do
	
  include DataHelpers
  include PublicFileHelpers
  
  def sub_dir
    return "models/concerns/sparql/query"
  end

  before :each do
    clear_triple_store
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
  end

  after :all do
    delete_all_public_test_files
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

  it "executes an query, error" do
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    item = Sparql::Query.new
    query = %Q{ SELECT ?a WHERE\n
      {\n
        ?a :ofOrganization ?b . \n
        ?b isoB:shortName "AAA"^^xsd:string . \n
      }\n
    }
    expect(ConsoleLogger).to receive(:info)
    expect{item.query(query, :isoI, [:isoB])}.to raise_error(Errors::ReadError, "Failed to query the database. SPARQL query failed.")
  end

end