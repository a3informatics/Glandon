require 'rails_helper'

describe 'iso_registration_authorities/index.html.erb', :type => :view do

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

    ras = IsoRegistrationAuthority.all
    ras.each {|ra| ra.ra_namespace_objects}
    
    assign(:registrationAuthorities, ras)
    assign(:owner, IsoRegistrationAuthority.owner)

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

    expect(rendered).to have_link 'New'
    expect(rendered).to have_link 'Close'

  end

end