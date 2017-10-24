require 'rails_helper'

describe "ISO Managed JS", :type => :feature do
  
  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include UserAccountHelpers
  
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
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    clear_iso_concept_object
  end

  after :all do
    user = User.where(:email => "curator@example.com").first
    user.destroy
  end

  describe "Curator User", :type => :feature do

    it "allows the metadata graph to be viewed", js: true do
      ua_curator_login
      click_link 'Biomedical Concepts'
      #pause
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC A00003')]/td/a", :text => 'History').click
      #pause
      expect(page).to have_content 'History: BC A00003'
      find(:xpath, "//tr[contains(.,'BC A00003')]/td/a", :text => 'Gr-').click
      expect(page).to have_content 'Graph:'
      expect(page).to have_button('graph_focus', disabled: true)
      expect(page).to have_field('concept_type', disabled: true)
      expect(page).to have_field('concept_label', disabled: true)
      click_button 'graph_stop'
      expect(page).to have_button('graph_focus', disabled: false)
      ua_logoff
    end

    it "allows a impact page to be displayed", js: true do
    	ua_curator_login
      click_link 'Biomedical Concepts'
      ui_check_page_has('Index: Biomedical Concepts')
      ui_table_row_link_click('BC C25347', 'History')
      ui_check_page_has('History: BC C25347')
      ui_table_row_link_click('BC C25347', 'Show')
      ui_check_page_has('Show: Height (BC C25347)')
      ui_table_row_link_click('BC C25347', 'Impact')
      ui_check_page_has('Impact Analysis: Height (BC C25347)')
      wait_for_ajax(10)
    #pause
      ui_check_table_row('managed_item_table', 1, ["BC C25347", "Height (BC C25347)", "1.0.0", "0.1"])
      ui_check_table_row('managed_item_table', 2, ["VS BASELINE", "Vital Signs Baseline", "0.0.0", ""])
      click_button 'close'
      ui_check_page_has('Show: Height (BC C25347)')
      ui_table_row_link_click('BC C25347', 'Impact')
      ui_check_page_has('Impact Analysis: Height (BC C25347)')
    #pause
      #ui_table_row_link_click('VS BASELINE', 'Show')
      #ui_check_page_has("Show: Vital Signs Baseline")
      ua_logoff
    end

    it "allows the show of an impact item, see above"

    it "allows a impact graph to be clicked"

    it "allows the comments to be updated", js: true do
      ua_curator_login
      click_link 'Forms'
      expect(page).to have_content 'Index: Forms'
      #pause
      find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'History').click
      #pause
      find(:xpath, "//table[@id='secondary']/tbody/tr/td/a", :text => 'Edit').click
      expect(page).to have_content 'Comments:'
      #pause
      fill_in "iso_managed_changeDescription", with: "Hello world. This is a change description"
      click_button "Preview"
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("Hello world. This is a change description")
      fill_in "iso_managed_explanatoryComment", with: "I am a comment"
      click_button "Preview"
      #pause
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("I am a comment")
      fill_in "iso_managed_origin", with: "I am the origin"
      click_button "Preview"
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("I am the origin")
      fill_in "iso_managed_origin", with: "£±£±"
      expect(page).to have_content 'Please enter valid markdown.'
      #pause
      ui_set_focus("iso_managed_explanatoryComment")
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("I am a comment")
      ui_set_focus("iso_managed_changeDescription")
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("Hello world. This is a change description")
      fill_in "iso_managed_origin", with: "Origin"
      click_button 'Submit'
      expect(page).to have_content 'Hello world. This is a change description'   
      expect(page).to have_content 'I am a comment'   
      expect(page).to have_content 'Origin'   
      ua_logoff
    end

    it "allows the comments to be updated, cdisc term", js: true do
      ua_curator_login
      click_link 'Terminology'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-09-25')]/td/a", :text => 'History').click
      find(:xpath, "//table[@id='secondary']/tbody/tr/td/a", :text => 'Edit').click
      expect(page).to have_content 'Comments:'
      fill_in "iso_managed_changeDescription", with: "Hello world. This is a change description."
      fill_in "iso_managed_explanatoryComment", with: "I am a comment"
      fill_in "iso_managed_origin", with: "I am the origin"
      click_button 'Submit'
      expect(page).to have_content 'Hello world. This is a change description.'   
      expect(page).to have_content 'I am a comment'   
      expect(page).to have_content 'I am the origin'   
      ua_logoff
    end

    it "allows the status to be updated", js: true do
      ua_curator_login
      click_link 'Forms'
      expect(page).to have_content 'Index: Forms'
      #pause
      find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'History').click
      #pause
      find(:xpath, "//table[@id='main']/tbody/tr/td/a", :text => 'Status').click
      expect(page).to have_content 'Status:'
      #pause
      fill_in "iso_scoped_identifier_versionLabel", with: "£±£±"
      click_button "version_submit"
      expect(page).to have_content "Versionlabel contains invalid characters"
      fill_in "iso_scoped_identifier_versionLabel", with: "Draft 1"
      click_button "version_submit"
      ui_check_input("iso_scoped_identifier_versionLabel", "Draft 1")
      #expect(page).to have_content "Draft 1"
      #pause      
      fill_in "iso_registration_state_administrativeNote", with: "£££££££££"
      fill_in "iso_registration_state_unresolvedIssue", with: "Draft 1"
      click_button "state_submit"
      expect(page).to have_content "Administrativenote contains invalid characters"
      fill_in "iso_registration_state_administrativeNote", with: "Good text"
      fill_in "iso_registration_state_unresolvedIssue", with: "±§"
      click_button "state_submit"
      expect(page).to have_content "Unresolvedissue contains invalid characters"
      fill_in "iso_registration_state_administrativeNote", with: "Good text"
      fill_in "iso_registration_state_unresolvedIssue", with: "Very good text"
      click_button "state_submit"
      #pause
      expect(page).to have_content "Current Status: Superseded"
      ua_logoff
    end

    it "allows the status to be updated, handles standard version", js: true do
      ua_curator_login
      click_link 'Forms'
      expect(page).to have_content 'Index: Forms'
      click_link 'New'
      expect(page).to have_content 'New Form:'
      fill_in 'form[identifier]', with: 'A NEW FORM'
      fill_in 'form[label]', with: 'Test New Form'
      click_button 'Create'
      expect(page).to have_content 'Index: Forms'
      expect(page).to have_content 'Test New Form'
      find(:xpath, "//tr[contains(.,'A NEW FORM')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: A NEW FORM'
      find(:xpath, "//tr[contains(.,'A NEW FORM')]/td/a", :text => 'Status').click
      ui_check_table_row("version_info", 1, ["Version:", "0.1.0"])
      ui_check_table_row("version_info", 2, ["Version Label:", ""])
      ui_check_table_row("version_info", 3, ["Internal Version:", "1"])
      fill_in "iso_scoped_identifier_versionLabel", with: "Draft Form"
      click_button "version_submit"
      ui_check_input("iso_scoped_identifier_versionLabel", "Draft Form")
      expect(page).to have_content("Current Status: Incomplete")
      click_button "state_submit"
      expect(page).to have_content("Current Status: Candidate")
      click_button "state_submit"
      expect(page).to have_content("Current Status: Recorded")
      click_button "state_submit"
      expect(page).to have_content("Current Status: Qualified")
      ui_check_table_row("version_info", 1, ["Version:", "0.1.0"])
      click_button "state_submit"
      expect(page).to have_content("Current Status: Standard")
      ui_check_table_row("version_info", 1, ["Version:", "1.0.0"])
      ui_check_table_row("version_info", 2, ["Version Label:", "Draft Form"])
      ui_check_table_row("version_info", 3, ["Internal Version:", "1"])
      ua_logoff
    end

  end

end