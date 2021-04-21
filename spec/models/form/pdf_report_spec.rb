require 'rails_helper'

describe Form::PDFReport do

  include DataHelpers
  include ReportHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/form"
  end

  before :all do
    data_files = ["forms/FN000150.ttl",]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..10)
    load_data_file_into_triple_store("mdr_identification.ttl")
  end

  it "creates simple non-annotated report" do
    user = User.create email: "wicked@example.com", password: "Changeme1#"
    form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    form_html = form.crf
    report = form.create(form, form_html, user)
    #html = report.html
  write_text_file_2(report, sub_dir, "report_1.txt")
    expected = read_text_file_2(sub_dir, "report_1.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(report)
    report.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    path_to_proj_1 = extract_path(expected)
    path_to_proj_2 = Rails.root.to_s
    expected.sub!(path_to_proj_1, path_to_proj_2)
    expect(report).to eq(expected)
  end

  # it "creates simple non-annotated report" do
  #   user = User.create email: "wicked@example.com", password: "Changeme1#"
  #   form = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   report = Reports::CrfReport.new
  #   html = report.create(form, {:annotate => false, :full => false}, user)
  # #write_text_file_2(html, sub_dir, "crf_report_simple_non_annotated.txt")
  #   expected = read_text_file_2(sub_dir, "crf_report_simple_non_annotated.txt")
  #   expect(html).to eq(expected)
  # end

  # it "creates simple annotated report" do
  #   user = User.create email: "wicked@example.com", password: "Changeme1#"
  #   form = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   report = Reports::CrfReport.new
  #   html = report.create(form, {:annotate => true, :full => false}, user)
  # #write_text_file_2(html, sub_dir, "crf_report_simple_annotated.txt")
  #   expected = read_text_file_2(sub_dir, "crf_report_simple_annotated.txt")
  #   expect(html).to eq(expected)
  # end

  # it "creates full non-annotated report" do
  #   user = User.create email: "wicked@example.com", password: "Changeme1#"
  #   form = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   report = Reports::CrfReport.new
  #   html = report.create(form, {:annotate => true, :full => true}, user)
  # #Xwrite_text_file_2(html, sub_dir, "crf_report_full_non_annotated.txt")
  #   expected = read_text_file_2(sub_dir, "crf_report_full_non_annotated.txt")
  #   run_at_1 = extract_run_at(expected)
  #   run_at_2 = extract_run_at(html)
  #   html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
  #   path_to_proj_1 = extract_path(expected)
  #   path_to_proj_2 = Rails.root.to_s
  #   expected.sub!(path_to_proj_1, path_to_proj_2)
  #   expect(html).to eq(expected)
  # end

  # it "creates full annotated report" do
  #   user = User.create email: "wicked@example.com", password: "Changeme1#"
  #   form = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   report = Reports::CrfReport.new
  #   html = report.create(form, {:annotate => true, :full => true}, user)
  # #Xwrite_text_file_2(html, sub_dir, "crf_report_full_annotated.txt")
  #   expected = read_text_file_2(sub_dir, "crf_report_full_annotated.txt")
  #   run_at_1 = extract_run_at(expected)
  #   run_at_2 = extract_run_at(html)
  #   html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
  #   path_to_proj_1 = extract_path(expected)
  #   path_to_proj_2 = Rails.root.to_s
  #   expected.sub!(path_to_proj_1, path_to_proj_2)
  #   expect(html).to eq(expected)
  # end

  # it "creates a full annotated all features report" do
  #   user = User.create email: "wicked@example.com", password: "Changeme1#"
  #   form = Form.find("F-ACME_CRFTEST1" , "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   report = Reports::CrfReport.new
  #   html = report.create(form, {:annotate => true, :full => true}, user)
  # #Xwrite_text_file_2(html, sub_dir, "crf_report_full_annotated_all_features.txt")
  #   expected = read_text_file_2(sub_dir, "crf_report_full_annotated_all_features.txt")
  #   run_at_1 = extract_run_at(expected)
  #   run_at_2 = extract_run_at(html)
  #   html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
  #   path_to_proj_1 = extract_path(expected)
  #   path_to_proj_2 = Rails.root.to_s
  #   expected.sub!(path_to_proj_1, path_to_proj_2)
  #   expect(html).to eq(expected)
  # end

  # it "creates a simple non-annotated all features report" do
  #   user = User.create email: "wicked@example.com", password: "Changeme1#"
  #   form = Form.find("F-ACME_CRFTEST1" , "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   report = Reports::CrfReport.new
  #   html = report.create(form, {:annotate => false, :full => false}, user)
  # #write_text_file_2(html, sub_dir, "crf_report_simple_non_annotated_all_features.txt")
  #   expected = read_text_file_2(sub_dir, "crf_report_simple_non_annotated_all_features.txt")
  #   expect(html).to eq(expected)
  # end

end
