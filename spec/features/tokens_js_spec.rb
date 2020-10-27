require 'rails_helper'

describe "Tokens", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "form_example_vs_baseline.ttl"]
    load_files(schema_files, data_files)
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    Token.delete_all
    Token.set_timeout(60)
    @user1 = ua_add_user email: "token@example.com", role: :reader
    item1 = Thesaurus.create({:identifier => "TEST 1", :label => "Test Thesaurus 1"})
    item2 = Thesaurus.create({:identifier => "TEST 2", :label => "Test Thesaurus 2"})
    item3 = Thesaurus.create({:identifier => "TEST 3", :label => "Test Thesaurus 3"})
    item4 = Thesaurus.create({:identifier => "TEST 4", :label => "Test Thesaurus 4"})
    token1 = Token.obtain(item1, @user1)
    token2 = Token.obtain(item2, @user1)
    token3 = Token.obtain(item3, @user1)
    token4 = Token.obtain(item4, @user1)
    ua_create
  end

  after :all do
    ua_remove_user "token@example.com"
    Token.restore_timeout
    ua_destroy
  end

  before :each do
    ua_sys_admin_login
  end

  after :each do
    ua_logoff
  end

  describe "System Admin User", :type => :feature do

    it "allows the tokens to be viewed (REQ-MDR-EL-050)", js: true do
      click_navbar_el
      expect(page).to have_content 'Active Edit Locks'
      expect(page).to have_content 'View and manage Edit Locks (Tokens)'
    end

    it "allows a lock to be released (REQ-MDR-EL-050)", js: true do
      click_navbar_el
      expect(page).to have_content 'Active Edit Locks'
      expect(page.all('table#main tr').count).to eq(5)
      find(:xpath, "//tr[contains(.,'http://www.acme-pharma.com/TEST_2/V1#TH')]/td/button", :text => 'Release').click
      ui_confirmation_dialog true
      wait_for_ajax 10

      expect(page.all('table#main tr').count).to eq(4)
      expect(page).to have_content "http://www.acme-pharma.com/TEST_1/V1#TH"
      expect(page).to have_content "http://www.acme-pharma.com/TEST_3/V1#TH"
      expect(page).to have_content "http://www.acme-pharma.com/TEST_4/V1#TH"
    end

    it "allows a lock to be released, rejection (REQ-MDR-EL-050)", js: true do
      click_navbar_el
      expect(page).to have_content 'Active Edit Locks'
      find(:xpath, "//tr[contains(.,'http://www.acme-pharma.com/TEST_3/V1#TH')]/td/button", :text => 'Release').click
      ui_confirmation_dialog false
    end

  end

end
