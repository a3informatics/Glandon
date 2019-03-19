require 'rails_helper'

describe IsoManaged do

	include DataHelpers
  include SparqlHelpers
  
  def sub_dir
    return "models"
  end
    
	before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("iso_managed_parent.ttl")
    load_test_file_into_triple_store("iso_managed_branch.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

	it "allows the branch parent (another managed item) to be set" do
    parent = IsoManaged.find("F-ACME_BRANCHPARENT", "http://www.assero.co.uk/MDRForms/ACME/V1")
    branch = IsoManaged.find("F-ACME_BRANCH", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(branch.is_a_branch?).to eq(false)
    branch.add_branch_parent(parent.id, parent.namespace)
    branch = IsoManaged.find("F-ACME_BRANCH", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(branch.is_a_branch?).to eq(true)
  end

  it "allows the branch parent (another managed item) to be set, error" do
    parent = IsoManaged.find("F-ACME_BRANCHPARENT", "http://www.assero.co.uk/MDRForms/ACME/V1")
    branch = IsoManaged.find("F-ACME_BRANCH", "http://www.assero.co.uk/MDRForms/ACME/V1")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{branch.add_branch_parent(parent.id, parent.namespace)}.to raise_error(Exceptions::UpdateError)
  end

  it "allows branched status to be determined" do
    branch = IsoManaged.find("F-ACME_BRANCH", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(branch.is_a_branch?).to eq(true)
    parent = IsoManaged.find("F-ACME_BRANCHPARENT", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(parent.is_a_branch?).to eq(false)
  end

  it "allows the item to be exported as sparql including the branch parent" do
    branch = IsoManaged.find("F-ACME_BRANCH", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #write_yaml_file(branch.triples, sub_dir, "iso_managed_branch_triples.yaml")
    sparql = SparqlUpdateV2.new
    result_uri = branch.to_sparql_v2(sparql, "bf")
  #Xwrite_text_file_2(sparql.to_s, sub_dir, "iso_managed_branch_sparql_1.txt")
    expected = read_text_file_2(sub_dir, "iso_managed_branch_sparql_1.txt")
    check_sparql_no_file(sparql.to_s, "iso_managed_branch_sparql_1.txt")
    expect(result_uri.to_s).to eq("http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_BRANCH")
  end

  it "allows the managed item to be set from triples including the branch parent" do
    triples = read_yaml_file(sub_dir, "iso_managed_branch_triples.yaml")
    item = IsoManaged.new(triples, "F-ACME_BRANCH")
    expect(item.is_a_branch?).to eq(true)
  #Xwrite_yaml_file(item.to_json, sub_dir, "iso_managed_branch_from_triples.yaml")
    expected = read_yaml_file(sub_dir, "iso_managed_branch_from_triples.yaml") # Note the branch info is not included in the JSON export.
    expect(item.to_json).to eq(expected)
  end

  it "allows the items branched from the item to be found" do
    items = IsoManaged.branches("F-ACME_BRANCHPARENT", "http://www.assero.co.uk/MDRForms/ACME/V1")
    results = []
    items.each { |x| results << x.to_json}
  #Xwrite_yaml_file(results, sub_dir, "iso_managed_branch_parents_1.yaml")
    expected = read_yaml_file(sub_dir, "iso_managed_branch_parents_1.yaml")
    expect(results).to eq(expected)
    items = IsoManaged.branches("F-ACME_BRANCH", "http://www.assero.co.uk/MDRForms/ACME/V1")
    results = []
    items.each { |x| results << x.to_json}
  #Xwrite_yaml_file(results, sub_dir, "iso_managed_branch_parents_2.yaml")
    expected = read_yaml_file(sub_dir, "iso_managed_branch_parents_2.yaml")
    expect(results).to eq(expected)    
  end

  it "determines if an item can be branched" do
    branch = IsoManaged.find("F-ACME_BRANCH", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(branch.can_be_branched?).to eq(false)
    branch.registrationState.registrationStatus = "Superseded"
    expect(branch.can_be_branched?).to eq(true)
    branch.registrationState.registrationStatus = "Retired"
    expect(branch.can_be_branched?).to eq(true)
    branch.registrationState.registrationStatus = "Standard"
    expect(branch.can_be_branched?).to eq(true)
    branch.registrationState.registrationStatus = "Incomplete"
    expect(branch.can_be_branched?).to eq(false)
    branch.registrationState.registrationStatus = "Candidate"
    expect(branch.can_be_branched?).to eq(false)
    branch.registrationState.registrationStatus = "Recorded"
    expect(branch.can_be_branched?).to eq(false)
    branch.registrationState.registrationStatus = "Qualified"
    expect(branch.can_be_branched?).to eq(false)
  end
end