require 'rails_helper'

describe Reports::CdiscChangesReport do

  include DataHelpers
  include ReportHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/reports/cdisc_changes_report"
  end

  before :each do
    @user = User.create email: "wicked@example.com", password: "12345678"
  end

  after :each do
    @user = User.create email: "wicked@example.com", password: "12345678"
  end

  it "creates the report" do
    results = read_yaml_file(sub_dir, "input_1.yaml")
    report = Reports::CdiscChangesReport.new
    pdf = report.create(results, @user)
    html = report.html
  write_text_file_2(html, sub_dir, "report_1.txt")
    expected = read_text_file_2(sub_dir, "report_1.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
  end

end