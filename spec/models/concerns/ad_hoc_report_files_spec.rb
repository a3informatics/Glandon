require 'rails_helper'

describe AdHocReportFiles do

  include PublicFileHelpers
	
  test_json = 
  [ 
    { a: "A string", b: "B String", c: "child 1" },
    { a: "A string", b: "B String", c: "child 1" },
    { a: "A string", b: "B String", c: "child 1" },
    { a: "A string", b: "B String", c: "child 1" },
    { a: "A string", b: "B String", c: "child 1" },
    { a: "A string", b: "B String", c: "child 1" }
  ] 
  
  before :all do
    delete_all_public_files
  end

  it "builds the sparql filename" do
    expect(AdHocReportFiles.report_sparql_filename("x files")).to eq("x_files_sparql.yaml")
  end

  it "builds the sparql filename, . character" do
    expect(AdHocReportFiles.report_sparql_filename("this.is a x files")).to eq("thisis_a_x_files_sparql.yaml")
  end

  it "builds the sparql filename, special characters" do
    expect(AdHocReportFiles.report_sparql_filename("this.is a x !@£ files")).to eq("thisis_a_x__files_sparql.yaml")
  end

  it "builds the results filename" do
    expect(AdHocReportFiles.report_results_filename("x files")).to eq("x_files_results.yaml")
  end

	it "builds the results filename, . character" do
    expect(AdHocReportFiles.report_results_filename("this.is a x files")).to eq("thisis_a_x_files_results.yaml")
  end

  it "builds the results filename, special characters" do
    expect(AdHocReportFiles.report_results_filename("this.is a x !@£ files")).to eq("thisis_a_x__files_results.yaml")
  end

  it "builds the csv filename" do
    expect(AdHocReportFiles.report_csv_filename("x files")).to eq("x_files_results.csv")
  end
  
  it "builds the csv filename, special characters" do
    expect(AdHocReportFiles.report_csv_filename("csv )(*&^%$£and) files")).to eq("csv_and_files_results.csv")
  end

  it "returns the directory path" do
		expect(AdHocReportFiles.dir_path()).to eq("public/test/")
	end

  it "saves a file" do
    result = AdHocReportFiles.save("test_report.yaml", test_json)
    expect(result).to match(true)
    expect(AdHocReportFiles.read("test_report.yaml")).to match(test_json)
  end

  it "saves a file, failed" do
    result = AdHocReportFiles.save("/", test_json)
    expect(result).to match(false)
  end

  it "detects the existance of a file, present" do
    expect(AdHocReportFiles.exists?("test_report.yaml")).to eq(true)
  end

  it "detects the existance of a file, not present" do
    expect(AdHocReportFiles.exists?("test_report1.yaml")).to eq(false)
  end

  it "reads a file" do
    result = AdHocReportFiles.read("test_report.yaml")
    expect(result).to match(test_json)
  end

  it "reads a file, fail" do
    result = AdHocReportFiles.read("test_report.yamlxx")
    expect(result).to match("")
  end

  it "deletes a file" do
    result = AdHocReportFiles.delete("test_report.yaml")
    expect(result).to eq(true)
  end

  it "deletes a file, fail" do
    result = AdHocReportFiles.delete("test_report.yaml")
    expect(result).to eq(false)
  end

end