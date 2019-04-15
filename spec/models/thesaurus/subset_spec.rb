require 'rails_helper'

describe Thesaurus::Subset do

	include DataHelpers
  include SparqlHelpers
    
	def sub_dir
    return "models/thesaurus/subset"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_scoped_identifier.ttl"]
    load_files(schema_files, data_files)
  end
 
  it "validates a valid object" do
    result = Thesaurus::Subset.new
    result.uri = Uri.new(uri: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = Thesaurus::Subset.new
    result.label = "Draft 123 more tesxt €"
    expect(result.valid?).to eq(false)
  end

  it "allows the object to be initialized from hash" do
    result = 
      {
        :uri => "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1",
        :label => "First member", 
        :members => "http://www.assero.co.uk/X/V1#M1",
        :rdf_type => "http://www.assero.co.uk/Thesaurus#Subset"
      }
    item = Thesaurus::Subset.from_h(result)
    expect(item.to_h).to eq(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = Sparql::Update.new
    item = Thesaurus::Subset.new
    item.label = "TEST"
    item.members = Uri.new({:fragment => "member", :namespace => "http://www.example.com/path"})
    item.uri = Uri.new({:fragment => "parent", :namespace => "http://www.example.com/path"})
    item.to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_create_sparql_expected.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_create_sparql_expected.txt")
  end

end