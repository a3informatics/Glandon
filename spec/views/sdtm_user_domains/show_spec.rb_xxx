require 'rails_helper'

describe 'sdtm_user_domains/show.html.erb', :type => :view do

  it 'displays the domain' do 

    bcs = []
    bc = BiomedicalConcept.new
    bc.scopedIdentifier.identifier = "BC_NO_1"
    bc.scopedIdentifier.semantic_version = "1.2.3"
    bc.scopedIdentifier.version = 112
    bc.scopedIdentifier.versionLabel = "Draft 1"
    bc.namespace = "http://www.example.com/bc"
    bc.id = "BC_NO_1"
    bcs << bc
    bc = BiomedicalConcept.new
    bc.scopedIdentifier.identifier = "BC_NO_2"
    bc.scopedIdentifier.semantic_version = "3.2.1"
    bc.scopedIdentifier.version = 211
    bc.scopedIdentifier.versionLabel = "Draft 2"
    bc.namespace = "http://www.example.com/bc"
    bc.id = "BC_NO_2"
    bcs << bc

    sdtm_user_domain = SdtmUserDomain.new
    sdtm_user_domain.scopedIdentifier.identifier = "D_1"
    sdtm_user_domain.scopedIdentifier.semantic_version = "4.0.0"
    sdtm_user_domain.scopedIdentifier.version = 16
    sdtm_user_domain.scopedIdentifier.versionLabel = "Whatevs"
    sdtm_user_domain.id = "XXXX"
    sdtm_user_domain.label = "A Domain"

    assign(:sdtm_user_domain, sdtm_user_domain)
    assign(:bcs, bcs)

    render
    
    expect(rendered).to have_content("Details")
    # @todo More tests required
    expect(rendered).to have_content("D_1")
    expect(rendered).to have_content("A Domain")
    #expect(rendered).to have_content("1.2.3")
    #expect(rendered).to have_content("3.2.1")
    #expect(rendered).to_not have_content("112")
    #expect(rendered).to_not have_content("211")
    #expect(rendered).to have_content("Draft 1")
    #expect(rendered).to have_content("Draft 2")
    
    expect(rendered).to have_content("Used Variables")
    # @todo More tests required
    
    expect(rendered).to have_content("Unused Variables")
    # @todo More tests required
    
    expect(rendered).to have_content("Biomedical Concepts")
    expect(rendered).to have_content("BC_NO_1")
    expect(rendered).to have_content("BC_NO_2")
    
    expect(rendered).to have_link 'Report'
    expect(rendered).to have_link 'BC+'
    expect(rendered).to have_link 'BC-'
    expect(rendered).to have_link 'Export JSON'
    expect(rendered).to have_link 'Export Turtle'
    expect(rendered).to have_link 'Export XPT'
  end

end