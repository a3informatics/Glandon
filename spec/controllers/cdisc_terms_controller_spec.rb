require 'rails_helper'

describe CdiscTermsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  
  describe "Curator User" do
  	
    login_curator

    def sub_dir
      return "controllers"
    end

    def standard_params
      params = 
      {
        :draw => "1", 
        :columns =>
        {
          "0" => {:data  => "parentIdentifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
          "1" => {:data  => "identifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
          "2" => {:data  => "notation", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
          "3" => {:data  => "preferredTerm", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
          "4" => {:data  => "synonym", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
          "5" => {:data  => "definition", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false"}}
        }, 
        :order => { "0" => { :column => "0", :dir => "asc" }}, 
        :start => "0", 
        :length => "15", 
        :search => { :value => "", :regex => "false" }, 
        :id => "TH-CDISC_CDISCTerminology", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V43"
      }
      return params
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
      delete_all_public_files
    end

    it "returns an error when it cannot find a code list, no current version" do
      @request.env['HTTP_REFERER'] = 'http://test.host/cdisc_term'
      params = { :notation => "VSTESTCDx" }
      get :find_submission, params
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match("Not current version of the terminology.")
      expect(response).to redirect_to("/cdisc_term")
    end
    
    it "finds a code list based on submission value" do
      th = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      IsoRegistrationState.make_current(th.registrationState.id)
      params = { :notation => "VSTESTCD" }
      get :find_submission, params
      results = assigns(:cdiscCl)
    #write_yaml_file(results.to_json, sub_dir, "cdisc_term_controller_find_submission.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_term_controller_find_submission.yaml")
      expect(results.to_json).to eq(expected)
    end
    
    it "returns an error when it cannot find a code list based on submission value" do
      @request.env['HTTP_REFERER'] = 'http://test.host/cdisc_term'
      params = { :notation => "VSTESTCDx" }
      get :find_submission, params
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match("Could not find the Code List.")
      expect(response).to redirect_to("/cdisc_term")
    end
    
    it "shows the history" do
      get :history
      expect(response).to render_template("history")
    end

    it "show the terminology" do
      params = { :id => "TH-CDISC_CDISCTerminology", :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V39" }
      get :show, params
      expect(response).to render_template("show")
    end

    it "initiates a search" do
      params = { :id => "TH-CDISC_CDISCTerminology", :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V39" }
      get :search, params
      expect(response).to render_template("search")
    end

    it "obtains the search results" do
      request.env['HTTP_ACCEPT'] = "application/json"
      params = standard_params
      params[:columns]["5"][:search][:value] = "cerebral"
      params[:search][:value] = "Temporal"
      results = CdiscTerm.search(params)
      get :search_results, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "calculates the compare results, no file" do
      file = CdiscCtChanges.dir_path + "CDISC_CT_40_39_Changes.yaml"
      File.delete(file) if File.exist?(file)
      params = { 
        :oldId => "TH-CDISC_CDISCTerminology", 
        :oldNamespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V39", 
        :newId => "TH-CDISC_CDISCTerminology", 
        :newNamespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V40" }
      get :compare_calc, params
      expect(response).to redirect_to("/backgrounds")
    end
    
    it "calculates the compare results, file" do
      params = { 
        :oldId => "TH-CDISC_CDISCTerminology", 
        :oldNamespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V39", 
        :newId => "TH-CDISC_CDISCTerminology", 
        :newNamespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V40" }
      get :compare_calc, params
      expect(response).to redirect_to("http://test.host/cdisc_terms/compare?newId=TH-CDISC_CDISCTerminology&newNamespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FCDISC%2FV40&oldId=TH-CDISC_CDISCTerminology&oldNamespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FCDISC%2FV39")
    end
    
    it "obtains the compare results" do
      params = { 
        :oldId => "TH-CDISC_CDISCTerminology", 
        :oldNamespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V39", 
        :newId => "TH-CDISC_CDISCTerminology", 
        :newNamespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V40" }
      get :compare, params
      expect(assigns(:identifier)).not_to eq(nil)
      expect(assigns(:trimmed_results)).not_to eq(nil)
      expect(assigns(:cls)).not_to eq(nil)
      expect(response).to render_template("changes")
    end

    it "calculates the changes results, no file" do
      file = CdiscCtChanges.dir_path + "CDISC_CT_Changes.yaml"
      File.delete(file) if File.exist?(file)
      get :changes_calc
      expect(response).to redirect_to("/backgrounds")
    end

    it "calculates the changes results, file" do
      get :changes_calc
      expect(response).to redirect_to("/cdisc_terms/changes")
    end

    it "obtains the change results" do
      get :changes
      expect(assigns(:identifier)).to eq('CDISC Terminology')
      expect(assigns(:previous_version)).to eq(nil)
      expect(assigns(:next_version)).to eq(nil)
      expect(assigns(:trimmed_results)).not_to eq(nil)
      expect(assigns(:cls)).not_to eq(nil)
      expect(response).to render_template("changes")
    end

    it "obtains the change results, version" do
      get :changes, { cdisc_term: {version: 40}}
      expect(assigns(:identifier)).to eq('CDISC Terminology')
      expect(assigns(:previous_version)).to eq(39)
      expect(assigns(:next_version)).to eq(nil)
      expect(response).to render_template("changes")
    end

    it "obtains the change results, version" do
			@user.write_setting("max_term_display", 2)
      get :changes, { cdisc_term: {version: 39}}
      expect(assigns(:identifier)).to eq('CDISC Terminology')
      expect(assigns(:previous_version)).to eq(nil)
      expect(assigns(:next_version)).to eq(40)
      expect(response).to render_template("changes")
    end

    it "changes_report" do
      request.env['HTTP_ACCEPT'] = "application/pdf"
      get :changes_report
      expect(response.content_type).to eq("application/pdf")
    end
    
    it "calculates the submission changes results, no file" do
      file = CdiscCtChanges.dir_path + "CDISC_CT_Submission_Changes.yaml"
      File.delete(file) if File.exist?(file)
      get :submission_calc
      expect(response).to redirect_to("/backgrounds")
    end

    it "calculates the submission changes results, file" do
      get :submission_calc
      expect(response).to redirect_to("/cdisc_terms/submission")
    end

    it "obtains the submission change results" do
      get :submission
      expect(assigns(:previous_version)).to eq(nil)
      expect(assigns(:next_version)).to eq(nil)
      expect(response).to render_template("submission")
    end

    it "submission_report" do
      request.env['HTTP_ACCEPT'] = "application/pdf"
      get :submission_report
      expect(response.content_type).to eq("application/pdf")
    end
    
  end

  describe "Content Admin User" do
    
    login_content_admin

    it "presents the import view"  do
      get :import
      expect(assigns(:next_version)).to eq(42)
      expect(response).to render_template("import")
    end

    it "allows a CDISC Terminology to be created" do
      delete_public_file("upload", "background_term.owl")
      copy_file_to_public_files("controllers", "background_term.owl", "upload")
      filename = upload_path("background_term.owl")
      params = 
      {
        :cdisc_term => 
        { 
          :version => "12", 
          :date => "2016-12-13", 
          :files => ["#{filename}"]
        }
      }
      post :create, params
      public_file_exists?("upload", "CT_V12.ttl")
      delete_public_file("upload", "CT_V12.ttl")
      expect(response).to redirect_to("/backgrounds")
    end
    
    it "allows a CDISC Terminology to be created, error" do
      filename = upload_path("background_term.owl")
      params = 
      {
        :cdisc_term => 
        { 
          :version => "aa", 
          :date => "2016-12-13", 
          :files => ["#{filename}"]
        }
      }
      post :create, params
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/cdisc_terms/import")
    end

    it "provides a list of the CDISC files" do
      expected = 
      [
        "public/test/CDISC_CT_40_39_Changes.yaml", 
        "public/test/CDISC_CT_Changes.yaml", 
        "public/test/CDISC_CT_Submission_Changes.yaml"
      ]
      get :file
      results = assigns(:files)
      expect(results).to match_array(expected)
    end

    it "allows a file to be deleted" do
      expected = 
      [
        "public/test/CDISC_CT_Changes.yaml", 
        "public/test/CDISC_CT_Submission_Changes.yaml"
      ]
      params = {:cdisc_term => { :files => ["public/test/CDISC_CT_40_39_Changes.yaml"] }}
      delete :file_delete, params
      files = Dir.glob(CdiscCtChanges.dir_path + "*")
      expect(files).to eq(expected)
    end

  end

  describe "Reader User" do
    
    login_reader

    it "prevents access to the import view"  do
      get :import
      expect(response).to redirect_to("/")
    end

    it "prevents access to creation of a CDISC Terminology" do
      params = 
      {
        :cdisc_term => 
        { 
          :version => "12", 
          :date => "2016-12-13", 
          :files => ["xxx.txt"]
        }
      }
      post :create, params
      expect(response).to redirect_to("/")
    end
    
    it "prevents access to the list of the CDISC files" do
      expected = 
      [
        "public/test/CDISC_CT_40_39_Changes.yaml", 
        "public/test/CDISC_CT_Changes.yaml", 
        "public/test/CDISC_CT_Submission_Changes.yaml"
      ]
      get :file
      expect(response).to redirect_to("/")
    end

    it "prevents access to file deletion" do
      expected = 
      [
        "public/test/CDISC_CT_Changes.yaml", 
        "public/test/CDISC_CT_Submission_Changes.yaml"
      ]
      params = {:cdisc_term => { :files => ["public/test/CDISC_CT_40_39_Changes.yaml"] }}
      delete :file_delete, params
      expect(response).to redirect_to("/")
    end

  end

  describe "Curator User" do
    
    login_curator

    it "prevents access to the import view"  do
      get :import
      expect(response).to redirect_to("/")
    end

    it "prevents access to creation of a CDISC Terminology" do
      params = 
      {
        :cdisc_term => 
        { 
          :version => "12", 
          :date => "2016-12-13", 
          :files => ["xxx.txt"]
        }
      }
      post :create, params
      expect(response).to redirect_to("/")
    end
    
    it "prevents access to the list of the CDISC files" do
      expected = 
      [
        "public/test/CDISC_CT_40_39_Changes.yaml", 
        "public/test/CDISC_CT_Changes.yaml", 
        "public/test/CDISC_CT_Submission_Changes.yaml"
      ]
      get :file
      expect(response).to redirect_to("/")
    end

    it "prevents access to file deletion" do
      expected = 
      [
        "public/test/CDISC_CT_Changes.yaml", 
        "public/test/CDISC_CT_Submission_Changes.yaml"
      ]
      params = {:cdisc_term => { :files => ["public/test/CDISC_CT_40_39_Changes.yaml"] }}
      delete :file_delete, params
      expect(response).to redirect_to("/")
    end

  end
  
end