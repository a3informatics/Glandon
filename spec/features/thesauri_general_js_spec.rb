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
  include TagHelpers
  include EditorHelpers
  include ItemsPickerHelpers
  include TokenHelpers
  include IsoManagedHelpers
  
  def sub_dir
    return "features"
  end

  def wait_for_ajax_long
    wait_for_ajax(10)
  end

  describe "Thesaurus, Curator User", type: :feature, js: true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_2.ttl", "CT_V43.ttl", "CT_ACME_TEST.ttl"]
      load_files(schema_files, data_files)
      ua_create
      Token.set_timeout(30)
      nv_destroy
      nv_create(parent: "10", child: "999")
      set_transactional_tests false
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
      Token.restore_timeout
      set_transactional_tests true
    end

    # Terminology

    it "allows terminology to be created (REQ-MDR-ST-015)" do
      ui_create_terminology('TEST test', 'Test Terminology')
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a").click
      expect(page).to have_content 'Version History of \'TEST test\''
    end

    it "allows for terminology to be exported as CSV"

    it "allows a thesaurus to be created, field validation (REQ-MDR-ST-015)" do
      ui_create_terminology('@@@', '€€€', false)
      expect(page).to have_content "Label contains invalid characters and Has identifier - identifier - contains invalid characters"
      ui_create_terminology('BETTER', '€€€', false)
      expect(page).to have_content "Label contains invalid characters"
      ui_create_terminology('BETTER', 'Nice Label')
      expect(page).to have_content "BETTER"
      expect(page).to have_content "Nice Label"
    end

    it "allows a thesaurus to be deleted (REQ-MDR-ST-015, REQ-MDR-MIT-030, REQ-MDR-MIT-040)" do
      ui_create_terminology('TT', 'TestTerminology')
      find(:xpath, "//tr[contains(.,'TestTerminology')]/td/a").click
      wait_for_ajax 10
      expect(page).to have_content 'Item History'
      expect(page).to have_content 'Identifier: TT'
      ui_check_table_info('history', 1, 1, 1)
      context_menu_element_v2("history", 'TestTerminology', :delete)
      ui_confirmation_dialog false
      expect(page).to have_content 'Item History'
      context_menu_element("history", 4, 'TestTerminology', :delete)
      ui_confirmation_dialog true
      wait_for_ajax 10
      ui_check_table_info('history', 0, 0, 0)
      ui_refresh_page(true)
      expect(page).to have_content 'Index: Terminology'
    end

    it "allows to view changes of a sponsor Code List" do
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element_v2("history", 'CDISC Extensions', :show)
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

  end

  describe "Code List Editor, Curator User", type: :feature, js: true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_2.ttl", "CT_V43.ttl", "CT_ACME_TEST.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      ua_create
      Token.set_timeout(30)
      nv_destroy
      nv_create(parent: "10", child: "999")
      set_transactional_tests false
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
      Token.restore_timeout
      set_transactional_tests true
    end


    def go_to_cl_edit(identifier)
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", identifier)
      find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", identifier, :edit)
      wait_for_ajax 10
    end

    # Code List Edit, Consecutive tests
    it "allows to create a new Code List, Edit page, initial state" do
      click_navbar_code_lists

      wait_for_ajax 10
      ui_new_code_list
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 10

      expect(page).to have_content "NP000010P"
      expect(page).to have_content "Code List Editor"
      expect(page).to have_content "No data."
      expect(page).to have_link "Refresh"
      expect(page).to have_link "Add items"
      expect(page).to have_link "New item"
    end

    it "allows a code list properties to be edited (REQ-MDR-ST-015)" do
      go_to_cl_edit "NP000010P"

      expect(context_menu_element_header_present?(:edit_properties)).to eq(true)
      context_menu_element_header(:edit_properties)

      ui_in_modal do
        expect(page).to have_content "Edit properties"
        fill_in "notation", with: "CODELIST"
        fill_in "definition", with: "Code List definition here"
        fill_in "synonym", with: "Syn1; Syn2"
        click_on 'Save changes'
      end

      wait_for_ajax(20)
      expect(find("#imh_header")).to have_content "CODELIST"
      expect(find("#imh_header")).to have_content "Code List definition here"
      expect(find("#imh_header")).to have_content "Syn1"
      expect(find("#imh_header")).to have_content "Syn2"
    end

    it "allows to create a new Code List Item, default values" do
      go_to_cl_edit "NP000010P"

      click_on "New item"
      wait_for_ajax 10
      ui_check_table_cell("editor", 1, 2, "Not Set")
      ui_check_table_cell("editor", 1, 3, "Not Set")
      ui_check_table_cell("editor", 1, 4, "")
      ui_check_table_cell("editor", 1, 5, "Not Set")
      ui_check_table_cell("editor", 1, 6, "None")
    end

    it "allows to edit a Code List Item" do
      go_to_cl_edit "NP000010P"

      ui_editor_select_by_location 1, 2
      ui_editor_fill_inline "notation", "SUBMISSION 999C\n"
      ui_editor_check_value 1, 2, "SUBMISSION 999C"

      ui_press_key :arrow_right
      ui_press_key :enter

      ui_editor_fill_inline "preferred_term", "The PT 999C\t"
      ui_editor_check_value 1, 3, "The PT 999C"

      ui_press_key :enter

      ui_editor_fill_inline "synonym", "Same as 999C\n"
      ui_editor_check_value 1, 4, "Same as 999C"

      ui_editor_select_by_content "Not Set"
      ui_editor_fill_inline "definition", "We never fill this in, too tricky 999C!\n"
      ui_editor_check_value 1, 5, "We never fill this in, too tricky 999C!"

      # Cancel edit
      ui_editor_select_by_location 1, 2
      ui_editor_fill_inline "notation", "This should not be saved"
      ui_press_key :escape
      ui_editor_check_value 1, 2, "SUBMISSION 999C"

      # Field validation
      ui_editor_select_by_location 1, 5
      ui_editor_fill_inline "definition", "I want special chærøcters\n"
      ui_editor_check_error "definition", "contains invalid characters"
    end

    it "prevents duplicate notation" do
      go_to_cl_edit "NP000010P"

      click_on "New item"
      wait_for_ajax 10
      ui_editor_select_by_location 1, 2
      ui_editor_fill_inline "notation", "SUBMISSION 999C\n"
      ui_editor_check_error "notation", "duplicate detected 'SUBMISSION 999C'"
    end

    it "allows to add a reference to CDISC Code List Items, prevents edit" do
      go_to_cl_edit "NP000010P"

      click_on "Add items"
      ip_pick_unmanaged_items(:unmanaged_concept, [
        { parent: "C120530", version: "2015-03-27", identifier: "C28224" },
        { parent: "C120530", version: "2015-03-27", identifier: "C14175" }
      ], 'add-children')
      wait_for_ajax 10
      ui_check_table_info "editor", 1, 4, 4

      ui_editor_select_by_content "FOCAL"
      ui_editor_check_disabled "notation"

      ui_editor_select_by_location 4, 5
      ui_editor_check_disabled "definition"
    end

    it "allows to add a reference to a Sponsor Code List Item, prevents edit" do
      go_to_cl_edit "NP000010P"

      click_on "Add items"
      ip_pick_unmanaged_items(:unmanaged_concept, [
        { parent: "A00020", version: "Incomplete", identifier: "A00021" }
      ], 'add-children')
      wait_for_ajax 10
      ui_check_table_info "editor", 1, 5, 5

      ui_editor_select_by_content "OTHER OR MIXED"
      ui_editor_check_disabled "notation"

      ui_press_key :escape
      ui_press_key :arrow_right
      ui_press_key :enter
      ui_editor_check_disabled "preferred_term"

    end

    it "allows to remove Code List Items from a Code List" do
      go_to_cl_edit "NP000010P"

      find(:xpath, "//tr[contains(.,'A00021')]/td[8]/span").click
      ui_confirmation_dialog true
      wait_for_ajax 10
      ui_check_table_info "editor", 1, 4, 4
      expect(page).not_to have_content "OTHER OR MIXED"

      find(:xpath, "//tr[contains(.,'Not Set')]/td[8]/span").click
      ui_confirmation_dialog true
      wait_for_ajax 10
      ui_check_table_info "editor", 1, 3, 3
      expect(find("#editor")).not_to have_content "Not Set"
    end

    it "allows to edit tags of a Code List Item, and refresh" do
      go_to_cl_edit "NP000010P"

      edit_tags_cell = find(:xpath, "//tr[contains(.,'The PT 999C')]/td[6]")
      w = window_opened_by { edit_tags_cell.click }
      within_window w do
        wait_for_ajax 10
        expect(page).to have_content "Edit Item Tags"
        attach_tag('SDTM')
        wait_for_ajax 10
      end

      click_on "Refresh"
      wait_for_ajax 10

      ui_check_table_cell "editor", 1, 6, "SDTM"
    end

    it "allows to open Code List Edit help dialog" do
      go_to_cl_edit "NP000010P"

      find("#editor-help").click
      ui_in_modal do
        expect(page).to have_content "How to use Code List Editor"
        click_on "Dismiss"
      end
    end

    it "token timer, warnings, extension and expiration (REQ-MDR-EL-020, REQ-MDR-EL-030)", js: true do

      token_ui_check(@user_c) do
        go_to_cl_edit "NP000010P"
      end 

    end

    it "token timer, expires edit lock, prevents changes" do

      go_to_edit = proc { go_to_cl_edit "NP000010P" }
      do_an_edit = proc do 
        ui_editor_select_by_location 1, 2
        ui_editor_fill_inline "notation", "Testing Edit Lock\n"
      end 

      token_expired_check(go_to_edit, do_an_edit)
      
    end

    it "token timer, clears token when leaving page" do

      token_clear_check do 
        go_to_cl_edit "NP000010P"
      end

    end

    it "allows a code list to be edited, manual-identifier"

    it "Code List - Edit Tags page, from Code List edit page" do
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
        expect(page).to have_content "Edit Item Tags"
      end
      w.close
    end

  end

  describe "Code List Editor, Curator User, Locked Status", type: :feature, js: true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_2.ttl", "CT_V43.ttl", "CT_ACME_TEST.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      ua_create
      Token.delete_all
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
      Token.restore_timeout
    end

    it "allows to edit a Code List in a locked state" do
      click_navbar_code_lists
      identifier = ui_new_code_list

      # Prepare Data
      context_menu_element_v2('history', identifier, :edit)
      wait_for_ajax 10

      click_on 'New item'
      wait_for_ajax 10

      ui_check_table_info('editor', 1, 1, 1)

      ui_editor_select_by_location 1, 2
      ui_editor_fill_inline 'notation', "TEST LOCKED STATE\t"
      ui_editor_check_value 1, 2, 'TEST LOCKED STATE'
      ui_press_key :enter
      ui_editor_fill_inline 'preferred_term', "Locked value\n"
      ui_editor_check_value 1, 3, 'Locked value'

      click_on 'Return'
      wait_for_ajax 10

      # Set to Recorded - locked state
      context_menu_element_v2('history', identifier, :document_control)
      wait_for_ajax 10
      dc_forward_to 'Recorded'
      click_on 'Return'
      wait_for_ajax 10

      context_menu_element_v2('history', identifier, :edit)
      wait_for_ajax 10

      ui_editor_check_value 1, 2, 'TEST LOCKED STATE'
      ui_editor_select_by_location 1, 2
      ui_editor_fill_inline 'notation', "Changing Locked Value\t"
      ui_editor_check_value 1, 2, 'Changing Locked Value'
      ui_press_key :enter
      ui_editor_fill_inline 'preferred_term', "Changing Another Locked Value\n"
      ui_editor_check_value 1, 3, 'Changing Another Locked Value'

      click_on 'New item'
      wait_for_ajax 10
      ui_check_table_info('editor', 1, 2, 2)

      click_on 'Return'
    end

  end

  describe "Status, Curator User", type: :feature, js: true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_sponsor_5_state.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..1)
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

    def th_state_update
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'State Test Terminology')]/td/a").click
      wait_for_ajax 10
      context_menu_element('history', 4, 'STATE', :document_control)
      wait_for_ajax 10
      click_on 'Forward to Next'
      wait_for_ajax 10
    end

    def unsuccesful_th_state_update(previous_state, new_state)
      th_state_update
      expect(page).to have_content 'Child items are not in the appropriate state'
      dc_check_status(previous_state, new_state)
      click_on 'Return'
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'STATE\''
      ui_check_table_cell("history", 1, 7, "#{previous_state}")
    end

    def succesful_th_state_update(previous_state, new_state)
      th_state_update
      dc_check_status(new_state)
      click_on 'Return'
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'STATE\''
      ui_check_table_cell("history", 1, 7, "#{new_state}")
    end

    def succesful_cl_state_update(identifier, previous_state, new_state)
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search('index', identifier)
      find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
      wait_for_ajax 10 
      context_menu_element_v2('history', "#{identifier}", :document_control)
      wait_for_ajax 10
      dc_check_status(previous_state, new_state)
      click_on "Forward to Next"
      wait_for_ajax 10
      dc_check_status(new_state)
      click_on 'Return'
      wait_for_ajax 10
      ui_check_table_cell("history", 1, 7, "#{new_state}")
    end

    it "history allows the status page to be viewed (REQ-MDR-ST-050)" do
      click_navbar_terminology
      wait_for_ajax 10 

      find(:xpath, "//tr[contains(.,'State Test Terminology')]/td/a").click
      wait_for_ajax 10 
      expect(page).to have_content 'Version History'
      context_menu_element_v2('history', 'State Test Terminology', :document_control)
      wait_for_ajax 10 

      dc_check_status('Incomplete', 'Candidate')
      expect(page).to have_content 'State Test Terminology'
      expect(page).to have_content '0.1.0'
      click_on 'Return'
      expect(page).to have_content 'Version History'
    end

    it "prevents updating status unless children in correct status" do
      unsuccesful_th_state_update("Incomplete", "Candidate")
      succesful_cl_state_update("A00001", "Incomplete", "Candidate")
      succesful_th_state_update("Incomplete", "Candidate")

      unsuccesful_th_state_update("Candidate", "Recorded")
      succesful_cl_state_update("A00001", "Candidate", "Recorded")
      succesful_th_state_update("Candidate", "Recorded")

      unsuccesful_th_state_update("Recorded", "Qualified")
      succesful_cl_state_update("A00001", "Recorded", "Qualified")
      succesful_th_state_update("Recorded", "Qualified")

      unsuccesful_th_state_update("Qualified", "Standard")
      succesful_cl_state_update("A00001", "Qualified", "Standard")
      succesful_th_state_update("Qualified", "Standard")
    end

    it "allows for Status updates, and multiple edit lock and unlock" do
      ui_create_terminology('TEST ME', 'Multi Edit Th')

      find(:xpath, "//tr[contains(.,'Multi Edit Th')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax 10

      dc_check_status('Incomplete', 'Candidate')
      dc_forward_to('Qualified')
      dc_check_status('Qualified', 'Standard')

      click_on 'Return'
      wait_for_ajax 10
      ui_check_table_cell('history', 1, 7, 'Qualified')
      find('.registration-state').click
      wait_for_ajax 10

      expect(page).to have_selector ('.registration-state .icon-lock-open')
      ui_check_table_info("history", 1, 1, 1)

      context_menu_element_v2('history', 'Multi Edit Th', :edit)
      wait_for_ajax 10
      click_on 'Return'
      wait_for_ajax 10

      find('.registration-state').click
      expect(page).to have_selector ('.registration-state .icon-lock')
      wait_for_ajax 10
      context_menu_element_v2('history', 'Multi Edit Th', :edit)
      wait_for_ajax 10
      click_link 'Return'

      ui_check_table_info("history", 1, 2, 2)
      context_menu_element_v2('history', 1, :document_control)

      wait_for_ajax 10 

      dc_update_version('1.0.0')

      click_on 'Return'
      wait_for_ajax 10
      ui_check_table_cell('history', 1, 1, '1.0.0')
    end

  end

  describe "Terminology CDISC CT Reference", type: :feature, js: true do

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

    it "recognizes CDISC CT reference in a sponsor Terminology" do
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
