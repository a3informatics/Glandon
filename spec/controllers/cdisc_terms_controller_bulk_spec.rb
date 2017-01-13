require 'rails_helper'

describe CdiscTermsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  
  describe "Bulk CDISC Terminology Changes" do
  	
    login_curator

    def sub_dir
      return "controllers"
    end

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_data_file_into_triple_store("CT_V35.ttl")
      load_data_file_into_triple_store("CT_V36.ttl")
      load_data_file_into_triple_store("CT_V37.ttl")
      load_data_file_into_triple_store("CT_V38.ttl")
      load_data_file_into_triple_store("CT_V39.ttl")
      load_data_file_into_triple_store("CT_V40.ttl")
      load_data_file_into_triple_store("CT_V41.ttl")
      load_data_file_into_triple_store("CT_V42.ttl")
      load_data_file_into_triple_store("CT_V43.ttl")
      load_data_file_into_triple_store("CT_V44.ttl")
      load_data_file_into_triple_store("CT_V45.ttl")
      load_data_file_into_triple_store("CT_V46.ttl")
      load_data_file_into_triple_store("CT_V47.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      delete_all_public_files
    end

    it "calculates the bulk changes results" do
      file = CdiscCtChanges.dir_path + "CDISC_CT_Changes.yaml"
      File.delete(file) if File.exist?(file)
      get :changes_calc
      expect(response).to redirect_to("/backgrounds")
      results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
      #write_yaml_file(results, sub_dir, "cdisc_terms_controller_bulk_all_changes.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_terms_controller_bulk_all_changes.yaml")
      expect(results).to eq(expected)
    end

    it "calculates the bulk submission change results" do
      file = CdiscCtChanges.dir_path + "CDISC_CT_Submission_Changes.yaml"
      File.delete(file) if File.exist?(file)
      get :submission_calc
      expect(response).to redirect_to("/backgrounds")
      results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
      #write_yaml_file(results, sub_dir, "cdisc_terms_controller_bulk_submission_changes.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_terms_controller_bulk_submission_changes.yaml")
      expect(results).to eq(expected)
    end

  end

end