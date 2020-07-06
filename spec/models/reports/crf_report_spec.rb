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
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("thesaurus.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("form_example_general.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("form_crf_test_1.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "creates simple non-annotated report" do
    user = User.create email: "wicked@example.com", password: "Changeme1#"
    form = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    report = Reports::CrfReport.new
    html = report.create(form, {:annotate => false, :full => false}, user)
  #write_text_file_2(html, sub_dir, "crf_report_simple_non_annotated.txt")
    expected = read_text_file_2(sub_dir, "crf_report_simple_non_annotated.txt")
    expect(html).to eq(expected)
  end

  it "creates simple annotated report" do
    user = User.create email: "wicked@example.com", password: "Changeme1#"
    form = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    report = Reports::CrfReport.new
    html = report.create(form, {:annotate => true, :full => false}, user)
  #write_text_file_2(html, sub_dir, "crf_report_simple_annotated.txt")
    expected = read_text_file_2(sub_dir, "crf_report_simple_annotated.txt")
    expect(html).to eq(expected)
  end

  it "creates full non-annotated report" do
    user = User.create email: "wicked@example.com", password: "Changeme1#"
    form = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    report = Reports::CrfReport.new
    html = report.create(form, {:annotate => true, :full => true}, user)
  #Xwrite_text_file_2(html, sub_dir, "crf_report_full_non_annotated.txt")
    expected = read_text_file_2(sub_dir, "crf_report_full_non_annotated.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    path_to_proj_1 = extract_path(expected)
    path_to_proj_2 = Rails.root.to_s
    expected.sub!(path_to_proj_1, path_to_proj_2)
    expect(html).to eq(expected)
  end

  it "creates full annotated report" do
    user = User.create email: "wicked@example.com", password: "Changeme1#"
    form = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    report = Reports::CrfReport.new
    html = report.create(form, {:annotate => true, :full => true}, user)
  #Xwrite_text_file_2(html, sub_dir, "crf_report_full_annotated.txt")
    expected = read_text_file_2(sub_dir, "crf_report_full_annotated.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    path_to_proj_1 = extract_path(expected)
    path_to_proj_2 = Rails.root.to_s
    expected.sub!(path_to_proj_1, path_to_proj_2)
    expect(html).to eq(expected)
  end

  it "creates a full annotated all features report" do
    user = User.create email: "wicked@example.com", password: "Changeme1#"
    form = Form.find("F-ACME_CRFTEST1" , "http://www.assero.co.uk/MDRForms/ACME/V1")
    report = Reports::CrfReport.new
    html = report.create(form, {:annotate => true, :full => true}, user)
  #Xwrite_text_file_2(html, sub_dir, "crf_report_full_annotated_all_features.txt")
    expected = read_text_file_2(sub_dir, "crf_report_full_annotated_all_features.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    path_to_proj_1 = extract_path(expected)
    path_to_proj_2 = Rails.root.to_s
    expected.sub!(path_to_proj_1, path_to_proj_2)
    expect(html).to eq(expected)
  end

  it "creates a simple non-annotated all features report" do
    user = User.create email: "wicked@example.com", password: "Changeme1#"
    form = Form.find("F-ACME_CRFTEST1" , "http://www.assero.co.uk/MDRForms/ACME/V1")
    report = Reports::CrfReport.new
    html = report.create(form, {:annotate => false, :full => false}, user)
  #write_text_file_2(html, sub_dir, "crf_report_simple_non_annotated_all_features.txt")
    expected = read_text_file_2(sub_dir, "crf_report_simple_non_annotated_all_features.txt")
    expect(html).to eq(expected)
  end

end
