require 'rails_helper'

describe "Dashboard" do

	include DataHelpers
  include PauseHelpers

	def sub_dir
    return "models"
  end

  before :all do
    data_files = [ "form_example_vs_baseline.ttl" ]
    load_files(schema_files, data_files)
  end

  it "finds all triples" do
    results = Dashboard.find("F-ACME_VSBASELINE1_G1_G2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expected = read_yaml_file(sub_dir, "dashboard_example1.yaml")
    results.each do |result|
      found = expected.find { |x| x.subject == result.subject && x.predicate == result.predicate && x.object == result.object }
      expect(result.to_json).to eq(found.to_json) 
    end
  end

end
