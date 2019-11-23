require 'rails_helper'

describe "Thesaurus", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include SparqlHelpers
  include NameValueHelpers

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

  def editor_table_click_row_content(row_content, col)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[contains(.,'#{row_content}')]/td[#{col}]").click
  end

  describe "Curator User", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_2.ttl", "CT_V43.ttl", "CT_ACME_TEST.ttl"]
      load_files(schema_files, data_files)
      # clear_triple_store
      # load_schema_file_into_triple_store("ISO11179Types.ttl")
      # load_schema_file_into_triple_store("ISO11179Identification.ttl")
      # load_schema_file_into_triple_store("ISO11179Registration.ttl")
      # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      # load_schema_file_into_triple_store("ISO25964.ttl")
      # load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      # load_test_file_into_triple_store("iso_namespace_real.ttl")
      # load_test_file_into_triple_store("thesaurus_concept.ttl")
      # load_test_file_into_triple_store("CT_V43.ttl")
      # load_test_file_into_triple_store("CT_ACME_TEST.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      Token.set_timeout(30)
      nv_destroy
      nv_create(parent: "10", child: "999")
    end

    before :each do
      #NameValue.destroy_all
      ua_curator_login
    end

    after :each do
      wait_for_ajax
      ua_logoff
    end

    after :all do
      ua_destroy
      nv_destroy
      Token.restore_timeout
    end

    #test of Terminology edit, document control, delete, export

    it "allows terminology to be created (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      expect(page).to have_content 'New Terminology'
      fill_in 'thesauri_identifier', with: 'TEST test'
      fill_in 'thesauri_label', with: 'Test Terminology'
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: TEST test'
    end

    it "history allows the status page to be viewed (REQ-MDR-ST-050)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      #currently not working
      context_menu_element('history', 4, 'CDISC Extensions', :document_control)
wait_for_ajax(10)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content 'Standard'
      expect(page).to have_content 'Superseded'
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      expect(page).to have_content '1.0.0'
      click_link 'Return'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "allows for terminology to be exported as CSV"
    # it "allows for terminology to be exported as CSV", js: true do
    #   clear_downloads
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: CDISC EXT'
    #   context_menu_element('history', 4, 'CDISC Extensions', :show)
    #   expect(page).to have_content 'Code Lists'
    #   #currently not working
    #   click_link 'Export CSV'
    #   file = download_content
    #   write_text_file_2(file, sub_dir, "thesaurus_export_results.csv")
    #   #Xwrite_text_file_2(file, sub_dir, "thesaurus_export.ttl")
    #   expected = read_text_file_2(sub_dir, "thesaurus_export.csv")
    #   check_triples("thesaurus_export_results.ttl", "thesaurus_export.csv")
    #   delete_data_file(sub_dir, "thesaurus_export_results.csv")
    # end

    it "allows terminology to be edited, manual-identifier"

    it "allows terminology to be edited, auto-identifier (REQ-MDR-ST-015)- WILL CURRENTLY FAIL", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
wait_for_ajax
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element('history', 4, 'CDISC Extensions', :edit)
wait_for_ajax
      expect(page).to have_content 'CDISC Extensions' 
      expect(page).to have_content 'CDISC EXT'
#      expect(page).to have_content '1.1.0'
#      expect(page).to have_content 'Incomplete'
      ui_check_page_options("editor_table", { "5" => 5, "10" => 10, "15" => 15, "25" => 25, "50" => 50, "100" => 100, "All" => -1})
      # fill_in 'Identifier', with: 'A00030'
      click_button 'New'
wait_for_ajax
      expect(page).to have_content 'NP000010P' # Note up version
      editor_table_click_row_content 'NP000010P', 2
      # editor_table_fill_in("DTE_Field_label", "Label text\t")
      editor_table_fill_in("DTE_Field_notation", "SUBMISSION 10P\t")
      editor_table_click_row_content 'NP000010P', 3
      editor_table_fill_in "DTE_Field_preferred_term", "The PT 10P\n"
      editor_table_click_row_content 'NP000010P', 4
      editor_table_fill_in "DTE_Field_synonym", "Same as A; B\n"
      editor_table_click_row_content 'NP000010P', 5
      editor_table_fill_in "DTE_Field_definition", "We never fill this in, too tricky!\n"
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/button", :text => 'Edit').click
wait_for_ajax
      expect(page).to have_content 'NP000010P'
      expect(page).to have_content 'The PT 10P'
      #fill_in 'Identifier', with: 'A00031'
      click_button 'New'
wait_for_ajax
      expect(page).to have_content 'NC00000999C'
      editor_table_click(1,2)
      #editor_table_fill_in "DTE_Field_label", "Label text 31\t"
      editor_table_fill_in "DTE_Field_notation", "SUBMISSION 999C\t"
      editor_table_fill_in "DTE_Field_preferred_term", "The PT 999C\n"
      editor_table_click(1,4)
      editor_table_fill_in "DTE_Field_synonym", "Same as 999C\n"
      editor_table_click(1,5)
      editor_table_fill_in "DTE_Field_definition", "We never fill this in, too tricky 999C!\n"
      #fill_in 'Identifier', with: 'A00032'
      click_button 'New'
wait_for_ajax
      expect(page).to have_content 'NC00001000C'
      editor_table_click(2,2)
      #editor_table_fill_in "DTE_Field_label", "Label text 32\t"
      editor_table_fill_in "DTE_Field_notation", "SUBMISSION 1000C\t"
      editor_table_fill_in "DTE_Field_preferred_term", "The PT 1000C\n"
      editor_table_click(2,4)
      editor_table_fill_in "DTE_Field_synonym", "Same as 1000C\n"
      editor_table_click(2,5)
      editor_table_fill_in "DTE_Field_definition", "We never fill this in, too tricky 1000C!\n"
      find(:xpath, "//tr[contains(.,'Same as 1000C')]/td/button", :text => 'Delete').click
      ui_click_ok("Are you sure?")
wait_for_ajax
      expect(page).to have_content 'NC00000999C'
      expect(page).not_to have_content 'NC00001000C'
      click_button 'Return'
    end

    # NOT WORKING (EDIT TERMINOLOGY)
    it "allows terminology to be edited, manual identifier check - WILL CURRENTLY FAIL (need to set config) (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
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

    # NOT WORKING (EDIT TERMINOLOGY)
    it "allows terminology to be edited, manual identifier validation - WILL CURRENTLY FAIL (need to set config) (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
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

    it "allows the edit session to be closed, parent page (REQ-MDR-ST-NONE)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
wait_for_ajax
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :edit)
wait_for_ajax
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      click_link 'Return'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "allows the edit session to be closed, child page (REQ-MDR-ST-NONE)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
wait_for_ajax
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :edit)
wait_for_ajax
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      click_button 'New'
wait_for_ajax
      expect(page).to have_content 'NP000010P' # Note up version
      click_link 'Return'
      expect(page).to have_content 'History: CDISC EXT'
    end

    # NOT WORKING (EDIT TERMINOLOGY)
    it "allows the parent page to be returned to (REQ-MDR-ST-NONE)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :edit)
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

    it "allows a thesauri to be created, field validation (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'New Terminology'
      fill_in 'thesauri[identifier]', with: '@@@'
      fill_in 'thesauri[label]', with: '€€€'
      click_button 'Create'
      expect(page).to have_content "Label contains invalid characters and Has identifier: Identifier contains invalid characters"
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

    it "allows a code list to be deleted (REQ-MDR-ST-015, REQ-MDR-MIT-030, REQ-MDR-MIT-040)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      fill_in 'thesauri[identifier]', with: 'TT'
      fill_in 'thesauri[label]', with: 'TestTerminology'
      click_button 'Create'
      expect(page).to have_content "Terminology was successfully created."
      find(:xpath, "//tr[contains(.,'TestTerminology')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: TT'
      context_menu_element("history", 4, 'TestTerminology', :delete)
      # ALERT NOT SHOWN, FAILS
      ui_click_cancel("Are you sure?")
      expect(page).to have_content 'History: TEST'
      context_menu_element("history", 4, 'TestTerminology', :delete)
      #pause
      ui_click_ok("Are you sure?")
      pause
      
      expect(page).to have_content 'Index: Terminology'
    end

    it "edit timeout warnings and expiration (REQ-MDR-EL-020)", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
wait_for_ajax
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :edit)
wait_for_ajax
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
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

    it "edit timeout warnings and extend (REQ-MDR-EL-030)", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :edit)
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

    it "edit timeout warnings and child pages (REQ-MDR-EL-NONE)", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :edit)
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

    it "edit clears token on close (REQ-MDR-EL-030)", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
wait_for_ajax
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :edit)
wait_for_ajax
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      # CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      token = tokens[0]
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#timeout")[:class].include?("btn-warning")
      ui_click_back_button
      wait_for_ajax
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      expect(tokens).to match_array([])
    end

    it "edit clears token on back button (REQ-MDR-EL-030)", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
wait_for_ajax
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :edit)
wait_for_ajax
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      # CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      token = tokens[0]
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#timeout")[:class].include?("btn-warning")
      ui_click_back_button
      wait_for_ajax
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      expect(tokens).to match_array([])
    end

    it "history allows the edit page to be viewed (REQ-MDR-ST-015)", js: true do # Put this after other tests, creates V2
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
wait_for_ajax
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element('history', 4, 'CDISC Extensions', :edit)
wait_for_ajax
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      #(V1.1.0, 2, Incomplete)' # Note the up version because V1 is at 'Standard'
      click_link 'Return'
    end


    #View option disabled
    # it "allows a thesaurus to be viewed, sponsor", js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: CDISC EXT'
    #   find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'View').click
    #   expect(page).to have_content 'View: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
    #   expect(page).to have_content 'Thesauri Details'
    #   ui_check_anon_table_row(1, ["Label:", "CDISC Extensions"])
    #   ui_check_anon_table_row(2, ["Identifier:", "CDISC EXT"])
    #   ui_check_anon_table_row(3, ["Version Label:", "0.1"])
    #   ui_check_anon_table_row(4, ["Version:", "1"])
    #   key1 = ui_get_key_by_path('["CDISC Extensions", "Placeholder for Ethnic Subgroup"]')
    #   ui_click_node_key(key1)
    #   wait_for_ajax
    #   ui_check_td_with_id("conceptLabel", "Placeholder for Ethnic Subgroup")
    #   ui_check_td_with_id("conceptId", "A00010")
    #   ui_double_click_node_key(key1)
    #   wait_for_ajax
    #   key2 = ui_get_key_by_path('["CDISC Extensions", "Placeholder for Ethnic Subgroup", "Ethnic Subgroup 1"]')
    #   ui_click_node_key(key2)
    #   ui_check_td_with_id("conceptLabel", "Ethnic Subgroup 1")
    #   ui_check_td_with_id("conceptId", "A00011")
    #   ui_check_td_with_id("conceptNotation", "ETHNIC SUBGROUP [1]")
    #   ui_click_node_key(key1)
    #   wait_for_ajax
    #   ui_check_td_with_id("conceptLabel", "Placeholder for Ethnic Subgroup")
    #   ui_check_td_with_id("conceptId", "A00010")
    # end

    #View option disabled
    # it "allows a thesaurus to be viewed, CDISC", js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC Terminology')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: CDISC Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-12-18')]/td/a", :text => 'View').click
    #   expect(page).to have_content 'View: CDISC Terminology 2015-12-18 CDISC Terminology (V43.0.0, 43, Standard)'
    #   expect(page).to have_content 'Thesauri Details'
    #   ui_check_anon_table_row(1, ["Label:", "CDISC Terminology 2015-12-18"])
    #   ui_check_anon_table_row(2, ["Identifier:", "CDISC Terminology"])
    #   ui_check_anon_table_row(3, ["Version Label:", "2015-12-18"])
    #   ui_check_anon_table_row(4, ["Version:", "43"])
    #   key1 = ui_get_key_by_path('["CDISC Terminology 2015-12-18", "Sex"]')
    #   ui_click_node_key(key1)
    #   wait_for_ajax
    #   ui_check_td_with_id("conceptLabel", "Sex")
    #   ui_check_td_with_id("conceptId", "C66731")
    #   ui_check_td_with_id("conceptNotation", "SEX")
    #   ui_double_click_node_key(key1)
    #   wait_for_ajax
    #   key2 = ui_get_key_by_path('["CDISC Terminology 2015-12-18", "Sex", "Male"]')
    #   ui_click_node_key(key2)
    #   ui_check_td_with_id("conceptLabel", "Male")
    #   ui_check_td_with_id("conceptId", "C20197")
    #   ui_check_td_with_id("conceptNotation", "M")
    # end

  end

end
