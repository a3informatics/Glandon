require 'rails_helper'

describe "Thesaurus", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper

  describe "Curator User", :type => :feature do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("thesaurus_concept.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("CT_ACME_TEST.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      user = User.create :email => "curator@example.com", :password => "12345678" 
      user.add_role :curator
      Token.set_timeout(30)
    end

    after :all do
      user = User.where(:email => "curator@example.com").first
      user.destroy
    end
  
    it "allows a thesaurus to be viewed, sponsor", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'View').click
      expect(page).to have_content 'View: CDISC Extensions CDISC EXT (0.1, V1, Standard)'
      expect(page).to have_content 'Thesauri Details'
      ui_check_anon_table_row(1, ["Label:", "CDISC Extensions"])
      ui_check_anon_table_row(2, ["Identifier:", "CDISC EXT"])
      ui_check_anon_table_row(3, ["Version Label:", "0.1"])
      ui_check_anon_table_row(4, ["Version:", "1"])
      key1 = ui_get_key_by_path('["CDISC Extensions", "Placeholder for Ethnic Subgroup"]')      
      ui_click_node_key(key1)
      wait_for_ajax
      ui_check_td_with_id("conceptLabel", "Placeholder for Ethnic Subgroup")
      ui_check_td_with_id("conceptId", "A00010")
      ui_double_click_node_key(key1)
      wait_for_ajax
      key2 = ui_get_key_by_path('["CDISC Extensions", "Placeholder for Ethnic Subgroup", "Ethnic Subgroup 1"]')      
      ui_click_node_key(key2)
      ui_check_td_with_id("conceptLabel", "Ethnic Subgroup 1")
      ui_check_td_with_id("conceptId", "A00011")
      ui_check_td_with_id("conceptNotation", "ETHNIC SUBGROUP [1]")
      ui_click_node_key(key1)
      wait_for_ajax
      ui_check_td_with_id("conceptLabel", "Placeholder for Ethnic Subgroup")
      ui_check_td_with_id("conceptId", "A00010")
    end
    
    it "allows a thesaurus to be viewed, CDISC", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-12-18')]/td/a", :text => 'View').click
      expect(page).to have_content 'View: CDISC Terminology 2015-12-18 CDISC Terminology (2015-12-18, V43, Standard)'
      expect(page).to have_content 'Thesauri Details'
      ui_check_anon_table_row(1, ["Label:", "CDISC Terminology 2015-12-18"])
      ui_check_anon_table_row(2, ["Identifier:", "CDISC Terminology"])
      ui_check_anon_table_row(3, ["Version Label:", "2015-12-18"])
      ui_check_anon_table_row(4, ["Version:", "43"])
      key1 = ui_get_key_by_path('["CDISC Terminology 2015-12-18", "Sex"]')      
      ui_click_node_key(key1)
      wait_for_ajax
      ui_check_td_with_id("conceptLabel", "Sex")
      ui_check_td_with_id("conceptId", "C66731")
      ui_check_td_with_id("conceptNotation", "SEX")
      ui_double_click_node_key(key1)
      wait_for_ajax
      key2 = ui_get_key_by_path('["CDISC Terminology 2015-12-18", "Sex", "Male"]')      
      ui_click_node_key(key2)
      ui_check_td_with_id("conceptLabel", "Male")
      ui_check_td_with_id("conceptId", "C20197")
      ui_check_td_with_id("conceptNotation", "M")
    end

    it "allows terminology to be edited", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (0.1, V2, Incomplete)' # Note up version
      fill_in 'Identifier', with: 'A00030'
      click_button 'New'
      expect(page).to have_content 'A00030' # Note up version
      find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[2]").click
      fill_in "DTE_Field_label", with: "Label text\t"
      fill_in "DTE_Field_notation", with: "SUBMISSION\t"
      fill_in "DTE_Field_preferredTerm", with: "The PT\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[5]").click
      fill_in "DTE_Field_synonym", with: "Same as A; B\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[6]").click
      fill_in "DTE_Field_definition", with: "We never fill this in, too tricky!\n"
      find(:xpath, "//tr[contains(.,'Same as A; B')]/td/button", :text => 'Edit').click
      expect(page).to have_content 'Edit: Label text A00030'
      fill_in 'Identifier', with: 'A00031'
      #pause
      click_button 'New'
      expect(page).to have_content 'A00031'
      find(:xpath, "//table[@id='editor_table']/tbody/tr[1]/td[2]").click
      fill_in "DTE_Field_label", with: "Label text 31\t"
      fill_in "DTE_Field_notation", with: "SUBMISSION 31\t"
      fill_in "DTE_Field_preferredTerm", with: "The PT 31\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[1]/td[5]").click
      fill_in "DTE_Field_synonym", with: "Same as 31\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[1]/td[6]").click
      fill_in "DTE_Field_definition", with: "We never fill this in, too tricky 31!\n"
      fill_in 'Identifier', with: 'A00032'
      click_button 'New'
      expect(page).to have_content 'A00032'
      find(:xpath, "//table[@id='editor_table']/tbody/tr[2]/td[2]").click
      fill_in "DTE_Field_label", with: "Label text 32\t"
      fill_in "DTE_Field_notation", with: "SUBMISSION 32\t"
      fill_in "DTE_Field_preferredTerm", with: "The PT 32\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[2]/td[5]").click
      fill_in "DTE_Field_synonym", with: "Same as 32\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[2]/td[6]").click
      fill_in "DTE_Field_definition", with: "We never fill this in, too tricky 32!\n"
      #pause
      find(:xpath, "//tr[contains(.,'Same as 32')]/td/button", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'A00031'
      expect(page).not_to have_content 'A00032'
    end

    it "allows a thesauri to be created, field validation", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      visit '/thesauri/new'
      expect(page).to have_content 'New Terminology:'
      fill_in 'thesauri[identifier]', with: '@@@'
      fill_in 'thesauri[label]', with: '€€€'
      click_button 'Create'
      expect(page).to have_content "Label contains invalid characters and Scoped Identifier error: Identifier contains invalid characters"
      fill_in 'thesauri[identifier]', with: 'BETTER'
      fill_in 'thesauri[label]', with: '€€€'
      click_button 'Create'
      expect(page).to have_content "Label contains invalid characters"
      fill_in 'thesauri[identifier]', with: 'BETTER'
      fill_in 'thesauri[label]', with: 'Nice Label'
      click_button 'Create'
      expect(page).to have_content "Terminology was successfully created."
      expect(page).to have_content "BETTER"
      expect(page).to have_content "Nice Label"
    end

    it "allows a thesaurus to be deleted", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'TEST')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: TEST'
      find(:xpath, "//tr[contains(.,'TEST')]/td/a", :text => 'Delete').click
      ui_click_cancel("Are you sure?")
      expect(page).to have_content 'History: TEST'
      find(:xpath, "//tr[contains(.,'TEST')]/td/a", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Index: Terminology'
    end

  end

end