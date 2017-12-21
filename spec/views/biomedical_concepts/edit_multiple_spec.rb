require 'rails_helper'

describe 'biomedical_concepts/edit_multiple.html.erb', :type => :view do

  include UiHelpers

  login_curator

  it 'displays the form' do

    bcts = []
    bct = BiomedicalConceptTemplate.new
    bct.scopedIdentifier.identifier = "X"
    bcts << bct
    bct = BiomedicalConceptTemplate.new
    bct.id = "ACME_2" 
    bct.namespace = "http://example.com/bct" 
    bct.scopedIdentifier.identifier = "Y"
    bcts << bct
    assign(:bcts, bcts)

    assign(:close_path, biomedical_concepts_path)

    render
    expect(rendered).to have_content("Edit Multiple Biomedical Concepts")
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