require 'rails_helper'

describe 'iso_registration_authorities/new.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  before :all do
    schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
    load_files(schema_files, data_files)
  end

  it 'displays the form' do

    ra = IsoRegistrationAuthority.new
    ns = IsoNamespace.all.map{|u| [u.name, u.id]}
    assign(:registrationAuthority, ra)
    assign(:namespaces, ns)

    render

  #puts rendered

    expect(rendered).to have_content("New Registration Authority")
    expect(rendered).to have_content("DUNS Number:")
    expect(rendered).to have_content("Scope Namespace:")
    expect(rendered).to have_select 'iso_registration_authority[namespace_id]', options: ["AAA Long", "BBB Pharma"]

    expect(rendered).to have_button 'Submit'
    expect(rendered).to have_link 'Close'

  end

end
