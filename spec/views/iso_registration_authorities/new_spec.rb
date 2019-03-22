require 'rails_helper'

describe 'iso_registration_authorities/new.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
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