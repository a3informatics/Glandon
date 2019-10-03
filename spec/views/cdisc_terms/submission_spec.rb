require 'rails_helper'

describe 'thesauri/submission.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "views/thesauri"
  end

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl",
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)
  end

  it 'displays the view, next and previous links' do

    cls = read_yaml_file(sub_dir, "submission_cls.yaml")
    links = read_yaml_file(sub_dir, "submission_links_1.yaml")
    ct = CdiscTerm.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V1#TH"))

    assign(:cls, cls)
		assign(:links, links)
    assign(:ct, ct)
    assign(:version_count, 4)

    render

  	expect(rendered).to have_content("Submission value changes")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(1)", text: 'Identifier')
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(2)", text: 'Label')
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(3)", text: "Submission Value")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(4)", text: "\u00A0")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(5)", text: "\u00A0")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(6)", text: "\u00A0")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(7)", text: "\u00A0")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(8)", text: '')

    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa1/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa2/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa3/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa4/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa5/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa6/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = 'javascript: history.back()']")
    expect(rendered).to have_xpath("//a[@href = '#']/span[@class='ico-btn-sec-text' and contains(.,'PDF Report')]")

  end

  it 'displays the view, previous link only' do

    cls = read_yaml_file(sub_dir, "submission_cls.yaml")
    links = read_yaml_file(sub_dir, "submission_links_2.yaml")
    ct = CdiscTerm.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V1#TH"))

    assign(:cls, cls)
    assign(:links, links)
    assign(:ct, ct)
    assign(:version_count, 4)

    render

    #puts response.body

    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa1/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa2/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa3/submission' and @class='btn medium nomargin ttip']")
    ui_link_disabled("fb_fs_button")
    ui_link_disabled("fb_fm_button")
    ui_link_disabled("fb_end_button")
    expect(rendered).to have_xpath("//a[@href = 'javascript: history.back()']")
    expect(rendered).to have_xpath("//a[@href = '#']/span[@class='ico-btn-sec-text' and contains(.,'PDF Report')]")

  end

  it 'displays the view, next link only' do

    cls = read_yaml_file(sub_dir, "submission_cls.yaml")
    links = read_yaml_file(sub_dir, "submission_links_3.yaml")
    ct = CdiscTerm.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V1#TH"))

    assign(:cls, cls)
    assign(:links, links)
    assign(:ct, ct)
    assign(:version_count, 4)

    render

  	#puts response.body

    ui_link_disabled("fb_start_button")
    ui_link_disabled("fb_bs_button")
    ui_link_disabled("fb_bm_button")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa4/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa5/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa6/submission' and @class='btn medium nomargin ttip']")
    expect(rendered).to have_xpath("//a[@href = 'javascript: history.back()']")
    expect(rendered).to have_xpath("//a[@href = '#']/span[@class='ico-btn-sec-text' and contains(.,'PDF Report')]")

  end

end
