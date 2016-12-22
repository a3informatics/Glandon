require 'rails_helper'

describe Reports::CrfReport do

  include DataHelpers
  include ReportHelpers
  include PublicFileHelpers
  
  def sub_dir
    return "models/reports"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCTerm.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("form_example_general.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "creates html minimal report" do
    user = User.create email: "wicked@example.com", password: "12345678"
    form = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    report = Reports::CrfReport.new
    html = report.create(form, {:annotate => false, :full => false}, user)
    write_text_file_2(html, sub_dir, "crf_report_html_none.txt")
    expected = read_text_file_2(sub_dir, "crf_report_html_none.txt")
    #run_at_1 = extract_run_at(expected)
    #run_at_2 = extract_run_at(html)
    #html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
    expect(true).to eq(false) # Make it fail so we dont forget this form is not rendering correctly
  end

  it "creates html full report"

  it "creates pdf minimal report"

  it "creates pdf full report"

  it "creates a BC-based report"

  it "creates a mixed form report"

  it "creates a repeating group report"

  it "creates a repeating BC group report"

end