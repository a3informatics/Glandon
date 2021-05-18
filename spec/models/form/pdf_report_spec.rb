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
    load_cdisc_term_versions(1..8)
    load_data_file_into_triple_store("mdr_identification.ttl")
    @user = User.create email: "wicked@example.com", password: "Changeme1#"
  end

  it "creates simple non-annotated report" do
    form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    form_html = form.crf
    report = form.create(form, form_html, @user, "http://localhost:3000")
  #Xwrite_text_file_2(report, sub_dir, "report_1.txt")
    expected = read_text_file_2(sub_dir, "report_1.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(report)
    change_1 = extract_change(expected)
    change_2 = extract_change(report)
    report.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    report.sub!(change_2, change_1) # Need to fix the change date and time for the comparison
    expect(report).to eq(expected)
  end

  it "creates simple annotated report" do
    form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    form_html = form.acrf
    report = form.create(form, form_html, @user, "http://localhost:3000")
  #Xwrite_text_file_2(report, sub_dir, "report_2.txt")
    expected = read_text_file_2(sub_dir, "report_2.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(report)
    change_1 = extract_change(expected)
    change_2 = extract_change(report)
    report.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    report.sub!(change_2, change_1) # Need to fix the change date and time for the comparison
    expect(report).to eq(expected)
  end

end
