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
      #expect(assigns(:statusCounts)).to eq([{:y=>"Candidate", :a=>"1"}, {:y=>"Standard", :a=>"16"}]) << Dashboard will change
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

	end

  describe "System Admin User" do

    login_sys_admin

    it "allows access, index to admin" do
      get :index
      expect(response).to render_template("index")
    end

    it "prevents access, view" do
      get :view, {id: "BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it "prevents access database action" do
      get :database, {id: "BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value_TR_1", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

  end

  describe "Term Reader User" do

    login_term_reader

    it "index, redirects to CDISC term" do
      get :index
      expect(response).to redirect_to thesauri_index_path
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

  end

  describe "No matching roles" do

    login_reader

    it "prevents access, index, redirects to error" do
     	allow(controller).to receive(:user_access_on_role).and_return(:none)
      get :index
      expect(response).to render_template("error")
    end

  end

	describe "No Role User" do

    login_no_role

  	it "displays triples" do
      get :view, {id: "BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it "gets more triples from the database" do
      get :database, {id: "BC-ACME_BC_C25347_DefinedObservation_nameCode_CD_originalText_ED_value_TR_1", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

  end

  describe "Not logged in" do

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

  end

end
