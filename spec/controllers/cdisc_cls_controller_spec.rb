require 'rails_helper'

describe CdiscClsController do

  include DataHelpers
  
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
      load_test_file_into_triple_store("CT_V40.ttl")
      load_test_file_into_triple_store("CT_V41.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "calculates all changes for a code list" do
      params = { :id => "CL-C66741" }
      get :changes, params
      results = assigns(:results)
      ##write_yaml_file(results, sub_dir, "cdisc_cl_controller_changes_1.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cl_controller_changes_1.yaml")
      expect(results).to eq(expected)
      clis = assigns(:clis)
      ##write_yaml_file(clis, sub_dir, "cdisc_cl_controller_changes_2.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cl_controller_changes_2.yaml")
      expect(clis).to eq(expected)
    end
    
    it "calculates all changes for a code list" do
      params = { :id => "CL-C120521" }
      get :changes, params
      results = assigns(:results)
      #write_yaml_file(results, sub_dir, "cdisc_cl_controller_changes_3.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cl_controller_changes_3.yaml")
      expect(results).to eq(expected)
      clis = assigns(:clis)
      #write_yaml_file(clis, sub_dir, "cdisc_cl_controller_changes_4.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cl_controller_changes_4.yaml")
      expect(clis).to eq(expected)
    end

    it "calculates all changes for a code list" do
      params = { :id => "CL-C100145" }
      get :changes, params
      results = assigns(:results)
      #write_yaml_file(results, sub_dir, "cdisc_cl_controller_changes_5.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cl_controller_changes_5.yaml")
      expect(results).to eq(expected)
      clis = assigns(:clis)
      #write_yaml_file(clis, sub_dir, "cdisc_cl_controller_changes_6.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cl_controller_changes_6.yaml")
      expect(clis).to eq(expected)
    end

    it "shows a given code list" do
      params = {:id => "CL-C66741", :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V40"}
      get :show, params
      results = assigns(:cdiscCl)
      ##write_yaml_file(results.to_json, sub_dir, "cdisc_cl_controller_show.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_cl_controller_show.yaml")
      expect(results.to_json).to eq(expected)
    end

  end

end