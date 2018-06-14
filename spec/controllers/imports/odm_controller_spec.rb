require 'rails_helper'

describe Imports::OdmController do

  include DataHelpers
  
  describe "Authorized User" do
  	
    def sub_dir
      return "controllers/imports/odm"
    end

    login_content_admin

    before :each do
      clear_triple_store
      Token.delete_all
=begin
      @lock_user = User.create :email => "lock@example.com", :password => "changeme" 
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
      load_test_file_into_triple_store("form_example_dm1_branch.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("CT_ACME_V1.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
=end
    end

    it "new" do
      get :index
      expect(assigns(:forms)).to eq([])
      expect(response).to render_template("index")
    end

    it "index, no file" do
      get :index
      expect(response).to render_template("index")
      expect(flash[:error]).to be_present
      expect(assigns(:forms)).to eq([])
    end

    it "index" do
      allow_any_instance_of(Import::Odm).to receive(:list).with({:filename=>"ODM.xml"}).and_return([{identifier: "AAA", label: "aaa"}, {identifier: "BBB", label: "bbb"}])
      get :index, {imports: {files: ["ODM.xml"]}}
      expect(response).to render_template("index")
      expect(assigns(:forms)).to eq([{identifier: "AAA", label: "aaa", filename: "ODM.xml"}, {identifier: "BBB", label: "bbb", filename: "ODM.xml"}])
    end

    it "create, errors" do
      odm = Import::Odm.new
      odm.errors.add(:base, "Errors")
      allow_any_instance_of(Import::Odm).to receive(:import).and_return(odm)
      post :create, {imports: {identifier: "AAA", filename: "ODM.xml"}}
      expect(response).to redirect_to(imports_odm_index_path(imports: {files: ["ODM.xml"]}))
      expect(flash[:error]).to be_present
    end

    it "create" do
      odm = Import::Odm.new
      allow_any_instance_of(Import::Odm).to receive(:import).and_return(odm)
      post :create, {imports: {identifier: "AAA", filename: "ODM.xml"}}
      expect(response).to redirect_to(forms_path)
      expect(flash[:success]).to be_present
    end

  end

  describe "Unauthorized User" do
    
    it "new" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "create" do
      post :create
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end