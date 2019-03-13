require 'rails_helper'

describe Reports::WickedCore do

  include DataHelpers
  include ReportHelpers
  
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
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "Initiates a report" do
    user = User.create email: "wicked@example.com", password: "12345678"
    report = Reports::WickedCore.new
    report.open("TEST DOC", "Title", [], user)
    html = report.html
  #write_text_file_2(html, sub_dir, "wicked_core_simple_report.txt")
    expected = read_text_file_2(sub_dir,"wicked_core_simple_report.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
  end

  it "Initiates a full report" do
    user = User.create email: "wicked@example.com", password: "12345678"
    mi = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    history = 
    [
      {
        :last_changed_date => "2012-12-01T19:00:00+00:00",
        :change_description => "A Change \n * List \n * list",
        :explanatory_comment => "Hello *Cruel* world",
        :origin => "Humph"
      },
      {
        :last_changed_date => "2013-12-01T19:00:00+00:00",
        :change_description => "A Change \n * List \n * list \n * list \n * list",
        :explanatory_comment => "Hello *Cruel* world!!!!!!",
        :origin => "Humph!!!!!!!"

      }
    ] 
    report = Reports::WickedCore.new
    report.open("TEST DOC", "Title", history, user)
    html = report.html
  #write_text_file_2(html, sub_dir, "wicked_core_full_report.txt")
    expected = read_text_file_2(sub_dir, "wicked_core_full_report.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
  end

  it "Allows the body to be set" do
    user = User.create email: "wicked@example.com", password: "12345678"
    report = Reports::WickedCore.new
    report.open("TEST DOC", "Title", [], user)
    report.add_to_body("<h1>THIS IS THE BODY ITEM 1</h1>")
    report.add_to_body("<h1>THIS IS THE BODY ITEM 2</h1>")
    html = report.html
  #write_text_file_2(html, sub_dir, "wicked_core_body.txt")
    expected = read_text_file_2(sub_dir, "wicked_core_body.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
  end

  it "Allows a page break to be set" do
    user = User.create email: "wicked@example.com", password: "12345678"
    report = Reports::WickedCore.new
    report.open("TEST DOC", "Title", [], user)
    report.add_to_body("<h1>THIS IS THE BODY</h1>")
    report.add_page_break
    report.add_to_body("<h1>THIS IS MORE OF THE BODY</h1>")
    report.add_page_break
    html = report.html
  #write_text_file_2(html, sub_dir, "wicked_core_break.txt")
    expected = read_text_file_2(sub_dir, "wicked_core_break.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
  end

  it "Allows the document to be closed" do
    user = User.create email: "wicked@example.com", password: "12345678"
    report = Reports::WickedCore.new
    report.open("TEST DOC", "Title", [], user)
    report.add_to_body("<h1>THIS IS THE BODY. Close check</h1>")
    report.add_page_break
    report.add_to_body("<h1>THIS IS MORE OF THE BODY</h1>")
    report.add_to_body(html)
    report.close
    html = report.html
  #write_text_file_2(html, sub_dir, "wicked_core_closed.txt")
    expected = read_text_file_2(sub_dir, "wicked_core_closed.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
  end

  it "Allows the document html to be returned" do
    user = User.create email: "wicked@example.com", password: "12345678"
    report = Reports::WickedCore.new
    report.open("TEST DOC", "Title", [], user)
    report.add_to_body("<h1>THIS IS THE BODY. This is the html check</h1>")
    report.add_page_break
    report.add_to_body("<h1>THIS IS MORE OF THE BODY</h1>")
    report.add_to_body(html)
    report.close
    html = report.html
  #write_text_file_2(html, sub_dir, "wicked_core_html.txt")
    expected = read_text_file_2(sub_dir, "wicked_core_html.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
  end

  it "Allows the PDF to be generated" do
    user = User.create email: "wicked@example.com", password: "12345678"
    report = Reports::WickedCore.new
    report.open("TEST DOC", "Title", [], user)
    report.open("TEST DOC", "Title", [], user)
    report.add_to_body("<h1>THIS IS THE BODY</h1>")
    report.add_page_break
    report.add_to_body("<h1>THIS IS MORE OF THE BODY FOR THE pdf test</h1>")
    report.add_to_body(html)
    report.close
    pdf = report.pdf
    html = report.html
  #write_text_file_2(html, sub_dir, "wicked_core_report.txt")
    expected = read_text_file_2(sub_dir, "wicked_core_report.txt")
    run_at_1 = extract_run_at(expected)
    run_at_2 = extract_run_at(html)
    html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    expect(html).to eq(expected)
    expect(pdf[0,4]).to eq('%PDF')
  end

end