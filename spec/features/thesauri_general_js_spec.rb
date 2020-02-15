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

  def wait_for_ajax_long
    wait_for_ajax(10)
  end

  def new_term_modal(identifier, label)
    # Leave this sleep here. Seems there is an issue with the modal and fade
    # that causes inconsistent entry of text using fill_in.
    sleep 2
    fill_in 'thesauri_identifier', with: identifier
    fill_in 'thesauri_label', with: label
    click_button 'Submit'
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
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_2.ttl", "CT_V43.ttl", "CT_ACME_TEST.ttl"]
      load_files(schema_files, data_files)
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
      # wait_for_ajax_long
      ua_logoff
    end

    after :all do
      ua_destroy
      nv_destroy
      Token.restore_timeout
    end

    it "allows terminology to be created (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      click_link 'New Terminology'
      new_term_modal('TEST test', 'Test Terminology')
      expect(page).to have_content 'Terminology was successfully created.'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a").click
      expect(page).to have_content 'Version History of \'TEST test\''
    end

    it "history allows the status page to be viewed (REQ-MDR-ST-050)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element('history', 4, 'CDISC Extensions', :document_control)
      wait_for_ajax_long
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content 'Standard'
      expect(page).to have_content 'Superseded'
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      expect(page).to have_content '1.0.0'
      click_link 'Return'
      expect(page).to have_content 'Version History of \'CDISC EXT\''
    end

    it "allows for multiple edit lock and unlock", js: true do
      click_navbar_terminology
      click_link 'New Terminology'
      new_term_modal('TEST ME', 'Test Multiple Edit Terminology')
      find(:xpath, "//tr[contains(.,'Test Multiple Edit Terminology')]/td/a").click
      wait_for_ajax_long
      context_menu_element('history', 4, 'Test Multiple Edit Terminology', :document_control)
      wait_for_ajax_long
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")
      click_button "state_submit"
      expect(page).to have_content("Candidate")
      click_button "state_submit"
      expect(page).to have_content("Recorded")
      click_button "state_submit"
      expect(page).to have_content("Qualified")
      click_link 'Return'
      wait_for_ajax_long
      find(:xpath, "//*[@id='history']/tbody/tr/td[7]/span/span").click
      wait_for_ajax_long
      expect(page).to have_css ('.icon-lock-open')
      ui_check_table_info("history", 1, 1, 1)
      context_menu_element('history', 4, 'Test Multiple Edit Terminology', :edit)
      wait_for_ajax_long
      click_link 'Return'
      find(:xpath, "//*[@id='history']/tbody/tr[1]/td[7]/span/span").click
      expect(page).to have_css ('.icon-lock')
      wait_for_ajax_long
      context_menu_element('history', 4, 'Test Multiple Edit Terminology', :edit)
      wait_for_ajax_long
      click_link 'Return'
      ui_check_table_info("history", 1, 2, 2)
      context_menu_element('history', 4, 'Test Multiple Edit Terminology', :document_control, 1)
      wait_for_ajax_long
      expect(page).to have_content 'Version Control'
      find(:xpath, "//*[@id='version-edit']").click
      find(:xpath, "//*[@id='select-release']/option[1]").click
      find(:xpath, "//*[@id='version-edit-submit']").click
      wait_for_ajax_long
      ui_check_table_row("version_info", 1, ["Version:", "1.0.0"])
      click_link 'Return'
    end

    it "Changes of a sponsor-created Code List", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element("history", 4, 'CDISC Extensions', :show)
       wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'A00020')]/td/a", :text => 'Show').click
      wait_for_ajax 10
      click_link 'Changes'
      wait_for_ajax 10
      expect(page).to have_content 'A00020'
      expect(page).to have_content 'Differences'
      expect(page).to have_content 'Changes'
      ui_check_table_info("differences_table", 1, 1, 1)
      ui_check_table_info("changes", 1, 1, 1)
    end

    it "allows for terminology to be exported as CSV"
    # it "allows for terminology to be exported as CSV", js: true do
    #   clear_downloads
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a").click
    #   expect(page).to have_content 'Version History of \'CDISC EXT\''
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

    it "allows terminology to be edited, auto-identifier (REQ-MDR-ST-015)", js: true do
      click_navbar_code_lists
      expect(page).to have_content 'Index: Code Lists'
      cl_identifier = ui_new_code_list
      #click_link 'New Code List'
      #wait_for_ajax_long
      #expect(page).to have_content 'NP000010P'
      #wait_for_ajax_long
      context_menu_element('history', 4, cl_identifier, :edit)
      wait_for_ajax_long
      click_button 'New'
      wait_for_ajax_long
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
      wait_for_ajax_long
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
      wait_for_ajax_long
      expect(page).to have_content 'NC00000999C'
      expect(page).not_to have_content 'NC00001000C'
      click_link 'Return'
    end

    it "allows a code list to be edited, edit properties (REQ-MDR-ST-015)", js: true do
      click_navbar_code_lists
      expect(page).to have_content 'Index: Code Lists'
      cl_identifier = ui_new_code_list
      context_menu_element('history', 4, cl_identifier, :edit)
      wait_for_ajax_long
      expect(context_menu_element_header_present?(:edit_properties)).to eq(true)
      context_menu_element_header(:edit_properties)
      sleep 0.5
      expect(page).to have_content "Edit properties of #{cl_identifier}"
      fill_in "ep_input_notation", with: "CODELIST"
      sleep 0.5
      fill_in "ep_input_definition", with: "Code List definition here"
      sleep 0.5
      fill_in "ep_input_synonym", with: "Syn1; Syn2"
      sleep 0.5
      find("#submit-button").click
      wait_for_ajax(20)
      expect(find("#imh_header")).to have_content "CODELIST"
      expect(find("#imh_header")).to have_content "Code List definition here"
      expect(find("#imh_header")).to have_content "Syn1"
      expect(find("#imh_header")).to have_content "Syn2"
      click_link 'Return'
    end

    it "links to Edit Tags page, from Code List edit page", js:true do
      click_navbar_code_lists
      expect(page).to have_content 'Index: Code Lists'
      cl_identifier = ui_new_code_list
      context_menu_element('history', 4, cl_identifier, :edit)
      wait_for_ajax_long
      expect(context_menu_element_header_present?(:edit_tags)).to eq(true)
      w = window_opened_by { context_menu_element_header(:edit_tags) }
      within_window w do
        wait_for_ajax(10)
        expect(page).to have_content cl_identifier
        expect(page).to have_content "Attach / Detach Tags"
      end
      w.close
    end

    # NOT WORKING (EDIT TERMINOLOGY)
    it "allows terminology to be edited, manual identifier check (REQ-MDR-ST-015)" #, js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Version History of \'CDISC EXT\''
    #   find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
    #   expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
    #   expect(find('#tcIdentifierPrefix')).to have_content('')
    #   fill_in 'Identifier', with: 'A00040'
    #   click_button 'New'
    #   expect(page).to have_content 'A00040' # Note up version
    #   editor_table_click(5,2)
    #   editor_table_fill_in "DTE_Field_label", "A00040 Label text\t"
    #   editor_table_fill_in "DTE_Field_notation", "A00040SUBMISSION\t"
    #   wait_for_ajax_long
    #   find(:xpath, "//tr[contains(.,'A00040SUBMISSION')]/td/button", :text => 'Edit').click
    #   expect(page).to have_content 'Edit: A00040 Label text'
    #   expect(find('#tcIdentifierPrefix')).to have_content('A00040.')
    #   fill_in 'Identifier', with: 'A00001'
    #   click_button 'New'
    #   expect(page).to have_content 'A00040.A00001'
    #   editor_table_click(1,2)
    #   editor_table_fill_in "DTE_Field_label", "Label text for A00040.A00001\t"
    #   editor_table_fill_in "DTE_Field_notation", "A00040A00001SUBMISSION\t"
    #   wait_for_ajax_long
    #   click_button 'Close'
    # end

    # NOT WORKING (EDIT TERMINOLOGY)
    it "allows terminology to be edited, manual identifier validation (REQ-MDR-ST-015)" #, js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
    #   expect(page).to have_content 'Version History of \'CDISC EXT\''
    #   find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
    #   expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
    #   expect(find('#tcIdentifierPrefix')).to have_content('')
    #   fill_in 'Identifier', with: 'A00040 XX'
    #   click_button 'New'
    #   expect(page).to have_content 'Please enter a valid identifier. Upper and lower case alphanumeric characters only.'
    #   fill_in 'Identifier', with: 'A00040£'
    #   click_button 'New'
    #   expect(page).to have_content 'Please enter a valid identifier. Upper and lower case alphanumeric characters only.'
    #   fill_in 'Identifier', with: 'A00050'
    #   click_button 'New'
    #   expect(page).to have_content 'The concept has been saved.'
    #   click_button 'Close'
    # end

    it "allows the edit session to be closed, parent page (REQ-MDR-ST-NONE) - WILL CURRENTLY FAIL - Return link wrong (minor)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element("history", 4, 'CDISC Extensions', :edit)
      wait_for_ajax_long
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      click_link 'Return'
      expect(page).to have_content 'Version History of \'CDISC EXT\''
    end

    # Design Changed. Review need for test / add tests
    it "allows the edit session to be closed, child page (REQ-MDR-ST-NONE)" #, js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Version History of \'CDISC EXT\''
    #   context_menu_element("history", 1, '1.1.0', :edit)
    #   wait_for_ajax_long
    #   expect(page).to have_content 'CDISC Extensions'
    #   expect(page).to have_content 'CDISC EXT'
    #   click_button 'New'
    #   wait_for_ajax_long
    #   expect(page).to have_content 'NP000011P'
    #   click_link 'Return'
    #   expect(page).to have_content 'Version History of \'CDISC EXT\''
    # end

    # Design Changed. Review need for test / add tests
    it "allows the parent page to be returned to (REQ-MDR-ST-NONE)" #, js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
    #   expect(page).to have_content 'Version History of \'CDISC EXT\''
    #   context_menu_element("history", 4, 'CDISC Extensions', :edit)
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
    #   find(:xpath, "//tr[contains(.,'A00040SUBMISSION')]/td/button", :text => 'Edit').click
    #   expect(page).to have_content 'Edit: A00040 Label text'
    #   find(:xpath, "//tr[contains(.,'A00040A00001SUBMISSION')]/td/button", :text => 'Edit').click
    #   expect(page).to have_content 'Edit: Label text for A00040.A00001 A00040.A00001'
    #   click_button 'Parent'
    #   expect(page).to have_content 'Edit: A00040 Label text'
    #   click_button 'Parent'
    #   expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)'
    # end

    it "allows a thesauri to be created, field validation (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'New Terminology'
      click_link 'New Terminology'
      new_term_modal('@@@', '€€€')
      expect(page).to have_content "Label contains invalid characters and Has identifier: Identifier contains invalid characters"
      click_link 'New Terminology'
      new_term_modal('BETTER', '€€€')
      expect(page).to have_content "Label contains invalid characters"
      click_link 'New Terminology'
      new_term_modal('BETTER', 'Nice Label')
      expect(page).to have_content "Terminology was successfully created."
      expect(page).to have_content "BETTER"
      expect(page).to have_content "Nice Label"
    end

    it "allows a thesaurus to be deleted (REQ-MDR-ST-015, REQ-MDR-MIT-030, REQ-MDR-MIT-040)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      click_link 'New Terminology'
      new_term_modal('TT', 'TestTerminology')
      expect(page).to have_content "Terminology was successfully created."
      find(:xpath, "//tr[contains(.,'TestTerminology')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Item History'
      expect(page).to have_content 'Identifier: TT'
      context_menu_element("history", 4, 'TestTerminology', :delete)
      ui_confirmation_dialog false
      expect(page).to have_content 'Item History'
      context_menu_element("history", 4, 'TestTerminology', :delete)
      ui_confirmation_dialog true
      expect(page).to have_content 'Index: Terminology'
    end

    it "edit timeout warnings and expiration (REQ-MDR-EL-020)", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element("history", 1, '1.1.0', :edit)
      wait_for_ajax_long
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#imh_header")[:class].include?("warning")
      click_link "timeout"
      wait_for_ajax_long
      expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#imh_header")[:class].include?("warning")
      sleep (@user_c.edit_lock_warning.to_i / 2) + 5
      page.find("#imh_header")[:class].include?("danger")
      sleep (@user_c.edit_lock_warning.to_i / 2)
      expect(page).to have_content("00:00")
      click_link 'Return'
    end

    it "edit timeout warnings and extend (REQ-MDR-EL-030)", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element("history", 1, '1.1.0', :edit)
      wait_for_ajax_long
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#imh_header")[:class].include?("warning")
      click_link "timeout"
      wait_for_ajax_long
      expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i
      expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
      sleep 11
      page.find("#imh_header")[:class].include?("warning")
      click_link 'Return'
    end

    # Design Changed. Review need for test / add tests
    it "edit timeout warnings and child pages (REQ-MDR-EL-NONE) - WILL CURRENTLY FAIL - Returning link wrong (minor)" #, js: true do
    #   Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Version History of \'CDISC EXT\''
    #   context_menu_element("history", 1, '1.1.0', :edit)
    #   wait_for_ajax_long
    #   expect(page).to have_content 'CDISC Extensions'
    #   expect(page).to have_content 'CDISC EXT'
    #   tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
    #   token = tokens[0]
    #   expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
    #   sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
    #   page.find("#imh_header")[:class].include?("warning")
    #   find(:xpath, "//tr[contains(.,'RACE OTHER')]/td/button", :text => 'Edit').click
    #   wait_for_ajax_long
    #   expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
    #   sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
    #   page.find("#imh_header")[:class].include?("warning")
    #   click_link 'Return'
    #   wait_for_ajax_long
    #   expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
    #   sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
    #   page.find("#imh_header")[:class].include?("warning")
    #   click_link 'Return'
    # end

    it "edit clears token on close (REQ-MDR-EL-030)", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element("history", 1, '1.1.0', :edit)
      wait_for_ajax_long
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      # CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      token = tokens[0]
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#imh_header")[:class].include?("warning")
      ui_click_back_button
      wait_for_ajax_long
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      expect(tokens).to match_array([])
    end

    it "edit clears token on back button (REQ-MDR-EL-030)", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element("history", 1, '1.1.0', :edit)
      wait_for_ajax_long
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      # CDISC EXT (V1.1.0, 2, Incomplete)' # Note up version
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      token = tokens[0]
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#timeout")[:class].include?("btn-warning")
      ui_click_back_button
      wait_for_ajax_long
      tokens = Token.where(item_uri: "MDRThesaurus/ACME/V2#TH-ACME_TEST")
      expect(tokens).to match_array([])
    end

    it "history allows the edit page to be viewed (REQ-MDR-ST-015)", js: true do # Put this after other tests, creates V2
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element('history', 1, '1.1.0', :edit)
      wait_for_ajax_long
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      #(V1.1.0, 2, Incomplete)' # Note the up version because V1 is at 'Standard'
      click_link 'Return'
    end

    #View option disabled
    # it "allows a thesaurus to be viewed, sponsor", js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a").click
    #   expect(page).to have_content 'Version History of \'CDISC EXT\''
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
    #   find(:xpath, "//tr[contains(.,'CDISC Terminology')]/td/a").click
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

  describe "Child Status Curator User", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_sponsor_5_state.ttl"]
      load_files(schema_files, data_files)
      ua_create
      nv_destroy
      nv_create(parent: "10", child: "999")
      Token.delete_all
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
      nv_destroy
    end

    def th_state_update(old_state, new_state)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'State Test Terminology')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'STATE\''
      context_menu_element('history', 4, 'STATE', :document_control)
      wait_for_ajax_long
      ui_manage_status_page(old_state, new_state, "ACME", "STATE", "0.1.0")
      click_button "state_submit"
      wait_for_ajax
    end

    def unsuccesful_th_state_update(old_state, new_state)
      th_state_update(old_state, new_state)
      ui_check_flash_message_present
      expect(page).to have_content 'Child items are not in the appropriate state.'
      click_link 'Return'
      expect(page).to have_content 'Version History of \'STATE\''
      ui_check_table_cell("history", 1, 7, "#{old_state}")
    end

    def succesful_th_state_update(old_state, new_state)
      th_state_update(old_state, new_state)
      ui_check_no_flash_message_present
      click_link 'Return'
      expect(page).to have_content 'Version History of \'STATE\''
      ui_check_table_cell("history", 1, 7, "#{new_state}")
    end

    def succesful_cl_state_update(old_state, new_state, identifier)
      click_navbar_code_lists
      expect(page).to have_content 'Index: Code Lists'
      wait_for_ajax_long
      find(:xpath, "//tr[contains(.,'London Heathrow')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Item History'
      context_menu_element('history', 4, "#{identifier}", :document_control)
      wait_for_ajax_long
      ui_manage_status_page(old_state, new_state, "ACME", "#{identifier}", "0.1.0")
      click_button "state_submit"
      wait_for_ajax
      ui_check_no_flash_message_present
      click_link 'Return'
      expect(page).to have_content 'Item History'
      ui_check_table_cell("history", 1, 7, "#{new_state}")
    end

    it "Child status", js:true do
      unsuccesful_th_state_update(:Incomplete, :Candidate)
      succesful_cl_state_update(:Incomplete, :Candidate, "A00001")
      succesful_th_state_update(:Incomplete, :Candidate)

      unsuccesful_th_state_update(:Candidate, :Recorded)
      succesful_cl_state_update(:Candidate, :Recorded, "A00001")
      succesful_th_state_update(:Candidate, :Recorded)

      unsuccesful_th_state_update(:Recorded, :Qualified)
      succesful_cl_state_update(:Recorded, :Qualified, "A00001")
      succesful_th_state_update(:Recorded, :Qualified)

      unsuccesful_th_state_update(:Qualified, :Standard)
      succesful_cl_state_update(:Qualified, :Standard, "A00001")
      succesful_th_state_update(:Qualified, :Standard)
    end

    it "edit lock, extend", js:true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'State Test Terminology')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'STATE\''
      context_menu_element('history', 4, 'STATE', :document_control)
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#imh_header")[:class].include?("warning")
      page.find("#timeout").click
      wait_for_ajax(120)
      expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
      sleep Token.get_timeout - (@user_c.edit_lock_warning.to_i / 2) + 2
      page.find("#imh_header")[:class].include?("danger")
      sleep 28
      page.find("#timeout")[:class].include?("disabled")
      page.find("#imh_header")[:class].include?("danger")
      Token.restore_timeout
    end

    it "expires edit lock, prevents changes", js:true do
      Token.set_timeout(10)
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'State Test Terminology')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'STATE\''
      context_menu_element('history', 4, 'STATE', :document_control)
      sleep 12
      click_on "Submit Status Change"
      expect(page).to have_content("The edit lock has timed out")
      Token.restore_timeout
    end

    it "clears token when leaving page", js:true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'State Test Terminology')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'STATE\''
      context_menu_element('history', 4, 'STATE', :document_control)
      tokens = Token.where(item_uri: "http://www.acme-pharma.com/STATE/V1")
      token = tokens[0]
      click_link 'Return'
      tokens = Token.where(item_uri: "http://www.acme-pharma.com/STATE/V1")
      expect(tokens).to match_array([])
    end

  end

  describe "Reference CT", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_sponsor_6_referenced.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
      ua_create
      nv_destroy
      nv_create(parent: "10", child: "999")
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
      nv_destroy
    end

    it "Child status", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'State Test Terminology')]/td/a").click
      wait_for_ajax_long
      expect(page).to have_content 'Version History of \'STATE\''
      context_menu_element('history', 4, 'STATE', :edit)
      wait_for_ajax_long
      expect(page).to have_content '2007-04-20'
    end

  end

end
