require 'rails_helper'

describe AdHocReportsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  include ControllerHelpers
  include IsoManagedHelpers

  def sub_dir
    return "controllers/ad_hoc_reports"
  end

  def check_and_fix_report_times(report, *args)
    args.each do |a|
      expect( Timestamp.new(report[a]).time ).to be_within(5.seconds).of Time.now
      report[a] = Time.new(0).to_s
    end
  end

  def check_and_fix_report_paths(report, *args)
    args.each do |a|
      expect( report[a] ).to include "/ad_hoc_reports/#{report[:id]}"
      report[a] = "/ad_hoc_reports/id"
    end
  end

  describe "ad hoc reports as content admin" do

    login_content_admin

    before :all do
      clear_triple_store
      delete_all_public_upload_files
      delete_all_public_test_files
      delete_all_public_report_files
      AdHocReport.delete_all
      @ahr1 = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr2 = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr3 = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end

    after :all do
      delete_all_public_upload_files
      delete_all_public_test_files
      delete_all_public_report_files
    end

    it "lists all the reports" do
      get :index
      expect(response).to render_template("index")
    end

    it "lists all the reports, json" do
      AdHocReport.delete_all
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
      copy_file_to_public_files(sub_dir, "terminology_code_lists_sparql.yaml", "upload")
      @ahr1 = AdHocReport.create_report(files: [ public_path("upload", "ad_hoc_report_test_1_sparql.yaml") ])
      @ahr2 = AdHocReport.create_report(files: [ public_path("upload", "terminology_code_lists_sparql.yaml") ])

      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      expect(response.code).to eq("200")
      actual = check_good_json_response(response)
      actual = actual[:data]

      expect( actual.count ).to eq 2
      actual.each do |report|
        check_and_fix_report_times(report, :created_at, :updated_at, :last_run)
        check_and_fix_report_paths(report, :report_path, :run_path, :results_path)
        report[:id] = 'id'
      end

      check_file_actual_expected(actual, sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "initiates creation of a new report" do
      get :new
      expect(response).to render_template("new")
    end

    it "create a new report, no file selected" do
      request.env['HTTP_REFERER'] = '/ad_hoc_reports/index'
      post :create
      expect(response).to redirect_to("/ad_hoc_reports/index")
      expect(flash[:error]).to be_present
    end

    it "allows a new report to be created, missing file" do
      count = AdHocReport.all.count
      filename = public_path("upload", "filname_root.yaml")
      post :create, params:{ ad_hoc_report: { files: [filename] }}
      expect(flash[:error]).to be_present
      expect(AdHocReport.all.count).to eq(count)
      expect(response).to redirect_to("http://test.host/ad_hoc_reports/new")
    end

    it "allows a new report to be created" do
      delete_all_public_test_files
      delete_all_public_report_files
      audit_count = AuditTrail.count
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
      count = AdHocReport.all.count
      filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
      post :create, params:{ ad_hoc_report: { files: [filename] }}
      expect(flash[:success]).to be_present
      expect(AdHocReport.all.count).to eq(count + 1)
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(response).to redirect_to("http://test.host/ad_hoc_reports")
    end

    it "allows a report to be run" do
      delete_all_public_test_files
      delete_all_public_report_files
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
      filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
      post :create, params:{ ad_hoc_report: { files: [filename] }}
      report = AdHocReport.where(:label => "Ad Hoc Report 1").first
      get :run_start, params:{ id: report.id, ad_hoc_report: {query_params: []}}
      expect(response).to render_template("results")
    end

    it "allows the progress of a report run to be seen" do
      delete_all_public_test_files
      delete_all_public_report_files
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
      filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
      post :create, params:{ ad_hoc_report: { files: [filename] }}
      report = AdHocReport.where(:label => "Ad Hoc Report 1").first
      get :run_start, params:{ id: report.id, ad_hoc_report: {query_params: []} }
      get :run_progress, params:{ id: report.id }
      expect(response.code).to eq("200")
      expect(response.body).to eq("{\"running\":false}")
    end

    it "allows the results of a report to be presented" do
      delete_all_public_test_files
      delete_all_public_report_files
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
      filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
      post :create, params:{ ad_hoc_report: { files: [filename] }}
      report = AdHocReport.where(:label => "Ad Hoc Report 1").first
      get :run_start, params:{ id: report.id, ad_hoc_report: {query_params: []} }
      get :run_progress, params:{ id: report.id }
      get :run_results, params:{ id: report.id }
      expect(response.code).to eq("200")
      expect(response.body).to eq("{\"columns\":[[\"URI\"],[\"Identifier\"],[\"Label\"]],\"data\":[]}")
    end

    it "allows the existing results of a report to be presented" do
      delete_all_public_test_files
      delete_all_public_report_files
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
      filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
      post :create, params:{ ad_hoc_report: { files: [filename] }}
      report = AdHocReport.where(:label => "Ad Hoc Report 1").first
      get :results, params:{ id: report.id }
      found_report = assigns(:report)
      columns = assigns(:columns)
      expect(found_report.id).to eq(report.id)
      expect(columns).to eq({:"?a"=>{:label=>"URI", :type=>"uri"}, :"?b" => {:label=>"Identifier", :type=>"literal"}, :"?c" => {:label=>"Label", :type=>"literal"}})
      expect(response).to render_template("results")
    end

    it "allows a report to be deleted" do
      @request.env['HTTP_REFERER'] = 'http://test.host/ad_hoc_reports'
      audit_count = AuditTrail.count
      count = AdHocReport.all.count
      post :destroy, params:{ id: @ahr2.id }
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(AdHocReport.all.count).to eq(count - 1)
      expect(response.code).to eq("200")
    end

  end

  describe "ad hoc reports as curator" do

    login_curator

    before :all do
      clear_triple_store
      delete_all_public_files
      AdHocReport.delete_all
      @ahr1 = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr2 = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr3 = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end

    after :all do
      delete_all_public_upload_files
      delete_all_public_test_files
      delete_all_public_report_files
    end

    it "lists all the reports" do
      get :index
      expect(response).to render_template("index")
    end

    it "prevents a new report to be created" do
      get :new
      expect(response).to redirect_to("/")
    end

    it "allows a report to be run" do
      delete_all_public_test_files
      delete_all_public_report_files
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
      filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
      files = []
      files << filename
      AdHocReport.create_report({files: files}) # Create directly as user cannot
      report = AdHocReport.where(:label => "Ad Hoc Report 1").first
      get :run_start, params:{ id: report.id, ad_hoc_report: {query_params: []} }
      expect(response).to render_template("results")
    end

    it "allows the progress of a report run to be seen" do
      delete_all_public_test_files
      delete_all_public_report_files
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
      filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
      files = []
      files << filename
      AdHocReport.create_report({files: files}) # Create directly as user cannot
      report = AdHocReport.where(:label => "Ad Hoc Report 1").first
      get :run_start, params:{ id: report.id, ad_hoc_report: {query_params: []} }
      get :run_progress, params:{ id: report.id  }
      expect(response.code).to eq("200")
    end

    it "allows the results of a report to be presented" do
      delete_all_public_test_files
      delete_all_public_report_files
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
      filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
      files = []
      files << filename
      AdHocReport.create_report({files: files}) # Create directly as user cannot
      report = AdHocReport.where(:label => "Ad Hoc Report 1").first
      get :run_start, params:{ id: report.id, ad_hoc_report: {query_params: []} }
      get :run_results, params:{ id: report.id }
      expect(response.code).to eq("200")
      expect(response.body).to eq("{\"columns\":[[\"URI\"],[\"Identifier\"],[\"Label\"]],\"data\":[]}")
    end

     it "allows the existing results of a report to be presented" do
      delete_all_public_test_files
      delete_all_public_report_files
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
      filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
      filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
      files = []
      files << filename
      AdHocReport.create_report({files: files}) # Create directly as user cannot
      report = AdHocReport.where(:label => "Ad Hoc Report 1").first
      get :results, params:{ id: report.id }
      found_report = assigns(:report)
      columns = assigns(:columns)
      expect(found_report.id).to eq(report.id)
      expect(columns).to eq({:"?a"=>{:label=>"URI", :type=>"uri"}, :"?b" => {:label=>"Identifier", :type=>"literal"}, :"?c" => {:label=>"Label", :type=>"literal"}})
      expect(response.code).to eq("200")
    end

     it "prevents a report to be deleted" do
      post :destroy, params:{ id: @ahr3.id }
      expect(response).to redirect_to("/")
    end

  end

  describe "Reader Role" do

    login_reader

    before :all do
      clear_triple_store
      delete_all_public_files
      AdHocReport.delete_all
      ahr = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end

    after :all do
      delete_all_public_upload_files
      delete_all_public_test_files
      delete_all_public_report_files
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
      get :run_start, params:{ id: 1 }
      expect(response).to redirect_to("/")
    end

    it "prevents a reader seeing a running report" do
      get :run_progress, params:{ id: 1 }
      expect(response).to redirect_to("/")
    end

    it "prevents a reader to see report results" do
      get :run_results, params:{ id: 1 }
      expect(response).to redirect_to("/")
    end

    it "prevents a reader seeing the results of a report" do
      get :results, params:{ id: 1 }
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
      get :run_start, params:{ id: 1 }
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents unauthorized access to seeing a running report" do
      get :run_progress, params:{ id: 1 }
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents unauthorized access to report results" do
      get :run_results, params:{ id: 1 }
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents unauthorized access to seeing the results of a report" do
      get :results, params:{ id: 1 }
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end
