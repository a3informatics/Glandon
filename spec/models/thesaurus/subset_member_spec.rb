require 'rails_helper'

describe "Thesaurus::SubsetMember" do

	include DataHelpers
  include SparqlHelpers
  include PublicFileHelpers

    
	def sub_dir
    return "models/thesaurus/subset_member"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    # schema_files = 
    # [
    #   "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
    #   "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    # ]
    # data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_scoped_identifier.ttl"]
    # load_files(schema_files, data_files)

    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)
    load_local_file_into_triple_store(sub_dir, "subsets_input_1.ttl")
    load_local_file_into_triple_store(sub_dir, "subsets_input_2.ttl")
  end

  it "allows to find the previous node of one given" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm = Thesaurus::SubsetMember.find(uri_1)
    sm_prev = Thesaurus::SubsetMember.find(uri_2)
    result = sm.previous_member
    expect(result.to_h).to eq(sm_prev.to_h)
  end

  it "allows to find the previous node of one given, previous nil" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm = Thesaurus::SubsetMember.find(uri_1)
    result = sm.previous_member
    expect(result).to eq(nil)
  end

  it "allows to find the next node of one given" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    sm = Thesaurus::SubsetMember.find(uri_1)
    sm_next = Thesaurus::SubsetMember.find(uri_2)
    result = sm.next_member
    expect(result.to_h).to eq(sm_next.to_h)
  end

  it "allows to find the next node of one given, next nil" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    sm = Thesaurus::SubsetMember.find(uri_1)
    result = sm.next_member
    expect(result).to eq(nil)
  end
 
  it "validates a valid object" do
    result = Thesaurus::SubsetMember.new
    result.uri = Uri.new(uri: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = Thesaurus::SubsetMember.new
    result.label = "Draft 123 more tesxt €"
    expect(result.valid?).to eq(false)
  end

  it "allows the object to be initialized from hash" do
    result = 
      {
        :uri => "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", 
        :id => Uri.new(uri:  "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1").to_id,
        :item => nil,
        :member_next => nil,
        :label => "BC Property Reference",
        :rdf_type => "http://www.assero.co.uk/Thesaurus#SubsetMember",
        :tagged => []
      }
    item = Thesaurus::SubsetMember.from_h(result)
    expect(item.to_h).to eq(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = Sparql::Update.new
    item = Thesaurus::SubsetMember.new
    item.label = "label"
    item.uri = Uri.new({:fragment => "parent", :namespace => "http://www.example.com/path"})
    item.to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_create_sparql_expected.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_create_sparql_expected.txt")
  end

end