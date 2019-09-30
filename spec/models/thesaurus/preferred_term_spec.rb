require 'rails_helper'

describe "Thesaurus::PreferredTerm" do

	include DataHelpers
  include SparqlHelpers
    
	def sub_dir
    return "models/thesaurus/preferred_term"
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
    result = Thesaurus::PreferredTerm.new
    result.uri = Uri.new(uri: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = Thesaurus::PreferredTerm.new
    result.label = "Draft 123 more tesxt €"
    expect(result.valid?).to eq(false)
  end

  it "allows the object to be initialized from hash" do
    result = 
      {
        :uri => "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", 
        :label => "BC Property Reference",
        :rdf_type => "http://www.assero.co.uk/Thesaurus#PreferredTerm",
        :uuid => "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvWC9WMSNGLUFDTUVfT1JfRzFfSTE="
      }
    item = Thesaurus::PreferredTerm.from_h(result)
    check_file_actual_expected(item.to_h, sub_dir, "from_h_expected.yaml", equate_method: :hash_equal)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = Sparql::Update.new
    item = Thesaurus::PreferredTerm.new
    item.label = "label"
    item.uri = Uri.new({:fragment => "parent", :namespace => "http://www.example.com/path"})
    item.to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_create_sparql_expected.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_create_sparql_expected.txt")
  end

  it "finds or creates a synonym" do
    item_1 = Thesaurus::PreferredTerm.where_only_or_create("NEW")
    item_2 = Thesaurus::PreferredTerm.where_only_or_create("NEW")
    expect(item_1.label).to eq("NEW")
    expect(item_1.uri.to_s).to eq(item_2.uri.to_s)
  end   
  
end