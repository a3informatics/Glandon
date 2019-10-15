require 'rails_helper'

describe Reports::CdiscSubmissionReport do

  include DataHelpers
  include ReportHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/reports/cdisc_submission_report"
  end

  before :each do
    @user = User.create email: "wicked@example.com", password: "Changeme1#"
  end

  after :each do
    user = User.where(:email =>  "wicked@example.com").first
    user.destroy
  end

  it "creates the report I" do
    results = read_yaml_file(sub_dir, "input_1.yaml")
    report = Reports::CdiscSubmissionReport.new
    pdf = report.create(results, @user)
    html = report.html
  #Xwrite_text_file_2(html, sub_dir, "report_1.txt")
    expected = read_text_file_2(sub_dir, "report_1.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    path_to_proj_1 = extract_path(expected)
    path_to_proj_2 = Rails.root.to_s
    expected.sub!(path_to_proj_1, path_to_proj_2)
    expect(html).to eq(expected)
  end

  it "creates the report II, bug report GLAN-919" do
    results = read_yaml_file(sub_dir, "input_2.yaml")
    report = Reports::CdiscSubmissionReport.new
    pdf = report.create(results, @user)
    html = report.html
  write_text_file_2(html, sub_dir, "report_2.txt")
    expected = read_text_file_2(sub_dir, "report_2.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    path_to_proj_1 = extract_path(expected)
    path_to_proj_2 = Rails.root.to_s
    expected.sub!(path_to_proj_1, path_to_proj_2)
    expect(html).to eq(expected)
  end

  it "creates the report III, bug report GLAN-919" do
    results = read_yaml_file(sub_dir, "input_3.yaml")
    report = Reports::CdiscSubmissionReport.new
    pdf = report.create(results, @user)
    html = report.html
  write_text_file_2(html, sub_dir, "report_3.txt")
    expected = read_text_file_2(sub_dir, "report_3.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    path_to_proj_1 = extract_path(expected)
    path_to_proj_2 = Rails.root.to_s
    expected.sub!(path_to_proj_1, path_to_proj_2)
    expect(html).to eq(expected)
  end

end
