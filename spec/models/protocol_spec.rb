require 'rails_helper'

describe "Protocol" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/protocol"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "create an instance" do
      actual = Protocol.create(identifier: "XXX", title: "sss", short_title: "yyy", acronym: "WW")
      expect(actual.scoped_identifier).to eq("XXX")
      expect(actual.version).to eq(1)
      expect(actual.semantic_version).to eq("0.1.0")
      expect(actual.study_phase).to eq(nil)
      expect(actual.study_type).to eq(nil)
      expect(actual.masking).to eq(nil)
      expect(actual.intervention_model).to eq(nil)
      actual = Protocol.find_minimum(actual.uri)
      expect(actual.scoped_identifier).to eq("XXX")
      expect(actual.version).to eq(1)
      expect(actual.semantic_version).to eq("0.1.0")
      expect(actual.study_phase).to eq(nil)
      expect(actual.study_type).to eq(nil)
      expect(actual.masking).to eq(nil)
      expect(actual.intervention_model).to eq(nil)
      check_dates(actual, sub_dir, "create_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

    it "simple update" do
      actual = Protocol.create(identifier: "XXX", title: "sss")
      actual = Protocol.find_minimum(actual.uri)
      actual.label = "New label"
      actual.save
      actual = Protocol.find_minimum(actual.uri)
      check_dates(actual, sub_dir, "update_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
      actual.label = "Really new label"
      actual.save
      expect(actual.label).to eq("Really new label")
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
      load_data_file_into_triple_store("hackathon_objectives.ttl")
    end

    it "design" do
      item = Protocol.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      actual = item.design
      check_file_actual_expected(actual, sub_dir, "design_expected.yaml", equate_method: :hash_equal)
    end

    it "from template" do
      pr = Protocol.find_with_properties(Uri.new(uri: "http://www.transceleratebiopharmainc.com/FLU001/V1#PR"))
      template = ProtocolTemplate.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/PARALLEL_SIMPLE/V1#PRT"))
      pr.from_template(template)
      pr = Protocol.find_with_properties(Uri.new(uri: "http://www.transceleratebiopharmainc.com/FLU001/V1#PR"))
      pr.specifies_arm_objects
      pr.specifies_epoch_objects
      check_file_actual_expected(pr.to_h, sub_dir, "from_template_expected_1.yaml", equate_method: :hash_equal)
    end

    it "objectives and endpoints" do
      pr = Protocol.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      results = pr.objectives
      check_file_actual_expected(results, sub_dir, "objectives_expected_1.yaml", equate_method: :hash_equal)
      results = pr.endpoints
      check_file_actual_expected(results, sub_dir, "endpoints_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

  end

end