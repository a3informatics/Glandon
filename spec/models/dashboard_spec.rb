require 'rails_helper'

describe User do

	include DataHelpers
  include PauseHelpers

	before :all do
    clear_triple_store
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
  end

  it "finds all triples" do
    triples = Dashboard.find("F-ACME_VSBASELINE1_G1_G2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    results = read_yaml_file_to_hash("dashboard_example1.yaml")
    expect(triples.to_json).to eq(results.to_json)
  end

end
