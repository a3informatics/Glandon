require 'rails_helper'

describe CdiscTermsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  
  def sub_dir
    return "controllers/cdisc_terms"
  end
    
  describe "Curator User" do
  	
    login_curator

    # def standard_params
    #   params = 
    #   {
    #     :draw => "1", 
    #     :columns =>
    #     {
    #       "0" => {:data  => "parentIdentifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
    #       "1" => {:data  => "identifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
    #       "2" => {:data  => "notation", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
    #       "3" => {:data  => "preferredTerm", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
    #       "4" => {:data  => "synonym", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
    #       "5" => {:data  => "definition", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false"}}
    #     }, 
    #     :order => { "0" => { :column => "0", :dir => "asc" }}, 
    #     :start => "0", 
    #     :length => "15", 
    #     :search => { :value => "", :regex => "false" }, 
    #     :id => "TH-CDISC_CDISCTerminology", 
    #     :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V43"
    #   }
    #   return params
    # end

  before :each do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = 
    [
      "iso_namespace_real.ttl", "iso_registration_authority_real.ttl",     
    ]
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
    load_data_file_into_triple_store("cdisc/ct/CT_V2.ttl")
  end

    it "index" do
      return_values = []
      (1..20).each_with_index {|x, index| return_values << {id: Uri.new(uri: "http://www.example.com/a##{index+1}").to_id, date: "2019-01-01"}}
      expect(CdiscTerm).to receive(:version_dates).and_return(return_values)
      get :index
      expect(assigns(:current_id)).to eq(Uri.new(uri: "http://www.example.com/a#17").to_id) # 4th to end
      expect(assigns(:latest_id)).to eq(Uri.new(uri: "http://www.example.com/a#20").to_id) # Latest
      expect(assigns(:versions)).to eq(return_values.reverse)
      expect(response).to render_template("index")
    end

    it "shows the history, initial view" do
      params = {}
      expect(Thesaurus).to receive(:history_uris).with({identifier: CdiscTerm::C_IDENTIFIER, scope: an_instance_of(IsoNamespace)}).and_return([Uri.new(uri: "http://www.example.com/a#1"),Uri.new(uri: "http://www.example.com/a#2")])
      get :history
      expect(assigns(:cdisc_term_id)).to eq("aHR0cDovL3d3dy5leGFtcGxlLmNvbS9hIzI=")
      expect(assigns(:identifier)).to eq(CdiscTerm::C_IDENTIFIER)
      expect(assigns(:scope_id)).to eq(IsoRegistrationAuthority.cdisc_scope.id)
      expect(response).to render_template("history")
    end

    it "shows the history, page" do
      CT1 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      CT2 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus).to receive(:history_pagination).with({identifier: CdiscTerm::C_IDENTIFIER, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([CT1, CT2])        
      get :history, {cdisc_term: {count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

=begin
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
=end
    # it "changes" do
    #   @user.write_setting("max_term_display", 2)
    #   expect(CdiscTerm).to receive(:find).and_return(CdiscTerm.new)
    #   expect_any_instance_of(CdiscTerm).to receive(:forward_backward).and_return({start: nil, end: "aaa1"})
    #   get :changes, id: "aaa"
    #   expect(assigns(:links)).to eq({start: "", end: "/cdisc_terms/aaa1/changes"})
    #   expect(response).to render_template("changes")
    # end

    # it "obtains the change results" do
    #   @user.write_setting("max_term_display", 2)
    #   expect(CdiscTerm).to receive(:find).and_return(CdiscTerm.new)
    #   expect_any_instance_of(CdiscTerm).to receive(:changes).with(2).and_return({versions: ["2019-01-01"], items: {}})
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :changes_results, id: "aaa"
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200") 
    #   expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq({items: {}, versions: ["2019-01-01"]})
    # end

    # it "changes_report" do
    #   @user.write_setting("max_term_display", 2)
    #   request.env['HTTP_ACCEPT'] = "application/pdf"
    #   expect(CdiscTerm).to receive(:find).and_return(CdiscTerm.new)
    #   expect_any_instance_of(CdiscTerm).to receive(:changes).with(2).and_return({versions: ["2019-01-01"], items: {}})
    #   get :changes_report, id: "aaa"
    #   expect(response.content_type).to eq("application/pdf")
    # end

    # it "submission" do
    #   @user.write_setting("max_term_display", 2)
    #   expect(CdiscTerm).to receive(:find).and_return(CdiscTerm.new)
    #   expect_any_instance_of(CdiscTerm).to receive(:forward_backward).and_return({start: nil, end: "aaa1"})
    #   get :submission, id: "aaa"
    #   expect(assigns(:links)).to eq({start: "", end: "/cdisc_terms/aaa1/submission"})
    #   expect(response).to render_template("submission")
    # end

    # it "obtains the submission results" do
    #   @user.write_setting("max_term_display", 2)
    #   expect(CdiscTerm).to receive(:find).and_return(CdiscTerm.new)
    #   expect_any_instance_of(CdiscTerm).to receive(:submission).with(2).and_return({versions: ["2019-01-01"], items: {}})
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :submission_results, id: "aaa"
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200") 
    #   expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq({items: {}, versions: ["2019-01-01"]})
    # end

    # it "submission_report" do
    #   @user.write_setting("max_term_display", 2)
    #   request.env['HTTP_ACCEPT'] = "application/pdf"
    #   expect(CdiscTerm).to receive(:find).and_return(CdiscTerm.new)
    #   expect_any_instance_of(CdiscTerm).to receive(:submission).with(2).and_return({versions: ["2019-01-01"], items: {}})
    #   get :submission_report, id: "aaa"
    #   expect(response.content_type).to eq("application/pdf")
    #end

  end

  describe "Content Admin User" do
    
    login_content_admin

    it "shows the history, initial view" do
      expect(Thesaurus).to receive(:history_uris).with({identifier: CdiscTerm::C_IDENTIFIER, scope: instance_of(IsoNamespace)}).and_return([Uri.new(uri: "http://www.example.com/a#1")])
      get :history
      expect(response).to render_template("history")
    end

  end

  describe "Reader User" do
    
    login_reader

    it "shows the history, initial view" do
      expect(Thesaurus).to receive(:history_uris).with({identifier: CdiscTerm::C_IDENTIFIER, scope: instance_of(IsoNamespace)}).and_return([Uri.new(uri: "http://www.example.com/a#1")])
      get :history
      expect(response).to render_template("history")
    end

    # it "prevents access to the import view"  do
    #   get :import
    #   expect(response).to redirect_to("/")
    # end

    # it "prevents access to the import cross reference view"  do
    # 	params = { id: "TH-CDISC_CDISCTerminology", cdisc_term: { namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V39" }}
    #   get :import_cross_reference, params
    #   expect(response).to redirect_to("/")
    # end

    # it "prevents access to creation of a CDISC Terminology" do
    #   params = { cdisc_term: { version: "12", date: "2016-12-13", files: ["xxx.txt"] }}
    #   post :create, params
    #   expect(response).to redirect_to("/")
    # end
    
    # it "prevents access to creation of a cross reference" do
    #   params = { id: "TH-CDISC_CDISCTerminology", cdisc_term: { namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V39", uri: "", 
    #   	version: "39", files: ["xxx.txt"] }}
    #   post :create_cross_reference, params
    #   expect(response).to redirect_to("/")
    # end
    
    # it "prevents access to the list of the CDISC files" do
    #   expected = 
    #   [
    #     "public/test/CDISC_CT_40_39_Changes.yaml", 
    #     "public/test/CDISC_CT_Changes.yaml", 
    #     "public/test/CDISC_CT_Submission_Changes.yaml"
    #   ]
    #   get :file
    #   expect(response).to redirect_to("/")
    # end

    # it "prevents access to file deletion" do
    #   expected = 
    #   [
    #     "public/test/CDISC_CT_Changes.yaml", 
    #     "public/test/CDISC_CT_Submission_Changes.yaml"
    #   ]
    #   params = {:cdisc_term => { :files => ["public/test/CDISC_CT_40_39_Changes.yaml"] }}
    #   delete :file_delete, params
    #   expect(response).to redirect_to("/")
    # end

    # it "displays the cross reference" do
    # 	params = { :id => "TH-CDISC_CDISCTerminology", cdisc_term: { direction: :to, namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V39" }}
    #   get :cross_reference, params
    #   expect(response).to render_template("cross_reference")
    #   expect(assigns(:cdisc_term).version).to eq(39)
    #   expect(assigns(:direction)).to eq(:to.to_s)
    # end

  end

  describe "Curator User" do
    
    login_curator

    it "shows the history, initial view" do
      expect(Thesaurus).to receive(:history_uris).with({identifier: CdiscTerm::C_IDENTIFIER, scope: instance_of(IsoNamespace)}).and_return([Uri.new(uri: "http://www.example.com/a#1")])
      get :history
      expect(response).to render_template("history")
    end

    # it "prevents access to the import view"  do
    #   get :import
    #   expect(response).to redirect_to("/")
    # end

    # it "prevents access to creation of a CDISC Terminology" do
    #   params = 
    #   {
    #     :cdisc_term => 
    #     { 
    #       :version => "12", 
    #       :date => "2016-12-13", 
    #       :files => ["xxx.txt"]
    #     }
    #   }
    #   post :create, params
    #   expect(response).to redirect_to("/")
    # end
    
    # it "prevents access to the list of the CDISC files" do
    #   expected = 
    #   [
    #     "public/test/CDISC_CT_40_39_Changes.yaml", 
    #     "public/test/CDISC_CT_Changes.yaml", 
    #     "public/test/CDISC_CT_Submission_Changes.yaml"
    #   ]
    #   get :file
    #   expect(response).to redirect_to("/")
    # end

    # it "prevents access to file deletion" do
    #   expected = 
    #   [
    #     "public/test/CDISC_CT_Changes.yaml", 
    #     "public/test/CDISC_CT_Submission_Changes.yaml"
    #   ]
    #   params = {:cdisc_term => { :files => ["public/test/CDISC_CT_40_39_Changes.yaml"] }}
    #   delete :file_delete, params
    #   expect(response).to redirect_to("/")
    # end

  end
  
end