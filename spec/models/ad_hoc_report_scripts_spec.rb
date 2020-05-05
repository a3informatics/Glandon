require 'rails_helper'

RSpec.describe AdHocReport, type: :model do
  
  include DataHelpers
  include PublicFileHelpers
  include CdiscCtHelpers

	def sub_dir
    return "models/ad_hoc_report"
  end

  describe "Simple Reports" do

    before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_airport_ad_hoc.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(CdiscCtHelpers.version_range)   
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
      check_file_actual_expected(results, sub_dir, "submission_impact_expected_1.yaml", equate_method: :hash_equal)
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
      check_file_actual_expected(results, sub_dir, "ct_references_inconsistencies_expected_1.yaml", equate_method: :hash_equal)
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
      check_file_actual_expected(results, sub_dir, "missing_tags_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Sponsor Extension Tests" do
    
    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(CdiscCtHelpers.version_range)
      load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl") 
      load_data_file_into_triple_store("sponsor_one/ct/CT_V3-0.ttl") 
      AdHocReport.delete_all
      delete_all_public_files
    end

    after :all do
      delete_all_public_files
    end

    it "executes an extension count report I" do
      copy_report_to_public_files("extension_count_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "extension_count_sparql.yaml"
      report.results_file = "extension_count_results_1.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.sanofi.com/2019_R1/V1#TH").to_id])}
      results = AdHocReportFiles.read("extension_count_results_1.yaml")
      check_file_actual_expected(results, sub_dir, "extension_count_expected_1.yaml", equate_method: :hash_equal)
    end


    it "executes an extension count report II" do
      copy_report_to_public_files("extension_count_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "extension_count_sparql.yaml"
      report.results_file = "extension_count_results_2.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.sanofi.com/2020_R1/V1#TH").to_id])}
      results = AdHocReportFiles.read("extension_count_results_2.yaml")
      check_file_actual_expected(results, sub_dir, "extension_count_expected_2.yaml", equate_method: :hash_equal)
    end
  
  end

    describe "CI Export Tests" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_versions(1..62)
      load_data_file_into_triple_store("cdisc/ct/changes/change_instructions_v47.ttl")
      load_data_file_into_triple_store("cdisc/ct/changes/change_instructions_v52.ttl")
      load_data_file_into_triple_store("cdisc/ct/changes/change_instructions_v53.ttl")
      AdHocReport.delete_all
      delete_all_public_files
    end

    after :all do
      delete_all_public_files
    end

    it "executes a change instructions export report" do
      copy_report_to_public_files("change_instructions_export_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "change_instructions_export_sparql.yaml"
      report.results_file = "change_instructions_export_results_1.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.cdisc.org/CT/V47#TH").to_id])}
      results = AdHocReportFiles.read("change_instructions_export_results_1.yaml")
      check_file_actual_expected(results, sub_dir, "change_instructions_export_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end
  
  end

end