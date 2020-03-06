require 'rails_helper'

RSpec.describe AdHocReport, type: :model do
  
  include DataHelpers
  include PublicFileHelpers

	def sub_dir
    return "models/ad_hoc_report"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_airport_ad_hoc.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..62)    
    AdHocReport.delete_all
    delete_all_public_files
  end

  after :all do
    delete_all_public_files
  end

  it "executes a submission impact report" do
    copy_report_to_public_files("submission_impact_sparql.yaml", "test")
    job = Background.create
    report = AdHocReport.new
    report.background_id = job.id
    report.sparql_file = "submission_impact_sparql.yaml"
    report.results_file = "submission_impact_results_1.yaml"
    job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH").to_id])}
    results = AdHocReportFiles.read("submission_impact_results_1.yaml")
    check_file_actual_expected(results, sub_dir, "submission_impact_expected_1.yaml")
  end

  it "executes a ct references inconsistencies report" do
    copy_report_to_public_files("ct_references_inconsistencies_sparql.yaml", "test")
    job = Background.create
    report = AdHocReport.new
    report.background_id = job.id
    report.sparql_file = "ct_references_inconsistencies_sparql.yaml"
    report.results_file = "ct_references_inconsistencies_results_1.yaml"
    job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH").to_id])}
    results = AdHocReportFiles.read("ct_references_inconsistencies_results_1.yaml")
    check_file_actual_expected(results, sub_dir, "ct_references_inconsistencies_expected_1.yaml")
  end

  it "executes a missing tags report" do
    copy_report_to_public_files("missing_tags_sparql.yaml", "test")
    job = Background.create
    report = AdHocReport.new
    report.background_id = job.id
    report.sparql_file = "missing_tags_sparql.yaml"
    report.results_file = "missing_tags_results_1.yaml"
    job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH").to_id])}
    results = AdHocReportFiles.read("missing_tags_results_1.yaml")
    check_file_actual_expected(results, sub_dir, "missing_tags_expected_1.yaml")
  end
  
end