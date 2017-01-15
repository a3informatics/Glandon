require 'rails_helper'

describe "CDISC Terminology", :type => :feature do
  
  include DataHelpers
  include UiHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  def sub_dir
    return "features"
  end

  describe "Curator Search", :type => :feature do
  
    before :all do
      user = User.create :email => "curator@example.com", :password => "12345678" 
      user.add_role :curator
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
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    after :all do
      Notepad.destroy_all
      user = User.where(:email => "curator@example.com").first
      user.destroy
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    it "allows a search to be performed", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-09-25')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Terminology 2015-09-25'
      wait_for_ajax(120) # Big load
      expect(page).to have_content '16,902 entries'
      expect(page).not_to have_button('notepadAdd')
      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end
    
    it "allows a search to be performed", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-12-18')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Terminology 2015-12-18'
      wait_for_ajax(120) # Big load
      expect(page).to have_content '17,355 entries'
      expect(page).to have_button('Notepad+')
      ui_click_by_id('notepadAdd')
      expect(page).to have_content 'You need to select an item.'
      ui_table_row_click('search2Table', "QSCAT")
      ui_click_by_id('notepadAdd')
      wait_for_ajax
      expect(page).to have_content 'You need to select an item not a code list.'
      ui_table_row_click('search2Table', "C100759")
      ui_click_by_id('notepadAdd')
      wait_for_ajax
      expect(page).to have_content 'Notepad+ 1'
      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end

  end

  describe "Reader Search", :type => :feature do
  
    before :all do
      user = User.create :email => "reader@example.com", :password => "12345678" 
      user.add_role :reader
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
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    after :all do
      Notepad.destroy_all
      user = User.where(:email => "reader@example.com").first
      user.destroy
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    it "allows a search to be performed", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-09-25')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Terminology 2015-09-25'
      wait_for_ajax(120) # Big load
      expect(page).to have_content '16,902 entries'
      expect(page).not_to have_button('notepadAdd')
      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end
    
    it "allows a search to be performed", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-12-18')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Terminology 2015-12-18'
      wait_for_ajax(120) # Big load
      expect(page).to have_content '17,355 entries'
      expect(page).not_to have_button('Notepad+')
      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end

  end
end