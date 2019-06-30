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
  
  end

  it 'displays the form, next and previous links' do 

    cls = read_yaml_file(sub_dir, "changes_cls.yaml")
    links = read_yaml_file(sub_dir, "changes_links_1.yaml")

    assign(:cls, cls)
		assign(:links, links)

    render

  	#puts response.body

    expect(rendered).to have_content("Changes: CDISC Terminology")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: 'C49499')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'Action Taken with Study Treatment')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: "ACN")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(6)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(7)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(8)", text: 'Changes')

    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa1/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa2/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa3/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa4/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa5/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa6/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/history']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/changes_report.pdf']")
    
  end

  it 'displays the form, previous link only' do 

    cls = read_yaml_file(sub_dir, "changes_cls.yaml")
    links = read_yaml_file(sub_dir, "changes_links_2.yaml")

    assign(:cls, cls)
    assign(:links, links)

    render

    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa1/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa2/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa3/changes' and @class='btn btn-primary']")
    ui_link_disabled("fb_fs_button")
    ui_link_disabled("fb_fm_button")
    ui_link_disabled("fb_end_button")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/history']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/changes_report.pdf']")
    
  end

    it 'displays the form, next link only' do 

    cls = read_yaml_file(sub_dir, "changes_cls.yaml")
    links = read_yaml_file(sub_dir, "changes_links_3.yaml")

    assign(:cls, cls)
    assign(:links, links)

    render

  	#puts response.body

    ui_link_disabled("fb_start_button")
    ui_link_disabled("fb_bs_button")
    ui_link_disabled("fb_bm_button")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa4/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa5/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/aaa6/changes' and @class='btn btn-primary']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/history']")
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/changes_report.pdf']")
    
  end

end