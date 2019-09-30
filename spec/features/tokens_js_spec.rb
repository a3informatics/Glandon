require 'rails_helper'

describe "Tokens", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
      "BusinessOperational.ttl", "BusinessForm.ttl", "CDISCBiomedicalConcept.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "form_example_vs_baseline.ttl"]
    load_files(schema_files, data_files)
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    Token.delete_all
    Token.set_timeout(60)
    @user1 = ua_add_user email: "token@example.com", role: :reader
    @user2 = ua_add_user email: "admin_user@example.com", role: :sys_admin
    item1 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item1.id = "1"
    item2 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item2.id = "2"
    item3 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item3.id = "3"
    item4 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item4.id = "4"
    token1 = Token.obtain(item1, @user1)
    token2 = Token.obtain(item2, @user1)
    token3 = Token.obtain(item3, @user1)
    token4 = Token.obtain(item4, @user1)
  end

  after :all do
    ua_remove_user "token@example.com"
    ua_remove_user "admin_user@example.com"
    Token.restore_timeout
  end

  before :each do
    #
  end

  describe "System Admin User", :type => :feature do

    it "allows the tokens to be viewed", js: true do
      ua_generic_login 'admin_user@example.com'
      click_navbar_el
      expect(page).to have_content 'Index: Edit Locks'
    end

    it "allows a lock to be released", js: true do
      ua_generic_login 'admin_user@example.com'
      click_navbar_el
      expect(page).to have_content 'Index: Edit Locks'
      expect(page.all('table#main tr').count).to eq(5)
      find(:xpath, "//tr[contains(.,'http://www.assero.co.uk/MDRForms/ACME/V1#2')]/td/a", :text => 'Release').click
      ui_click_ok("Are you sure?")
      expect(page.all('table#main tr').count).to eq(4)
      expect(page).to have_content "http://www.assero.co.uk/MDRForms/ACME/V1#1"
      expect(page).to have_content "http://www.assero.co.uk/MDRForms/ACME/V1#3"
      expect(page).to have_content "http://www.assero.co.uk/MDRForms/ACME/V1#4"
    end

    it "allows a lock to be released, rejection", js: true do
      ua_generic_login 'admin_user@example.com'
      click_navbar_el
      expect(page).to have_content 'Index: Edit Locks'
      find(:xpath, "//tr[contains(.,'http://www.assero.co.uk/MDRForms/ACME/V1#3')]/td/a", :text => 'Release').click
      ui_click_cancel("Are you sure?")
    end

  end

end
