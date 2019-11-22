require 'rails_helper'

describe 'iso_registration_authorities/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  before :all do
    schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
    load_files(schema_files, data_files)
  end

  it 'displays the form' do
    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(new?: true)
    ras = IsoRegistrationAuthority.all
    ras.each {|ra| ra.ra_namespace_objects}
    namespaces = IsoNamespace.all.map{|u| [u.name, u.id]}

    assign(:registrationAuthorities, ras)
    assign(:owner, IsoRegistrationAuthority.owner)
    assign(:namespaces, namespaces)

    render

  #puts rendered

    expect(rendered).to have_content("Registration Authorities")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '123456789')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'DUNS')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'BBB Pharma')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: 'BBB')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(6)", text: 'Delete')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: '111111111')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'DUNS')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'AAA Long')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(4)", text: 'AAA')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(6)", text: 'Delete')

    expect(rendered).to have_content("New Registration Authority")
    expect(rendered).to have_content("DUNS Number:")
    expect(rendered).to have_content("Scope Namespace:")
    expect(rendered).to have_select 'iso_registration_authority[namespace_id]', options: ["AAA Long", "BBB Pharma"]
    expect(rendered).to have_button '+ New Registration Authority'

  end

end
