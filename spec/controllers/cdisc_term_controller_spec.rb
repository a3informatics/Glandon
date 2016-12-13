require 'rails_helper'

describe CdiscTermsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  
  describe "Curator User" do
  	
    login_curator

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
      #write_hash_to_yaml_file(results.to_json, "cdisc_term_controller_find_submission.yaml")
      expected = read_yaml_file_to_hash("cdisc_term_controller_find_submission.yaml")
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

    it "import"

    it "create"
    
    it "show" do
      params = { :id => "TH-CDISC_CDISCTerminology", :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V39" }
      get :show, params
      expect(response).to render_template("show")
    end

    it "search" do
      params = { :id => "TH-CDISC_CDISCTerminology", :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V39" }
      get :search, params
      expect(response).to render_template("search")
    end

    it "next" do
      request.env['HTTP_ACCEPT'] = "application/json"
      params = { :id => "TH-CDISC_CDISCTerminology", :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V39", :offset => "20", :limit => "20" }
      get :next, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      #write_text_file(response.body, "cdisc_term_controller_next.txt")
      expected = read_text_file("cdisc_term_controller_next.txt")
      expect(response.body).to eq(expected)
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
      expect(response).to render_template("changes")
    end

    it "changes_report" do
      get :changes_report
      expect(assigns(:pdf)[0,4]).to eq('%PDF')
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
      expect(response).to render_template("submission")
    end

    it "submission_report" do
      get :submission_report
      expect(assigns(:pdf)[0,4]).to eq('%PDF')
    end
    
    it "impact"
    it "impact_graph"
    it "impact_calc"
    it "impact_report"

  end

  describe "Content Admin User" do
    
    login_content_admin

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

end