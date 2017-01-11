require 'rails_helper'

describe User do

	include DataHelpers
  include PauseHelpers

	def sub_dir
    return "models"
  end

  before :all do
    clear_triple_store
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
  end

  it "finds all triples" do
    triples = Dashboard.find("F-ACME_VSBASELINE1_G1_G2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    results = read_yaml_file(sub_dir, "dashboard_example1.yaml")
    expect(triples.to_json).to eq(results.to_json)
  end

end
