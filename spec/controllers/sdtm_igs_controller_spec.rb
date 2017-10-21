require 'rails_helper'

describe SdtmIgsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  
  describe "Reader User" do
  	
    login_reader

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
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "shows the history" do
      get :history
      expect(response).to render_template("history")
    end

    it "show" do
      params = 
      { 
        :id => "IG-CDISC_SDTMIG", 
        sdtm_ig: 
        {
          :namespace => "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3" 
        }
      }
      get :show, params
      expect(response).to render_template("show")
    end

    it "allows for a SDTM Model to be exported as JSON" do
      get :export_json, { :id => "IG-CDISC_SDTMIG", sdtm_ig: { :namespace => "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3" }}
    end

    it "allows for a SDTM Model to be exported as TTL" do
      get :export_ttl, { :id => "IG-CDISC_SDTMIG", sdtm_ig: { :namespace => "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3" }}
    end

    it "prevents access to the import view"  do
      get :import
      expect(response).to redirect_to("/")
    end

    it "prevents access to creation of a SDTM Model" do
      post :create, {} # id needs to be there but doesn't do anything
      expect(response).to redirect_to("/")
    end

  end

  describe "Curator User" do
    
    login_curator

    it "prevents access to the import view"  do
      get :import
      expect(response).to redirect_to("/")
    end

    it "prevents access to creation of a SDTM Model" do
      post :create, {} # id needs to be there but doesn't do anything
      expect(response).to redirect_to("/")
    end
    
  end

  describe "Content Admin User" do
    
    login_content_admin

    it "presents the import view"  do
      get :import
      expect(assigns(:next_version)).to eq(4)
      expect(response).to render_template("import")
    end

    it "allows a SDTM IG to be created" do
      delete_public_file("upload", "")
      copy_file_to_public_files("controllers/sdtm_igs", "sdtm-3-1-2-excel.xlsx", "upload")
      filename = upload_path("sdtm-3-1-2-excel.xlsx")
      params = 
      {
        :sdtm_ig => 
        { 
          :version => "4",
          :version_label => "2.0",
          :date => "2017-10-14", 
          :files => ["#{filename}"]
        }
      }
      post :create, params
      expect(response).to redirect_to("/backgrounds")
    end
    
    it "allows a SDTm Model to be created, error version" do
      filename = upload_path("sdtm-3-1-2-excel.xlsx")
      params = 
      {
        :sdtm_ig => 
        { 
          :version => "aa", 
          :version_label => "2.0",
          :date => "2016-12-13", 
          :files => ["#{filename}"]
        }
      }
      post :create, params
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/sdtm_igs/history")
    end

  end

end