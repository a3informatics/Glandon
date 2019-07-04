require 'rails_helper'

describe "Thesaurus", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include SparqlHelpers

  def sub_dir
    return "features"
  end

  def editor_table_fill_in(input, text)
    expect(page).to have_css("##{input}", wait: 15) 
    fill_in "#{input}", with: "#{text}"
    wait_for_ajax(5)
  end

  def editor_table_click(row, col)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[#{col}]").click
  end
      
  describe "Curator User", :type => :feature do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("thesaurus_concept.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("CT_ACME_TEST.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      @user = User.create :email => "curator@example.com", :password => "12345678" 
      @user.add_role :curator
      Token.set_timeout(30)
    end

    after :all do
      user = User.where(:email => "curator@example.com").first
      user.destroy
      Token.restore_timeout
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
      expect(page).to have_content 'View: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
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
      expect(page).to have_content 'View: CDISC Terminology 2015-12-18 CDISC Terminology (V43.0.0, 43, Standard)'
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

    it "allows for terminology to be exported as TTL", js: true do
      clear_downloads
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show:'
      click_link 'Export Turtle'
      file = download_content
      write_text_file_2(file, sub_dir, "thesaurus_export_results.ttl")
    #Xwrite_text_file_2(file, sub_dir, "thesaurus_export.ttl")
      expected = read_text_file_2(sub_dir, "thesaurus_export.ttl")
      check_triples("thesaurus_export_results.ttl", "thesaurus_export.ttl")
      delete_data_file(sub_dir, "thesaurus_export_results.ttl")
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
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' 
      ui_check_page_options("editor_table", { "5" => 5, "10" => 10, "15" => 15, "20" => 20, "25" => 25, "50" => 50, "All" => -1})
      fill_in 'Identifier', with: 'A00030'
      click_button 'New'
      expect(page).to have_content 'A00030' # Note up version
      editor_table_click(4,2)
      editor_table_fill_in("DTE_Field_label", "Label text\t")
      editor_table_fill_in("DTE_Field_notation", "SUBMISSION\t")
      editor_table_fill_in "DTE_Field_preferredTerm", "The PT\n"
      editor_table_click(4,5)
      editor_table_fill_in "DTE_Field_synonym", "Same as A; B\n"
      editor_table_click(4,6)
      editor_table_fill_in "DTE_Field_definition", "We never fill this in, too tricky!\n"
      find(:xpath, "//tr[contains(.,'Same as A; B')]/td/button", :text => 'Edit').click
      expect(page).to have_content 'Edit: Label text A00030'
      fill_in 'Identifier', with: 'A00031'
      click_button 'New'
      expect(page).to have_content 'A00031'
      editor_table_click(1,2)
      editor_table_fill_in "DTE_Field_label", "Label text 31\t"
      editor_table_fill_in "DTE_Field_notation", "SUBMISSION 31\t"
      editor_table_fill_in "DTE_Field_preferredTerm", "The PT 31\n"
      editor_table_click(1,5)
      editor_table_fill_in "DTE_Field_synonym", "Same as 31\n"
      editor_table_click(1,6)
      editor_table_fill_in "DTE_Field_definition", "We never fill this in, too tricky 31!\n"
      fill_in 'Identifier', with: 'A00032'
      click_button 'New'
      expect(page).to have_content 'A00032'
      editor_table_click(2,2)
      editor_table_fill_in "DTE_Field_label", "Label text 32\t"
      editor_table_fill_in "DTE_Field_notation", "SUBMISSION 32\t"
      editor_table_fill_in "DTE_Field_preferredTerm", "The PT 32\n"
      editor_table_click(2,5)
      editor_table_fill_in "DTE_Field_synonym", "Same as 32\n"
      editor_table_click(2,6)
      editor_table_fill_in "DTE_Field_definition", "We never fill this in, too tricky 32!\n"
    #pause
      find(:xpath, "//tr[contains(.,'Same as 32')]/td/button", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'A00031'
      expect(page).not_to have_content 'A00032'
      click_button 'Close'
    end

    it "allows terminology to be edited, identifier check", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      expect(find('#tcIdentifierPrefix')).to have_content('')
      fill_in 'Identifier', with: 'A00040'
      click_button 'New'
      expect(page).to have_content 'A00040' # Note up version
      editor_table_click(5,2)
      editor_table_fill_in "DTE_Field_label", "A00040 Label text\t"
      editor_table_fill_in "DTE_Field_notation", "A00040SUBMISSION\t"
      wait_for_ajax
      find(:xpath, "//tr[contains(.,'A00040SUBMISSION')]/td/button", :text => 'Edit').click
      expect(page).to have_content 'Edit: A00040 Label text'
      expect(find('#tcIdentifierPrefix')).to have_content('A00040.')
      fill_in 'Identifier', with: 'A00001'
      click_button 'New'
      expect(page).to have_content 'A00040.A00001'
      editor_table_click(1,2)
      editor_table_fill_in "DTE_Field_label", "Label text for A00040.A00001\t"
      editor_table_fill_in "DTE_Field_notation", "A00040A00001SUBMISSION\t"
      wait_for_ajax
      click_button 'Close'
    end

    it "allows terminology to be edited, identifier validation", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      expect(find('#tcIdentifierPrefix')).to have_content('')
      fill_in 'Identifier', with: 'A00040 XX'
      click_button 'New'
      expect(page).to have_content 'Please enter a valid identifier. Upper and lower case alphanumeric characters only.'
      fill_in 'Identifier', with: 'A00040£'
      click_button 'New'
      expect(page).to have_content 'Please enter a valid identifier. Upper and lower case alphanumeric characters only.'
      fill_in 'Identifier', with: 'A00050'
      click_button 'New'
      expect(page).to have_content 'The concept has been saved.'
      click_button 'Close'
    end

    it "allows the edit session to be closed, parent page", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      click_button 'Close'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "allows the edit session to be closed, child page", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      wait_for_ajax
      find(:xpath, "//tr[contains(.,'A00040SUBMISSION')]/td/button", :text => 'Edit').click
      expect(page).to have_content 'Edit: A00040 Label text'
      click_button 'Close'
      expect(page).to have_content 'History: CDISC EXT'
    end
    
    it "allows the parent page to be returned to", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      find(:xpath, "//tr[contains(.,'A00040SUBMISSION')]/td/button", :text => 'Edit').click
      expect(page).to have_content 'Edit: A00040 Label text'
      find(:xpath, "//tr[contains(.,'A00040A00001SUBMISSION')]/td/button", :text => 'Edit').click
      expect(page).to have_content 'Edit: Label text for A00040.A00001 A00040.A00001'
      click_button 'Parent'
      expect(page).to have_content 'Edit: A00040 Label text'
      click_button 'Parent'
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)'
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

    it "allows a search to be performed", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'1.0.0')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
      #expect(page).to have_button('Notepad+')
      wait_for_ajax(5) # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Close'
      expect(page).to have_content 'History: CDISC EXT'
    end  

    it "allows a search to be performed on all current versions", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      click_link 'Search Current'
      expect(page).to have_content 'Search: All Current Terminology'
      wait_for_ajax(5) # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Close'
      expect(page).to have_content 'Index: Terminology'
    end  

    it "edit timeout warnings and expiration", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      token = tokens[0]
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      sleep (@user.edit_lock_warning.to_i / 2)
      expect(page).to have_content("The edit lock is about to timeout!")
      sleep 5
      page.find("#token_timer_1")[:class].include?("btn-danger")
      sleep (@user.edit_lock_warning.to_i / 2)
      expect(page).to have_content("00:00")
      click_button 'Close'
    end

    it "edit timeout warnings and extend", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      token = tokens[0]
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      click_button 'Save'
      wait_for_ajax
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user.edit_lock_warning.to_i
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep 11
      page.find("#token_timer_1")[:class].include?("btn-warning")
      click_button 'Close'
    end

    it "edit timeout warnings and child pages", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      token = tokens[0]
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      find(:xpath, "//tr[contains(.,'RACE OTHER')]/td/button", :text => 'Edit').click
      wait_for_ajax
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      click_button "referer_button"
      wait_for_ajax
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      click_button 'Close'
    end  

    it "edit clears token on close", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      token = tokens[0]
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      click_button 'Close'
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      expect(tokens).to match_array([])
    end  

    it "edit clears token on back button", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      token = tokens[0]
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      ui_click_back_button
      wait_for_ajax
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      expect(tokens).to match_array([])
    end 
    
  end

end