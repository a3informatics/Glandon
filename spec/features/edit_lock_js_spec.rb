require 'rails_helper'
require 'selenium-webdriver'

describe "Edit Locks", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include FormHelpers
  include DomainHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_crf_test_1.ttl")
    load_test_file_into_triple_store("form_crf_test_2.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_dm.ttl")
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    @user1 = User.create :email => "form_edit@example.com", :password => "12345678" 
    @user1.add_role :curator
    @user2 = User.create :email => "domain_edit@example.com", :password => "12345678" 
    @user2.add_role :curator
    Token.destroy_all
  end

  after :each do
    click_link 'logoff_button'
  end

  after :all do
    Notepad.destroy_all
    user = User.where(:email => "form_edit@example.com").first
    user.destroy
  end

  describe "Curator User", :type => :feature do
  
    it "form edit timeout warnings and expiration", js: true do
      Token.set_timeout(@user1.edit_lock_warning.to_i + 10)
      load_form("CRF TEST 1") 
      wait_for_ajax
      expect(page).to have_content("Edit: CRF Test Form CRF TEST 1 (, V1, Incomplete)")
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_CRFTEST1")
      token = tokens[0]
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer')
      page.find("#token_timer")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user1.edit_lock_warning.to_i + 2
      page.find("#token_timer")[:class].include?("btn-warning")
      sleep (@user1.edit_lock_warning.to_i / 2)
      expect(page).to have_content("The edit lock is about to timeout!")
      sleep 5
      page.find("#token_timer")[:class].include?("btn-danger")
      sleep (@user1.edit_lock_warning.to_i / 2)
      expect(page).to have_content("00:00")
      expect(token.timed_out?).to eq(true)
    end

    it "form edit timeout warnings and extend", js: true do
      Token.set_timeout(@user1.edit_lock_warning.to_i + 10)
      load_form("CRF TEST 1") 
      wait_for_ajax
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_CRFTEST1")
      token = tokens[0]
      expect(page).to have_content("Edit: CRF Test Form CRF TEST 1 (, V1, Incomplete)")
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer')
      page.find("#token_timer")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user1.edit_lock_warning.to_i + 2
      page.find("#token_timer")[:class].include?("btn-warning")
      click_button 'Save'
      wait_for_ajax
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer')
      page.find("#token_timer")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user1.edit_lock_warning.to_i
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer')
      page.find("#token_timer")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep 11
      page.find("#token_timer")[:class].include?("btn-warning")
    end

    it "domain edit timeout warnings and expiration", js: true do
      Token.set_timeout(@user2.edit_lock_warning.to_i + 10)
      load_domain("DM Domain")
      expect(page).to have_content("Edit: Demographics DM Domain (, V1, Incomplete)")
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain")
      token = tokens[0]
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer')
      page.find("#token_timer")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user2.edit_lock_warning.to_i + 2
      page.find("#token_timer")[:class].include?("btn-warning")
      sleep (@user2.edit_lock_warning.to_i / 2)
      expect(page).to have_content("The edit lock is about to timeout!")
      sleep 5
      page.find("#token_timer")[:class].include?("btn-danger")
      sleep (@user2.edit_lock_warning.to_i / 2)
      expect(page).to have_content("00:00")
      expect(token.timed_out?).to eq(true)
    end

    it "form edit timeout warnings and extend", js: true do
      Token.set_timeout(@user2.edit_lock_warning.to_i + 10)
      load_domain("DM Domain")
      expect(page).to have_content("Edit: Demographics DM Domain (, V1, Incomplete)")
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain")
      token = tokens[0]
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer')
      page.find("#token_timer")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user2.edit_lock_warning.to_i + 2
      page.find("#token_timer")[:class].include?("btn-warning")
      click_button 'Save'
      wait_for_ajax
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer')
      page.find("#token_timer")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user2.edit_lock_warning.to_i
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer')
      page.find("#token_timer")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep 11
      page.find("#token_timer")[:class].include?("btn-warning")
    end

  end

end