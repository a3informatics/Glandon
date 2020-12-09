require 'rails_helper'

describe "Scenario 9 - Terminology Release, Clone, Impact and Upgrade", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include UserAccountHelpers
  include ScenarioHelpers
  include TagHelpers
  include D3TreeHelpers
  include NameValueHelpers
  include EditorHelpers
  include ItemsPickerHelpers

  def sub_dir
    return "features/scenarios"
  end

  def click_row_contains(table, text)
    ui_table_search(table, text)
    find(:xpath, "//*[@id='#{table}']/tbody/tr[contains(.,'#{text}')]").click
    ui_table_search(table, '')
  end

  def change_cdisc_version(version)
    page.find('.card-with-tabs .expandable-content-btn').click
    sleep 0.5
    ui_dashboard_single_slider version
    click_button 'Submit selected version'
    ui_confirmation_dialog true if page.has_text? "Are you sure you want to proceed?"
    wait_for_ajax 20
  end

  describe "Curator User", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      nv_destroy
      nv_create({parent: "10", child: "999"})
      Token.destroy_all
      ua_create
      set_transactional_tests false
    end

    after :all do
      ua_destroy
      set_transactional_tests true
    end

    it "Prepares a tag, system admin", scenario: true, js: true do
      ua_sys_and_content_admin_login
      go_to_tags
      create_tag('Tags', 'TstTag', 'Tag for Test')
      ua_logoff
    end

    it "Build Terminology Release, Clone and Upgrade", scenario: true, js: true do
      ua_curator_login

      # Create Thesaurus
      ui_create_terminology("TST", "Test Terminology")

      # Edit Thesaurus, set reference
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 10
      change_cdisc_version "2017-09-29"
      click_link "Return"
      wait_for_ajax 10

      # Create an Extension
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "Epoch")
      find(:xpath, "//tr[contains(.,'CDISC')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "2017-06-30", :show)
      wait_for_ajax 10
      context_menu_element_header(:extend)
      ip_pick_managed_items(:thesauri, [{identifier: "TST", version: "1"}], "thesaurus")
      wait_for_ajax 10

      # Edit Extension, Add items
      click_on "Add items"
      ip_pick_unmanaged_items(:unmanaged_concept, [
        { parent: "C99074", version: "2017-06-30", identifier: "C98798" },
        { parent: "C99074", version: "2017-06-30", identifier: "C94393" }
      ], "add-children")

      wait_for_ajax 10

      # Edit Extension, Add a tag
      w = window_opened_by { context_menu_element_header(:edit_tags) }
      within_window w do
        wait_for_ajax 10
        attach_tag "TstTag"
      end
      w.close
      click_on "Return"
      wait_for_ajax 10

      # Document Control, Make Extension Standard
      context_menu_element_v2("history", "0.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_link "Return"
      wait_for_ajax 10

      # Create a Subset
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "Anatomical")
      find(:xpath, "//tr[contains(.,'CDISC')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "2019-06-28", :show)
      wait_for_ajax 10
      context_menu_element_header(:subsets)
      ui_in_modal do
        click_on "+ New Subset"
      end
      ui_in_modal do
        click_on "Do not select"
      end
      wait_for_ajax 20

      # Edit Subset - Add items
      click_row_contains("source-table", "ABDOMINAL CAVITY")
      wait_for_ajax 10
      click_row_contains("source-table", "C139186")
      wait_for_ajax 10

      # Edit Subset - Update properties
      context_menu_element_header(:edit_properties)
      ui_in_modal do
        fill_in "preferred_term", with: "Anatomical Location Subset 1"
        fill_in "notation", with: "ANATOMICAL LOC SUBSET"
        fill_in "synonym", with: "Synonym1; And Number 2"
        click_on "Save changes"
      end
      wait_for_ajax 10
      click_link "Return"
      wait_for_ajax 10

      # Document Control, Make Subset Standard
      context_menu_element_v2("history", "0.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_link "Return"
      wait_for_ajax 10


      # New Code List
      click_navbar_code_lists
      wait_for_ajax 20
      cl_identifier = ui_new_code_list
      context_menu_element('history', 4, cl_identifier, :edit)
      wait_for_ajax 10
      click_on 'New item'
      wait_for_ajax 10
      ui_editor_select_by_location(1,2)
      ui_editor_fill_inline "notation", "SPONSOR CL\t"
      ui_editor_select_by_location(1,3)
      ui_editor_fill_inline "preferred_term", "Some Sponsor Code List\n"
      ui_editor_select_by_location(1,5)
      ui_editor_fill_inline "definition", "And of course, a definition\n"
      wait_for_ajax 5
      click_link "Return"
      wait_for_ajax 10

      # Document Control, Make CL Standard, Add Version Label
      context_menu_element_v2("history", "0.1.0", :document_control)

      page.find('#version-label-edit').click
      fill_in 'iso_scoped_identifier[version_label]', with: 'Standard Version Label'
      page.find('#version-label-submit').click

      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"

      click_link "Return"
      wait_for_ajax 10

      # Create a Subset of a Sponsor Extension
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "Epoch")
      find(:xpath, "//tr[contains(.,'ACME')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :show)
      wait_for_ajax 10
      context_menu_element_header(:subsets)
      ui_in_modal do
        click_on "+ New Subset"
      end
      ui_in_modal do
        click_on "Do not select"
      end
      wait_for_ajax 20

      # Edit Subset - Add items
      click_row_contains("source-table", "VENTROLATERAL")
      wait_for_ajax 10
      click_row_contains("source-table", "Baseline Epoch")
      wait_for_ajax 10
      click_row_contains("source-table", "C94393")
      wait_for_ajax 10

      # Edit Subset - Update properties
      context_menu_element_header(:edit_properties)
      ui_in_modal do
        fill_in "notation", with: "SPONSOR SUBSET"
        click_button "Save changes"
      end
      wait_for_ajax 10
      click_link "Return"
      wait_for_ajax 10

      # Document Control, Make Subset Standard
      context_menu_element_v2("history", "0.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_link "Return"
      wait_for_ajax 10

      # Edit Thesaurus, add items
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 20
      click_row_contains("table-cdisc-cls", "Epoch")
      wait_for_ajax 10
      click_row_contains("table-cdisc-cls", "C99073")
      wait_for_ajax 10
      ui_click_tab "Sponsor CLs"
      wait_for_ajax 10
      click_row_contains("table-sponsor-cls", cl_identifier)
      wait_for_ajax 10
      ui_click_tab "Sponsor Subsets"
      wait_for_ajax 10
      page.find("#table-sponsor-subsets-bulk-select").click
      wait_for_ajax 10
      click_link "Return"
      wait_for_ajax 10

      # Document Control, Make Thesaurus Standard
      context_menu_element_v2("history", "0.1.0", :document_control)

      page.find('#version-label-edit').click
      fill_in 'iso_scoped_identifier[version_label]', with: 'Standard Test TH'
      page.find('#version-label-submit').click

      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"

      click_link "Return"
      wait_for_ajax 10

      # Clone Thesaurus
      context_menu_element('history', 8, 'Standard Test TH', :clone)
      ui_in_modal do
        fill_in 'thesauri_identifier', with: "CLONE"
        fill_in 'thesauri_label', with: "Cloned Terminology"
        click_button 'Submit'
      end

      # Change CDISC Reference
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'Cloned Terminology')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 20
      change_cdisc_version("2019-12-20")

      # Upgrade Terms
      context_menu_element_header :upgrade
      wait_for_ajax 20
      expect(page).to have_content("Upgrade Code Lists CLONE v0.1.0")

      # Checks if filtering corrent - Subset and Extensions affected only
      click_row_contains("changes-cdisc-table", "Laterality")
      wait_for_ajax 10
      expect(page).to have_content "No affected items found"

      # Upgrade Subset
      click_row_contains("changes-cdisc-table", "Anatomical Location")
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'Subset')]/td/button").click
      wait_for_ajax 20
      expect(page).to have_content "Item was successfully upgraded"
      expect(find(:xpath, "//tr[contains(.,'Subset')]/td/button").text).to eq("Cannot upgrade")

      # Verify Upgrade Inclusion
      click_link "Return"
      wait_for_ajax 20
      ui_click_tab "Cloned Terminology"
      ui_check_table_cell("table-selection-overview", 3, 6, "0.2.0")
      ui_check_table_row_indicators("table-selection-overview", 3, 8, ["2 versions", "subset"])

      context_menu_element_header :upgrade
      wait_for_ajax 20

      # Upgrade Extension and Subset of Extension
      click_row_contains("changes-cdisc-table", "Epoch")
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'Subset')]/td/button").click
      wait_for_ajax 10
      expect(page).to have_content "Cannot upgrade. You must first upgrade the referenced code list"
      find(:xpath, "//tr[contains(.,'Extension')]/td/button").click
      wait_for_ajax 20
      expect(page).to have_content "Item was successfully upgraded"

      expect(find(:xpath, "//tr[contains(.,'Extension')]/td/button").text).to eq("Cannot upgrade")

      sleep 5

      find(:xpath, "//tr[contains(.,'Subset')]/td/button").click
      wait_for_ajax 20
      expect(page).to have_content "Item was successfully upgraded"
      expect(find(:xpath, "//tr[contains(.,'Subset')]/td/button").text).to eq("Cannot upgrade")

      ua_logoff
    end

  end

  describe "Curator User", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      nv_destroy
      nv_create({parent: "10", child: "999"})
      Token.destroy_all
      ua_create
    end

    after :all do
      Token.destroy_all
      ua_destroy
    end

    it "Upgrade of a Subset of an Extension, prevents upgrade of Subset before Extension. Status: Incomplete, WILL CURRENTLY FAIL", scenario: true, js: true do
      ua_curator_login

      # Create Thesaurus
      ui_create_terminology("TST2", "Test Terminology 2")

      # Edit Thesaurus, set reference
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'Test Terminology 2')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 10
      change_cdisc_version "2017-09-29"
      click_link "Return"
      wait_for_ajax 10

      # Create an Extension
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "Epoch")
      find(:xpath, "//tr[contains(.,'CDISC')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "2017-06-30", :show)
      wait_for_ajax 10
      context_menu_element_header(:extend)

      ip_pick_managed_items(:thesauri, [{identifier: "TST2", version: "1"}], "thesaurus")

      # Create a Subset of a Sponsor Extension
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "Epoch")
      find(:xpath, "//tr[contains(.,'ACME')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :show)
      wait_for_ajax 10
      context_menu_element_header(:subsets)
      ui_in_modal do
        click_on "+ New Subset"
      end
      ip_pick_managed_items(:thesauri, [{identifier: "TST2", version: "1"}], "thesaurus")

      wait_for_ajax 20

      # Edit Subset - Add items
      click_row_contains("source-table", "Baseline Epoch")
      wait_for_ajax 10
      click_row_contains("source-table", "C99158")
      wait_for_ajax 10

      click_link "Return"
      wait_for_ajax 10

      # Edit Thesaurus, add items
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'Test Terminology 2')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 20
      change_cdisc_version("2019-12-20")

      # Upgrade Terms
      context_menu_element_header :upgrade
      wait_for_ajax 20
      click_row_contains("changes-cdisc-table", "Epoch")
      wait_for_ajax 10

      find(:xpath, "//tr[contains(.,'Subset')]/td/button").click
      wait_for_ajax 10
      expect(page).to have_content "Cannot upgrade. You must first upgrade the referenced code list"
      find(:xpath, "//tr[contains(.,'Extension')]/td/button").click
      wait_for_ajax 20
      expect(page).to have_content "Item was successfully upgraded"
      expect(find(:xpath, "//tr[contains(.,'Extension')]/td/button").text).to eq("Cannot upgrade")

      sleep 5

      find(:xpath, "//tr[contains(.,'Subset')]/td/button").click
      wait_for_ajax 20
      expect(page).to have_content "Item was successfully upgraded"
      expect(find(:xpath, "//tr[contains(.,'Subset')]/td/button").text).to eq("Cannot upgrade")

      ua_logoff
    end

  end

end
