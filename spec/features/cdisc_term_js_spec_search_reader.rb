require 'rails_helper'

describe "CDISC Terminology", :type => :feature do
  
  include DataHelpers
  include UiHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  def sub_dir
    return "features"
  end

  def wait_for_ajax_long
    wait_for_ajax(15)
  end

  def wait_for_ajax_v_long
    wait_for_ajax(120)
  end

  def wait_for_ajax_short
    wait_for_ajax(7)
  end

  describe "Reader Search", :type => :feature do
      
    before :all do
      user = User.create :email => "reader@example.com", :password => "12345678" 
      user.add_role :reader
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")

      load_cdisc_term_versions(1..45)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    after :all do
      #Notepad.destroy_all
      user = User.where(:email => "reader@example.com").first
      user.destroy
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    it "allows a search to be performed (REQ-MDR-CT-060)", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'2015-09-25 Release')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: Controlled Terminology CT (V44.0.0, 44, Standard)'
      wait_for_ajax_v_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      #click_link 'Close'
      #expect(page).to have_content 'History: CDISC Terminology'
    end
    
    it "allows a search to be performed - another version (REQ-MDR-CT-060)", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'2015-12-18 Release')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: Controlled Terminology CT (V45.0.0, 45, Standard)'
      wait_for_ajax_v_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
    end
  end
end