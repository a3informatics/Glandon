require 'rails_helper'

describe "ISO Registration Authority", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UserAccountHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")  
    ua_create
  end 

  after :all do
    ua_destroy
  end 

  before :each do
    ua_content_admin_login
  end

  after :each do
    ua_logoff
  end

  describe "View", :type => :feature do
  
    it "allows all registration authorities to be viewed" do
      click_link 'Registration Authorities'
      expect(page).to have_content 'Registration Authorities'
      expect(page).to have_content '123456789'
      expect(page).to have_content '111111111'      
    end

    it "allows a new namespace to be added" do
      click_link 'Registration Authorities'
      expect(page).to have_content 'Registration Authorities'
      click_link 'New'
      expect(page).to have_content 'Registration Authority'
      fill_in 'DUNS Number', with: '111122223'
      select 'AAA Long', from: "iso_registration_authority_namespace_id"
      click_button 'Submit'
      expect(page).to have_content 'Registration Authorities'
      expect(page).to have_content '111122223'   
    end

  end

end