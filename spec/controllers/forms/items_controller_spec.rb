require 'rails_helper'

describe Forms::ItemsController do

  C_SUB_DIR = "controllers/forms"

  include DataHelpers
  
  describe "Authrorized User" do
  	
    login_reader

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("form_example_dm1.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
    end
 
    it "shows an BC Property item" do
      params = {id: "F-ACME_VSBASELINE1_G1_G2_I3" , formId: "F-ACME_VSBASELINE1", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      get :show, params
      item = assigns(:formItem)
      property = assigns(:property)
      tcs = assigns(:tcs)
      #write_hash_to_yaml_file_2(item.to_json, C_SUB_DIR, "items_controller_bc_property.yaml")
      expected = read_yaml_file_to_hash_2(C_SUB_DIR, "items_controller_bc_property.yaml")
      expect(item.to_json).to eq(expected)
      # The TCs
      json = []
      tcs.each {|x| json << x.to_json}
      #write_hash_to_yaml_file_2(json, C_SUB_DIR, "items_controller_bc_property_tcs.yaml")
      expected_tcs = read_yaml_file_to_hash_2(C_SUB_DIR, "items_controller_bc_property_tcs.yaml")
      expect(json).to eq(expected_tcs)
      # The property
      #write_hash_to_yaml_file_2(property.to_json, C_SUB_DIR, "items_controller_bc_property_property.yaml")
      expected_property = read_yaml_file_to_hash_2(C_SUB_DIR, "items_controller_bc_property_property.yaml")
      expect(property.to_json).to eq(expected_property)
    end

    it "shows a Question item" do
      params = {id: "F-ACME_DM101_G1_I5", formId: "F-ACME_DM101", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      get :show, params
      item = assigns(:formItem)
      property = assigns(:property)
      tcs = assigns(:tcs)
      #write_hash_to_yaml_file_2(item.to_json, C_SUB_DIR, "items_controller_question.yaml")
      expected = read_yaml_file_to_hash_2(C_SUB_DIR, "items_controller_question.yaml")
      expect(item.to_json).to eq(expected)
      expect(tcs).to eq([])
      expect(property).to eq(nil)
    end

    it "shows a Placeholder item" do
      params = {id: "F-ACME_T2_G1_I1", formId: "F-ACME_T2", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      get :show, params
      item = assigns(:formItem)
      property = assigns(:property)
      tcs = assigns(:tcs)
      #write_hash_to_yaml_file_2(item.to_json, C_SUB_DIR, "items_controller_placeholder.yaml")
      expected = read_yaml_file_to_hash_2(C_SUB_DIR, "items_controller_placeholder.yaml")
      expect(item.to_json).to eq(expected)
      expect(tcs).to eq([])
      expect(property).to eq(nil)
    end

    it "shows a Mapping item" do
      params = {id: "F-ACME_T2_G1_I2", formId: "F-ACME_T2", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      get :show, params
      item = assigns(:formItem)
      property = assigns(:property)
      tcs = assigns(:tcs)
      #write_hash_to_yaml_file_2(item.to_json, C_SUB_DIR, "items_controller_mapping.yaml")
      expected = read_yaml_file_to_hash_2(C_SUB_DIR, "items_controller_mapping.yaml")
      expect(item.to_json).to eq(expected)
      expect(tcs).to eq([])
      expect(property).to eq(nil)
    end

    it "shows a Text Label item" do
      params = {id: "F-ACME_T2_G1_I3", formId: "F-ACME_T2", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      get :show, params
      item = assigns(:formItem)
      property = assigns(:property)
      tcs = assigns(:tcs)
      #write_hash_to_yaml_file_2(item.to_json, C_SUB_DIR, "items_controller_text_label.yaml")
      expected = read_yaml_file_to_hash_2(C_SUB_DIR, "items_controller_text_label.yaml")
      expect(item.to_json).to eq(expected)
      expect(tcs).to eq([])
      expect(property).to eq(nil)
    end

  end

  describe "Unauthorized User" do
    
    it "show a item" do
      get :show, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end