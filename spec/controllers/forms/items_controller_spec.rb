require 'rails_helper'

describe Forms::ItemsController do

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
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("form_example_dm1.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
    end
 
    it "shows an BC Property item" do
      params = {id: "F-ACME_VSBASELINE1_G1_G2_I3" , formId: "F-ACME_VSBASELINE1", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      get :show, params
      item = assigns(:formItem)
      expect(item).to eq("")
    end

    it "shows a Question item" do
      params = {id: "F-ACME_DM101_G1_I5" , formId: "F-ACME_DM101", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      get :show, params
      item = assigns(:formItem)
      #write_hash_to_yaml_file(item.to_json, "forms_items_controller_question.yaml")
      expected = read_yaml_file_to_hash("forms_items_controller_question.yaml")
      expect(item.to_json).to eq(expected)
    end

    it "shows a Placeholder item"

    it "shows a Mapping item"

    it "shows a Text Label item"

  end

  describe "Unauthorized User" do
    
    it "show a item" do
      get :show, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end