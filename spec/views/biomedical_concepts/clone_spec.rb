require 'rails_helper'

describe 'biomedical_concepts/new.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it 'displays the form' do

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

    render
    expect(rendered).to have_content("New: Biomedical Concept")
    expect(rendered).to have_content("Identifier:")
    expect(rendered).to have_content("Label:")
    expect(rendered).to have_content("Template:")

  end

end
