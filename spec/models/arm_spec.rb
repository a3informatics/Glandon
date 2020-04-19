require 'rails_helper'

describe "Arm" do

  include DataHelpers

  def sub_dir
    return "models/arm"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "create an instance" do
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3301")
      item = Arm.create(label: "XXX", description:"D", arm_type:"type", ordinal: 1)
      actual = Arm.find(item.uri)
      expect(actual.label).to eq("XXX")
      expect(actual.description).to eq("D")
      expect(actual.arm_type).to eq("type")
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "method tests" do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
      load_data_file_into_triple_store("hackathon_thesaurus.ttl")
      load_data_file_into_triple_store("hackathon_tas.ttl")
      load_data_file_into_triple_store("hackathon_indications.ttl")
      load_data_file_into_triple_store("hackathon_endpoints.ttl")
      load_data_file_into_triple_store("hackathon_parameters.ttl")
      load_data_file_into_triple_store("hackathon_protocols.ttl")
      load_data_file_into_triple_store("hackathon_bc_instances.ttl")
      load_data_file_into_triple_store("hackathon_bc_templates.ttl")
      load_data_file_into_triple_store("hackathon_protocol_templates.ttl")
    end

    it "timepoints" do
      pr = Protocol.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      pr.specifies_arm_links
      item = Arm.find(pr.specifies_arm.first)
      actual = item.timepoints
      check_file_actual_expected(actual, sub_dir, "timepoints_expected.yaml", equate_method: :hash_equal)
    end

    it "add timepoint" do
      pr = Protocol.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      pr.specifies_arm_links
      pr.specifies_epoch_links
      item = Arm.find(pr.specifies_arm.first)
      tps = item.timepoints
      epoch = Epoch.find(pr.specifies_epoch.first)
      actual = item.add_timepoint({offset: "12", epoch_id: epoch.id})
      check_file_actual_expected(actual, sub_dir, "add_timepoint_expected_1.yaml", equate_method: :hash_equal)
      item = Arm.find(item.uri)
      actual = item.timepoints
      check_file_actual_expected(actual, sub_dir, "add_timepoint_expected_2.yaml", equate_method: :hash_equal)
      actual = item.add_timepoint({offset: "30", epoch_id: epoch.id})
      check_file_actual_expected(actual, sub_dir, "add_timepoint_expected_3.yaml", equate_method: :hash_equal)
      item = Arm.find(item.uri)
      actual = item.timepoints
      check_file_actual_expected(actual, sub_dir, "add_timepoint_expected_4.yaml", equate_method: :hash_equal)
    end

  end

end