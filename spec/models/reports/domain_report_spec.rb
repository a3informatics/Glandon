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
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_dm.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_vs.ttl")
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "creates simple report" do
    user = User.create email: "wicked@example.com", password: "12345678"
    domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    report = Reports::DomainReport.new
    html = report.create(domain, {}, user)
  #write_text_file_2(html, sub_dir, "domain_report_simple.txt")
    expected = read_text_file_2(sub_dir, "domain_report_simple.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
  end

end