require 'rails_helper'

describe 'iso_managed/status.html.erb', :type => :view do

  it 'displays the version info' do 

    mi = BiomedicalConcept.new
    mi.scopedIdentifier.identifier = "X"
    mi.scopedIdentifier.semantic_version = "1.2.3"
    mi.scopedIdentifier.version = 112
    mi.scopedIdentifier.versionLabel = "Draft 1"
    assign(:managed_item, mi)

    rs = mi.registrationState
    rs.registrationStatus = "Candidate"
    rs.id = "YYY"
    assign(:registration_state, rs)

    si = IsoScopedIdentifier.new
    si.id = "XXX"
    assign(:scoped_identifier, si)

    render
    expect(rendered).to have_content("Version:1.2.3")
    expect(rendered).to have_content("Internal Version:112")
    expect(rendered).to have_content("Version Label:Draft 1")

  end

end