require 'rails_helper'

describe "Thesaurus::Subset" do

	include DataHelpers
  include SparqlHelpers
  include PublicFileHelpers
    
	def sub_dir
    return "models/thesaurus/subset"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)
    load_local_file_into_triple_store(sub_dir, "subsets_input_1.ttl")
    load_local_file_into_triple_store(sub_dir, "subsets_input_2.ttl")
  end
 
  after :all do
    delete_all_public_test_files
  end

  # it "creates some test data" do
  #   base_uri = Uri.new(uri: "http://www.example.com/a#b")
  #   tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C25301"))
  #   subset = Thesaurus::Subset.new
  #   subset.uri = subset.create_uri(base_uri)
  #   sm_1 = Thesaurus::SubsetMember.new
  #   sm_1.item = tc
  #   sm_1.uri = sm_1.create_uri(base_uri)
  #   sm_2 = Thesaurus::SubsetMember.new
  #   sm_2.item = tc
  #   sm_2.uri = sm_2.create_uri(base_uri)
  #   sm_3 = Thesaurus::SubsetMember.new
  #   sm_3.item = tc
  #   sm_3.uri = sm_3.create_uri(base_uri)
  #   sm_1.member_next = sm_2
  #   sm_2.member_next = sm_3
  #   subset.members = sm_1

  #   sparql = Sparql::Update.new
  #   sparql.default_namespace(subset.uri.namespace)
  #   subset.to_sparql(sparql)
  #   sm_1.to_sparql(sparql)
  #   sm_2.to_sparql(sparql)
  #   sm_3.to_sparql(sparql)
  #   file = sparql.to_file
  #   copy_file_from_public_files_rename("test", file.basename, sub_dir, "subsets_input_1.ttl")
  #end

  it "allows the last member to be found" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/TS#f5d17523-104f-412c-a652-b98ae6666666")
    expected = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    subset = Thesaurus::Subset.find(uri_1)
    result = subset.last
    expect(result.uri).to eq(expected)
    subset = Thesaurus::Subset.find(uri_2)
    result = subset.last
    expect(result).to be_nil
  end

  it "allows add a new item to the list" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#f5d17523-104f-412c-a652-b98ae6666666")
    subset = Thesaurus::Subset.find(uri_1)
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    result = subset.add(uri_2.to_id)
    expect(subset.last.to_h).to eq(result.to_h)
    uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    result = subset.add(uri_3.to_id)
    expect(subset.last.to_h).to eq(result.to_h)
  end

  it "allows add a new item to the list" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    subset = Thesaurus::Subset.find(uri_1)
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    result = subset.add(uri_2.to_id)
    expect(subset.last.to_h).to eq(result.to_h)
    uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    result = subset.add(uri_3.to_id)
    expect(subset.last.to_h).to eq(result.to_h)  
  end

  it "allow remove an item from the list" do
    subset_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    subset = Thesaurus::Subset.find(subset_uri_1)
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    uri_4 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm_2 = Thesaurus::SubsetMember.find(uri_2)
    sm_3 = Thesaurus::SubsetMember.find(uri_3)
    sm_4 = Thesaurus::SubsetMember.find(uri_4)
  byebug
    result = subset.remove(sm_2.uri.to_id)
    expect(sm_4.next_member.to_h).to eq(sm_3.to_h)
  end

  it "allow remove an item from the list, first subset member" do
    subset_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    subset = Thesaurus::Subset.find(subset_uri_1)
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    sm_2 = Thesaurus::SubsetMember.find(uri_2)
    sm_3 = Thesaurus::SubsetMember.find(uri_3)
  byebug
    result = subset.remove(sm_2.uri.to_id)
    expect(subset.members).to eq(sm_3.uri)
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
        :id => Uri.new(uri:  "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1").to_id,
        :label => "First member", 
        :members => "http://www.assero.co.uk/X/V1#M1",
        :rdf_type => "http://www.assero.co.uk/Thesaurus#Subset",
        :tagged => []
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