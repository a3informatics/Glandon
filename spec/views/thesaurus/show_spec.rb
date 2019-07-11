require 'rails_helper'

describe 'thesauri/show.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "views/thesaurus"
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

  it 'displays the panels' do 

    ct = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"), false)

    assign(:ct, ct)
    assign(:close_path, history_cdisc_terms_path)

    render

  	#puts response.body

    expect(rendered).to have_content("Show: Controlled Terminology CT (V1.0.0, 1, Standard)")

    expect(rendered).to have_selector("table#header_table thead tr:nth-of-type(1) th:nth-of-type(1)", text: 'Identifier')
    expect(rendered).to have_selector("table#header_table thead tr:nth-of-type(1) th:nth-of-type(2)", text: 'Label')
    expect(rendered).to have_selector("table#header_table thead tr:nth-of-type(1) th:nth-of-type(3)", text: "Owner")
    expect(rendered).to have_selector("table#header_table thead tr:nth-of-type(1) th:nth-of-type(4)", text: "Status")
    expect(rendered).to have_selector("table#header_table thead tr:nth-of-type(1) th:nth-of-type(5)", text: "Version")
    expect(rendered).to have_selector("table#header_table thead tr:nth-of-type(1) th:nth-of-type(6)", text: "Version Label")

    expect(rendered).to have_selector("table#children_table thead tr:nth-of-type(1) th:nth-of-type(1)", text: 'Identifier')
    expect(rendered).to have_selector("table#children_table thead tr:nth-of-type(1) th:nth-of-type(2)", text: 'Submission Value')
    expect(rendered).to have_selector("table#children_table thead tr:nth-of-type(1) th:nth-of-type(3)", text: 'Preferred Term')
    expect(rendered).to have_selector("table#children_table thead tr:nth-of-type(1) th:nth-of-type(4)", text: 'Synonym(s)')
    expect(rendered).to have_selector("table#children_table thead tr:nth-of-type(1) th:nth-of-type(5)", text: 'Extensible')
    expect(rendered).to have_selector("table#children_table thead tr:nth-of-type(1) th:nth-of-type(6)", text: 'Definition')
    
    expect(rendered).to have_xpath("//a[@href = '/cdisc_terms/history']")
    expect(rendered).to have_xpath("//a[@href = '/thesauri/#{ct.id}/export_csv']")
    
  end

end