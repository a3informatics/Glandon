require 'rails_helper'

describe "ISO Namespace JS", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UserAccountHelpers
  include UiHelpers

  before :all do
    schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
    load_files(schema_files, data_files)
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

    it "deletes namespace (REQ-MDR-NS-020)" do
      click_navbar_namespaces
      expect(page).to have_content 'New Scope Namespace'
      expect(page).to have_content 'Namespaces'
      fill_in 'iso_namespace_short_name', with: 'NEWORG'
      fill_in 'iso_namespace_name', with: 'New Organisation'
      fill_in 'iso_namespace_authority', with: 'www.example.com'
      click_on '+ New namespace'
      expect(page).to have_content 'Namespaces'
      expect(page).to have_content 'BBB Pharma'
      expect(page).to have_content 'AAA Long'
      expect(page).to have_content 'New Organisation'
      find(:xpath, "//tr[contains(.,'NEWORG')]/td/a", :text => 'Delete').click
      page.accept_alert
      sleep(1)
      expect(page).to have_content 'BBB Pharma'
      expect(page).to have_content 'AAA Long'
      expect(page).to have_no_content 'New Organisation'
    end

  end

end
