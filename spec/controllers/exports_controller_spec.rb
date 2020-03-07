require 'rails_helper'

describe ExportsController do

  include DataHelpers
  include UploadHelpers
  
  describe "Authorized User" do
  	
    def sub_dir
      return "controllers/exports"
    end

    login_content_admin

    before :each do
      clear_triple_store
      Token.delete_all
      @lock_user = User.create :email => "lock@example.com", :password => "changeme" 
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    it "index" do
      get :index
      expect(response).to render_template("index")
    end

    it "start" do
      file = Hash.new
      file['datafile'] = fixture_file_upload(upload_path(sub_dir, "upload.txt"), 'text/html')
      get :start, { export: { export_list_path: "XXX" } }
      expect(assigns(:list_path)).to eq("XXX")
      expect(response).to render_template("start")
    end

    it "terminologies" #do
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :terminologies
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200") 
    #   expect(response.body.empty?).to eq(false)  
    # end

    it "biomedical_concepts" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :biomedical_concepts
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")   
      expect(response.body.empty?).to eq(false)  
    end

    it "forms" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :forms
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")   
      expect(response.body.empty?).to eq(false)  
    end

    it "download" do
      get :download, { export: { file_path: test_file_path(sub_dir, "download.ttl") } }
      allow_any_instance_of(ExportsController).to receive(:send_data).and_return(:success)
    end

  end

  describe "Unauthorized User" do
    
    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "start" do
      post :start
      expect(response).to redirect_to("/users/sign_in")
    end

    it "terminologies" do
      post :terminologies
      expect(response).to redirect_to("/users/sign_in")
    end

    it "biomedical_concepts" do
      post :biomedical_concepts
      expect(response).to redirect_to("/users/sign_in")
    end

    it "forms" do
      post :forms
      expect(response).to redirect_to("/users/sign_in")
    end

    it "download" do
      post :download
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end