require 'rails_helper'

describe BiomedicalConceptTemplatesController do

  include DataHelpers
  include PauseHelpers
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers"
    end

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

      load_test_file_into_triple_store("BCT.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "lists all unique templates, HTML" do
      get :index
      expect(assigns[:bcts].count).to eq(2)
      expect(response).to render_template("index")
    end
    
    it "lists all unique templates, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    write_text_file_2(response.body, sub_dir, "bct_controller_index.txt")
      expected = read_text_file_2(sub_dir, "bct_controller_index.txt")
      expect(response.body).to eq(expected)
    end

    it "lists all released templates, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :list
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      result = JSON.parse(response.body)
    #Xwrite_yaml_file(result, sub_dir, "bct_controller_list.yml")
      expected = read_yaml_file(sub_dir, "bct_controller_list.yml")
      expect(result).to hash_equal(expected)
    end

    it "lists all templates, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :all
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      result = JSON.parse(response.body)
    #Xwrite_yaml_file(result, sub_dir, "bct_controller_all.yml")
      expected = read_yaml_file(sub_dir, "bct_controller_all.yml")
      expect(result).to hash_equal(expected)
    end

    it "shows the history" do
      ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
      get :history, { :biomedical_concept_template => { :identifier => "Obs PQR", :scope_id => ra.ra_namespace.id }}
      expect(response).to render_template("history")
    end

    it "shows the history, redirects when empty" do
      ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
      get :history, { :biomedical_concept_template => { :identifier => "Obs PQRx", :scope_id => ra.ra_namespace.id }}
      expect(response).to redirect_to("/biomedical_concept_templates")
    end

    it "show" do
      get :show, { :id => "BCT-Obs_PQR", :biomedical_concept_template => { :namespace => "http://www.assero.co.uk/MDRBCTs/V1" }}
      expect(response).to render_template("show")
    end

  end

end