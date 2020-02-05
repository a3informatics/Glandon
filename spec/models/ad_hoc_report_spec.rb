require 'rails_helper'

RSpec.describe AdHocReport, type: :model do
  
  include DataHelpers
  include PublicFileHelpers

	def sub_dir
    return "models/ad_hoc_report"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)    
    AdHocReport.delete_all
    delete_all_public_files
  end

  after :all do
    delete_all_public_files
  end

  it "creates a report" do
  	copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(item.errors.count).to eq(0)
    expect(public_file_exists?("test", "ad_hoc_report_1_sparql.yaml")).to eq(true)
  end

  it "stops a duplicate report being created" do
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The report already exists")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, error" do
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_err_1_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_err_1_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The SPARQL file did not contain the correct format")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, error" do
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_err_2_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_err_2_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The SPARQL file did not contain the correct format")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, error" do
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_err_3_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_err_3_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The SPARQL file did not contain the correct format")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, error" do
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_err_4_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_err_4_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The SPARQL file did not contain the correct format")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, error" do
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_err_5_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_err_5_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The SPARQL file did not contain the correct format")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, missing file" do
    filename = public_path("upload", "ad_hoc_report_test_X_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The report definition file did not exist")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, syntax error" do
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_err_6_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_err_6_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The SPARQL file contained a syntax error")
    expect(item.errors.count).to eq(1)
  end

  it "will run a report" do
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "test")
    report = AdHocReport.new
    expect(report).to receive(:execute).and_return(true)
    report.sparql_file = "ad_hoc_report_test_1_sparql.yaml"
    report.results_file = "ad_hoc_report_test_1_results.yaml"
    report.run
    expect(report.last_run).to be_within(1.second).of Time.now
    expect(report.background_id).not_to eq(-1)
    expect(report.active).to be(true)
    results = AdHocReportFiles.read(report.results_file)
    check_file_actual_expected(results, sub_dir, "run_expected_1.yaml")
    delete_public_file("reports", "ad_hoc_report_1_results.yaml")
  end

  it "determine if the report is running" do
    report = AdHocReport.new
    job = Background.new
    job.save
    job.complete = false
    report.background_id = job.id
    expect(report.running?).to eq(true)
    expect(report.active).to eq(true)
    expect(report.background_id).to eq(job.id)
  end

  it "determine if the report is running, completed" do
    report = AdHocReport.new
    report.background_id = -1
    expect(report.running?).to eq(false)
    expect(report.active).to eq(false)
    expect(report.background_id).to eq(-1)
  end

  it "will return the column definitions" do
    report = AdHocReport.new
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "test")
    report.sparql_file = "ad_hoc_report_test_1_sparql.yaml"
    expected = {"?a"=>{:label=>"URI", :type=>"uri"}, "?b"=>{:label=>"Identifier", :type=>"literal"}, "?c"=>{:label=>"Label", :type=>"literal"}}
    results = report.columns
    check_file_actual_expected(results, sub_dir, "columns_expected_1.yaml")
  end

  it "will return the column definitions, fail" do
    report = AdHocReport.new
    report.sparql_file = "ad_hoc_report_test_1_sparql_xxx.yaml"
    expected = {}
    expect{report.columns}.to raise_error(Errors::ApplicationLogicError, "Error reading ad hoc report definition file.")
  end

  it "will output the report results in CSV format" do
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_results.yaml", "test")
    report = AdHocReport.new
    report.results_file = "ad_hoc_report_test_1_results.yaml"
    result = report.to_csv
  #write_text_file_2(result, sub_dir, "ad_hoc_report_csv_1.txt")
    expected = read_text_file_2(sub_dir, "ad_hoc_report_csv_1.txt")
    expect(result).to eq(expected)
  end

  it "will output the report results in CSV format, fail" do
    report = AdHocReport.new
    report.results_file = "ad_hoc_report_1_results_xxx.yaml" # File does not exits
    result = report.to_csv
  #write_text_file_2(result, sub_dir, "ad_hoc_report_csv_2.txt")
    expected = read_text_file_2(sub_dir, "ad_hoc_report_csv_2.txt")
    expect(result).to eq(expected)
  end

  it "deletes a report" do
    delete_all_public_report_files
    delete_all_public_test_files
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.count).to eq(0)
    expect(public_file_exists?("test", "ad_hoc_report_1_sparql.yaml")).to eq(true)
    copy_file_to_public_files(sub_dir, "ad_hoc_report_1_results.yaml", "test")
    expect(public_file_exists?("test", "ad_hoc_report_1_results.yaml")).to eq(true)
    count = AdHocReport.all.count
    item.destroy_report
    expect(AdHocReport.all.count).to eq(count - 1)
    expect(public_file_does_not_exist?("test", "ad_hoc_report_1_sparql.yaml")).to eq(true)
    expect(public_file_does_not_exist?("test", "ad_hoc_report_1_results.yaml")).to eq(true)
  end

  it "executes a report" do
    copy_file_to_public_files(sub_dir, "ad_hoc_report_test_1_sparql.yaml", "test")
    job = Background.create
    report = AdHocReport.new
    report.background_id = job.id
    report.sparql_file = "ad_hoc_report_test_1_sparql.yaml"
    report.results_file = "ad_hoc_report_test_1_results.yaml"
    job.start("Rspec test", "Starting...") {report.execute}
    results = AdHocReportFiles.read("ad_hoc_report_test_1_results.yaml")
    check_file_actual_expected(results, sub_dir, "execute_expected_1.yaml")
  end 

end