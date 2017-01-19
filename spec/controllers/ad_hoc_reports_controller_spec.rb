require 'rails_helper'

describe AdHocReportsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers

  describe "ad hoc reports as content admin" do
  
    login_content_admin
  
    def sub_dir
      return "controllers"
    end

    before :all do
      clear_triple_store
      AdHocReport.delete_all
      ahr = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end
    
    it "lists all the reports" do
      get :index
      expect(assigns(:items).count).to eq(3) 
      expect(response).to render_template("index")
    end

    it "initiates creation of a new report" do
      get :new
      expect(response).to render_template("new")
    end

    it "allows a new report to be created, missing file" do
      count = AdHocReport.all.count
      post :create, { ad_hoc_report: { label: "A new report", filename: "filname_root" }}
      item = assigns(:new_report)
      #expect(item.errors.count).to eq(1)
      #expect(item.errors.full_messages.to_sentence).to eq("Filename contains invalid characters or is empty")
      expect(flash[:error]).to be_present
      expect(AdHocReport.all.count).to eq(count)
      expect(response).to redirect_to("http://test.host/ad_hoc_reports/new")
    end

    it "allows a new report to be created, error label" do
      count = AdHocReport.all.count
      post :create, { ad_hoc_report: { label: "A new report@", filename: "filname_root" }}
      expect(flash[:error]).to be_present
      expect(AdHocReport.all.count).to eq(count)
      expect(response).to redirect_to("http://test.host/ad_hoc_reports/new")
    end

    it "allows a new report to be created, error filename root" do
      count = AdHocReport.all.count
      post :create, { ad_hoc_report: { label: "A new report", filename: "filname_rootA" }}
      item = assigns(:new_report)
      expect(flash[:error]).to be_present
      expect(AdHocReport.all.count).to eq(count)
      expect(response).to redirect_to("http://test.host/ad_hoc_reports/new")
    end

    it "allows a new report to be created" do
      copy_file_to_public_files("controllers", "ad_hoc_report_1_sparql.yaml", "test")
      count = AdHocReport.all.count
      post :create, { ad_hoc_report: { label: "The first report", filename: "ad_hoc_report_1" }}
      expect(AdHocReport.all.count).to eq(count + 1)
      expect(response).to redirect_to("http://test.host/ad_hoc_reports")
    end

    it "allows a report to be run"

    it "allows a report to be deleted"

    it "allows the results of a report to be presented"

  end
  
  describe "Curator Role" do
  	
    login_curator
   
    before :all do
      clear_triple_store
      AdHocReport.delete_all
      ahr = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end
    
    it "lists all the reports" do
      get :index
      expect(assigns(:items).count).to eq(3) 
      expect(response).to render_template("index")
    end

    it "prevents a new report to be created"

    it "allows a report to be run"

    it "prevents a report to be deleted"

    it "allows the results of a report to be presented"
  end

  describe "Reader Role" do
    
    login_reader
   
    before :all do
      clear_triple_store
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      AdHocReport.delete_all
      ahr = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end
    
    it "prevents a reader listing all the reports" do
      get :index
      expect(response).to redirect_to("/")
    end

    it "prevents a reader creating a report" do
      get :new
      expect(response).to redirect_to("/")
    end

    it "prevents a reader running a report" do
      get :run, { id: 1 }
      expect(response).to redirect_to("/")
    end

    it "prevents a reader seeing the results of a report" do
      get :show, { id: 1 }
      expect(response).to redirect_to("/")
    end

  end

  describe "Unauthorized User" do
    
    it "prevents unauthorized access to listing all the reports" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents unauthorized access to creating a report" do
      get :new
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents unauthorized access to running a report" do
      get :run, { id: 1 }
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents unauthorized access to seeing the results of a report" do
      get :show, { id: 1 }
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end