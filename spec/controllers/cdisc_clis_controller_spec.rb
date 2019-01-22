require 'rails_helper'

describe CdiscClisController do

  include DataHelpers
  include PauseHelpers
  
  describe "Authorized User" do
  	
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
      load_test_file_into_triple_store("CT_V39.ttl")
      load_test_file_into_triple_store("CT_V41.ttl")
      load_test_file_into_triple_store("CT_V40.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    it "calculates all changes for a code list item" do
      params = {id: "CLI-C66741_C12472", cdisc_cli: {namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V39"}}
      get :changes, params
      results = assigns(:results)
    #write_yaml_file(results, sub_dir, "cdisc_cli_controller_changes_1.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cli_controller_changes_1.yaml")
      expect(results).to eq(expected)
    end
    
    it "calculates all changes for a code list item" do
      params = {id: "CLI-C120521_C120601", cdisc_cli: {namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V40"}}
      get :changes, params
      results = assigns(:results)
    #write_yaml_file(results, sub_dir, "cdisc_cli_controller_changes_2.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cli_controller_changes_2.yaml")
      expect(results).to eq(expected)
    end
    
    it "calculates all changes for a code list item" do
      params = {id: "CLI-C100145_C120601", cdisc_cli: {namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V39"}}
      get :changes, params
      results = assigns(:results)
    #write_yaml_file(results, sub_dir, "cdisc_cli_controller_changes_3.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cli_controller_changes_3.yaml")
      expect(results).to eq(expected)
    end
    
    it "shows a given code list item" do
      params = {id: "CLI-C66741_C12472", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V40"}
      get :show, params
      results = assigns(:cdiscCli)
    #write_yaml_file(results.to_json, sub_dir, "cdisc_cli_controller_show.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cli_controller_show.yaml")
      expect(results.to_json).to eq(expected)
    end

  end

end