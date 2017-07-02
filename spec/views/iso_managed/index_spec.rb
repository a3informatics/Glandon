require 'rails_helper'

describe 'iso_managed/index.html.erb' do

  include UiHelpers

  it 'displays items correctly' do
    
    x = 
    	[
			  {
			    id: "BCT-Obs_CD",
			    namespace: "http://www.assero.co.uk/MDRBCTs/V1",
			    label: "Simple Observation CD Biomedical Research Concept Template",
			    identifier: "Obs CD",
			    semantic_version: "1.0.0",
			    status: "Standard",
			    owner: "A"
			  },
			  {
			    id: "BCT-Obs_PQR",
			    namespace: "http://www.assero.co.uk/MDRBCTs/V1",
			    label: "Simple Observation PQR Biomedical Research Concept Template",
			    identifier: "Obs PQR",
			    semantic_version: "1.0.0",
			    status: "Standard",
			    owner: "B"
			  },
			  {
			    id: "TH-CDISC_CDISCTerminology",
			    namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42",
			    label: "CDISC Terminology 2015-09-25",
			    identifier: "CDISC Terminology",
			    semantic_version: "42.0.0",
			    status: "Standard",
			    owner: "C"
			  }
			]
    assign(:managed_items, x)

    render
    expect(rendered).to have_content("Index: Managed Items")
    #ui_check_breadcrumb("Background", "", "", "")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: 'Obs CD')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'Simple Observation CD Biomedical Research Concept Template')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: '1.0.0')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: 'Standard')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: 'A')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(6)", text: 'Delete')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: 'Obs PQR')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'Simple Observation PQR Biomedical Research Concept Template')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: '1.0.0')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(4)", text: 'Standard')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(5)", text: 'B')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(6)", text: 'Delete')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(1)", text: 'CDISC Terminology')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(2)", text: 'CDISC Terminology 2015-09-25')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(3)", text: '42.0.0')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(4)", text: 'Standard')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(5)", text: 'C')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(6)", text: 'Delete')
		
  end

end