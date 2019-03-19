require 'rails_helper'

describe Reports::CdiscSubmissionReport do

  include DataHelpers
  include ReportHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/reports"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCTerm.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

    load_test_file_into_triple_store("CT_V34.ttl")
    load_test_file_into_triple_store("CT_V35.ttl")
    load_test_file_into_triple_store("CT_V36.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    delete_all_public_files
  end

  it "creates the report" do
    user = User.create email: "wicked@example.com", password: "12345678"
    job = Background.create
    job.submission_changes_cdisc_term()
    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
    report = Reports::CdiscSubmissionReport.new
    pdf = report.create(results, user)
    html = report.html
  #write_text_file_2(html, sub_dir, "cdisc_submission_report.txt")
    expected = read_text_file_2(sub_dir, "cdisc_submission_report.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
  end

end