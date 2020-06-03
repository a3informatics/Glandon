require 'rails_helper'

describe 'biomedical_concepts/edit.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers

  login_curator

  it 'displays the form' do  

    bc = BiomedicalConcept.new
    bc.id = "ACME_1"
    bc.namespace = "http://www.example.com/bcs"
    bc.label = "hello"
    bc.scopedIdentifier.identifier = "X"
    bc.scopedIdentifier.semantic_version = "1.0.0"
    bc.scopedIdentifier.version = "10"
    bc.registrationState.registrationStatus = "Very New"
    assign(:bc, bc)

    bcts = []
    bct = BiomedicalConceptTemplate.new
    bct.id = "ACME_1" 
    bct.namespace = "http://example.com/bct" 
    bct.scopedIdentifier.identifier = "X"
    bcts << bct
    bct = BiomedicalConceptTemplate.new
    bct.id = "ACME_2" 
    bct.namespace = "http://example.com/bct" 
    bct.scopedIdentifier.identifier = "Y"
    bcts << bct
    assign(:bcts, bcts)

    token = Token.new
    assign(:token, token)

    assign(:close_path, biomedical_concepts_path)

    render
    expect(rendered).to have_content("Edit: hello X (V1.0.0, 10, Very New)")
    expect(rendered).to have_content("All Biomedical Concepts")
    expect(rendered).to have_content("Current Biomedical Concept")
    expect(rendered).to have_content("Current Terminologies")
    expect(rendered).to have_content("Terminology")
    expect(rendered).to have_content("New")
    expect(rendered).to have_content("Identifier:")
    expect(rendered).to have_content("Label:")
    expect(rendered).to have_content("Template Identifier:")
    expect(rendered).to have_content("Add Biomedical Concept")

  end

end