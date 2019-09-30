require 'rails_helper'

describe "ISO Registration Authority JS", :type => :feature do

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

    it "deletes registration authority (REQ-MDR-RA-020)" do
      click_navbar_regauthorities
      expect(page).to have_content 'Registration Authorities'
      find(:xpath, "//tr[contains(.,'111111111')]/td/a", :text => 'Delete').click
      page.accept_alert
      sleep(1)
      expect(page).to have_content '123456789'
      expect(page).to have_no_content '111111111'
    end

  end

end
