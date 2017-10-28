require 'rails_helper'

describe DashboardController do

  include DataHelpers
  
  def sub_dir
    return "controllers"
  end

  describe "Reader User" do
  	
    login_reader

    before :all do
      clear_triple_store
      load_test_file_into_triple_store("CT_V34.ttl")
      load_test_file_into_triple_store("CT_V35.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("form_example_dm1.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline.ttl")
      clear_iso_concept_object
    end

    it "provides the dashboard page" do
      get :index
      expect(assigns(:statusCounts)).to eq([{:y=>"Candidate", :a=>"1"}, {:y=>"Standard", :a=>"16"}])
      expect(response).to render_template("index")
    end

    it "displays triples" do
      get :view, {id: "BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      expect(assigns(:id)).to eq("BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value")
      expect(assigns(:namespace)).to eq("http://www.assero.co.uk/MDRBCs/V1")
      expect(response).to render_template("view")
    end

    it "gets more triples from the database" do
      get :database, {id: "BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value_TR_1", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      hash = JSON.parse(response.body, symbolize_names: true)
      hash.sort_by! {|u| u[:predicate]}
    #write_yaml_file(hash, sub_dir, "dashboard_controller_example_1.yaml")
      results = read_yaml_file(sub_dir, "dashboard_controller_example_1.yaml")
      expect(hash).to be_eql(results)
    end

    it "prevents access admin action" do
      put :admin
      expect(response).to redirect_to("/")
    end

	end

  describe "System Admin User" do
    
    login_sys_admin

    it "prevents access, index" do
      get :index
      expect(response).to render_template("index")
    end

    it "prevents access, view" do
      get :view, {id: "BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      assert_response :forbidden
      expect(response).to redirect_to(root_path)
      expect(page).to have_content("You do not have the access rights to that operation.")
    end

    it "prevents access database action" do
      get :database, {id: "BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value_TR_1", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      expect(response).to render_template("index")
    end

    it "prevents access admin action" do
      put :admin
      expect(response).to render_template("admin")
    end

  end

  describe "Unauthorized User" do
    
    it "prevents access, index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents access, view" do
      get :view, {id: "BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents access database action" do
      get :database, {id: "BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value_TR_1", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents access admin action" do
      put :admin
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end