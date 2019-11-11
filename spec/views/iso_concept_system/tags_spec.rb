require 'rails_helper'

describe 'iso_concept_systems/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl"]
    load_files(schema_files, data_files)
  end

  it 'displays the basic page' do

    assign(:concept_system, IsoConceptSystem.root)

    render

  #puts response.body

    expect(rendered).to have_content("Tag Viewer")
    expect(rendered).to have_content("Tags")
    expect(rendered).to have_content("Manage Tags")
    expect(rendered).to have_content "Item List"
    expect(rendered).to have_xpath("//table[@id = 'iso_managed_table']")
    expect(rendered).to have_xpath("//div[@id = 'd3']")
  end

end
