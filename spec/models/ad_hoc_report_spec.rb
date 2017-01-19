require 'rails_helper'

RSpec.describe AdHocReport, type: :model do
  
  include PublicFileHelpers

	before :all do
    AdHocReport.delete_all
    delete_all_public_files
  end

  it "creates a report" do
  	copy_file_to_public_files("models", "ad_hoc_report_test_1_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(item.errors.count).to eq(0)
    expect(public_file_exists?("test", "ad_hoc_report_1_sparql.yaml")).to eq(true)
  end

  it "stops a duplicate report being created" do
    copy_file_to_public_files("models", "ad_hoc_report_test_1_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_1_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The report already exists")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, error" do
    copy_file_to_public_files("models", "ad_hoc_report_test_err_1_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_err_1_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The SPARQL file did not contain the correct format")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, error" do
    copy_file_to_public_files("models", "ad_hoc_report_test_err_2_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_err_2_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The SPARQL file did not contain the correct format")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, error" do
    copy_file_to_public_files("models", "ad_hoc_report_test_err_3_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_err_3_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The SPARQL file did not contain the correct format")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, error" do
    copy_file_to_public_files("models", "ad_hoc_report_test_err_4_sparql.yaml", "upload")
    filename = public_path("upload", "ad_hoc_report_test_err_4_sparql.yaml")
    files = []
    files << filename
    item = AdHocReport.create_report({files: files})
    expect(item.errors.full_messages.to_sentence).to eq("Report was not created. The SPARQL file did not contain the correct format")
    expect(item.errors.count).to eq(1)
  end

  it "stops a report being created, error" do
    copy_file_to_public_files("models", "ad_hoc_report_test_err_5_sparql.yaml", "upload")
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

  it "will run a report" do
    report = AdHocReport.new
    report.sparql_file = "ad_hoc_report_1_sparql.yaml"
    report.results_file = "ad_hoc_report_1_results.yaml"
    report.run
    expect(report.last_run).to be_within(1.second).of Time.now
    expect(report.background_id).not_to eq(-1)
    expect(report.active).to be(true)
    results = AdHocReportFiles.read(report.results_file)
    expected = { columns: [], data: [] }
    expect(results).to eq(expected)
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
    report.sparql_file = "ad_hoc_report_1_sparql.yaml"
    expected = {"?a"=>"URI", "?b"=>"Identifier", "?c"=>"Label"}
    result = report.columns
    expect(result).to eq(expected)
  end

  it "will output the report results in CSV format" do
    report = AdHocReport.new
    report.sparql_file = "ad_hoc_report_1_sparql.yaml"
    report.results_file = "ad_hoc_report_1_results.yaml"
    report.run
    result = report.to_csv
    puts result
  end

end