require 'rails_helper'

describe "ISO Namespace JS", :type => :feature do
  
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

  describe "valid user", :type => :feature, js: true do

    it "deletes namespace" do
      click_link 'Namespaces'
      click_link 'New'
      expect(page).to have_content 'New Scope Namespace'
      fill_in 'iso_namespace_short_name', with: 'NEWORG'
      fill_in 'iso_namespace_name', with: 'New Organisation'
      fill_in 'iso_namespace_authority', with: 'www.example.com'
      click_button 'Submit'
      expect(page).to have_content 'Namespaces'
      expect(page).to have_content 'BBB Pharma'
      expect(page).to have_content 'AAA Long'
      expect(page).to have_content 'New Organisation'
    #pause
      find(:xpath, "//tr[contains(.,'NEWORG')]/td/a", :text => 'Delete').click
      page.accept_alert
      sleep(1)
      expect(page).to have_content 'BBB Pharma'
      expect(page).to have_content 'AAA Long'
      expect(page).to have_no_content 'New Organisation'
    end

  end

end