require 'rails_helper'

describe 'cdisc_terms/changes.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "views/cdisc_terms"
  end

  before :all do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = 
    [
      "iso_namespace_real.ttl", "iso_registration_authority_real.ttl",     
    ]
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
  end

  it 'displays the form, next and previous links' do 

    cls = read_yaml_file(sub_dir, "changes_cls.yaml")
    links = read_yaml_file(sub_dir, "changes_links_1.yaml")
    ct = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"), false)

    assign(:cls, cls)
    assign(:links, links)
    assign(:ct, ct)
    assign(:version_count, 4)

    render

  	#puts response.body

    expect(rendered).to have_content("Changes: CDISC Terminology")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(1)", text: 'Identifier')
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(2)", text: 'Label')
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(3)", text: "Submission")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(4)", text: "\u00A0")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(5)", text: "\u00A0")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(6)", text: "\u00A0")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(7)", text: "\u00A0")
    expect(rendered).to have_selector("table#changes thead tr:nth-of-type(1) th:nth-of-type(8)", text: '')

    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa1/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa2/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa3/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa4/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa5/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa6/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/history']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/#{ct.id}/changes_report.pdf']")
    
  end

  it 'displays the form, previous link only' do 

    cls = read_yaml_file(sub_dir, "changes_cls.yaml")
    links = read_yaml_file(sub_dir, "changes_links_2.yaml")
    ct = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"), false)

    assign(:cls, cls)
    assign(:links, links)
    assign(:ct, ct)
    assign(:version_count, 4)

    render

    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa1/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa2/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa3/changes' and @class='btn btn-primary']")
    ui_link_disabled("fb_fs_button")
    ui_link_disabled("fb_fm_button")
    ui_link_disabled("fb_end_button")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/history']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/#{ct.id}/changes_report.pdf']")
    
  end

  it 'displays the form, next link only' do 

    cls = read_yaml_file(sub_dir, "changes_cls.yaml")
    links = read_yaml_file(sub_dir, "changes_links_3.yaml")
    ct = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"), false)

    assign(:cls, cls)
    assign(:links, links)
    assign(:ct, ct)
    assign(:version_count, 4)

    render

  	#puts response.body

    ui_link_disabled("fb_start_button")
    ui_link_disabled("fb_bs_button")
    ui_link_disabled("fb_bm_button")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa4/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa5/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa6/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/history']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/#{ct.id}/changes_report.pdf']")
    
  end

end