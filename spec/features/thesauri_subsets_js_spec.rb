require 'rails_helper'

describe "Thesauri Subsets", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  def sub_dir
    return "features/thesaurus/subset"
  end

  describe "Subsets Draft State", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_subsets_1.ttl", "thesaurus_subsets_2.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      load_local_file_into_triple_store(sub_dir, "subsets_input_4.ttl")
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
      ua_create
      Token.delete_all
    end

    after :all do
      ua_destroy
    end

    before :each do
      Token.restore_timeout
      ua_content_admin_login
    end

    after :each do
      ua_logoff
    end

    it "index subsets (REQ-MDR-?????)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(120)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(120)
      expect(page).to have_content '2010-03-05 Release'
      ui_child_search("C66726")
      wait_for_ajax(120)
      ui_check_table_info('children_table', 1, 1, 1)
      find(:xpath, "//tr[contains(.,'C66726')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      expect(page).to have_content("CDISC SDTM Pharmaceutical Dosage Form Terminology")
      context_menu_element_header(:subsets)
      sleep 1
      ui_check_table_cell("subsets-index-table", 1, 1, "S000001")
      ui_check_table_cell("subsets-index-table", 2, 1, "S000002")
      click_button "Close"
      sleep 1
    end

    it "adds a new subset, terminology selected (REQ-MDR-?????)", js:true do
      audit_count = AuditTrail.count
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      expect(page).to have_content '2010-03-05 Release'
      find(:xpath, "//tr[contains(.,'C85495')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      expect(page).to have_content("MSRESCAT")
      context_menu_element_header(:subsets)
      sleep 1
      expect(page).to have_content("No subsets found.")
      click_button "+ New subset"
      sleep 1
      expect(page).to have_content("Pick a Terminology")
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button "Select"
      wait_for_ajax(10)
      sleep 1
      expect(page).to have_content("Edit Subset")
      expect(AuditTrail.count).to eq(audit_count+1)
    end

    it "adds a new subset, Do not select terminology (REQ-MDR-?????)", js:true do
      audit_count = AuditTrail.count
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      expect(page).to have_content '2010-03-05 Release'
      find(:xpath, "//tr[contains(.,'C85495')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      expect(page).to have_content("MSRESCAT")
      context_menu_element_header(:subsets)
      sleep 1
      click_button "+ New subset"
      sleep 1
      expect(page).to have_content("Pick a Terminology")
      click_button "Do not select"
      wait_for_ajax(10)
      sleep 1
      expect(page).to have_content("Edit Subset")
      expect(AuditTrail.count).to eq(audit_count+1)
    end

    it "allows to access the edit subset page", js:true do
      click_navbar_code_lists
      wait_for_ajax
      ui_table_search("index", "S123")
      find(:xpath, "//tr[contains(.,'PK unit')]/td/a").click
      wait_for_ajax
      context_menu_element("history", 5, "2010-03-05 Release", :edit)
      wait_for_ajax(10)
      expect(page).to have_content("C85494")
      expect(page).to have_content("Edit Subset")
      expect(page).to have_content("Preferred term: PK unit")
    end

    it "allows to edit a subset, add, remove and move_after item", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(7)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(120)
      expect(page).to have_content '2010-03-05 Release'
      wait_for_ajax(10)
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      context_menu_element_header(:subsets)
      sleep 1
      context_menu_element("subsets-index-table", 3, "PK Parameter Units of Measure", :edit)
      wait_for_ajax(120)
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      wait_for_ajax(120)
      ui_check_table_cell("subset_children_table", 4, 2, "Day Times Femtogram per Milliliter\nday*fg/mL (C85583)")
      ui_check_table_cell("subset_children_table", 3, 2, "Day Times Mole per Milliliter\nday*mol/mL (C85590)")
      source = page.find(:xpath, "//*[@id='subset_children_table']/tbody/tr[1]")
      target = page.find(:xpath, "//*[@id='subset_children_table']/tbody/tr[2]")
      source.drag_to(target)
      wait_for_ajax(10)
      ui_check_table_cell("subset_children_table", 1, 2, "Day Times Gram per Milliliter\nday*g/mL (C85584)")
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[4]/td").click
      wait_for_ajax(10)
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      wait_for_ajax(10)
      ui_check_table_cell("subset_children_table", 4, 2, "Day Times Microgram per Milliliter\nday*ug/mL (C85586)")
    end

    it "selects and deselects all items", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      expect(page).to have_content '2010-03-05 Release'
      find(:xpath, "//tr[contains(.,'C85495')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      expect(page).to have_content("MSRESCAT")
      context_menu_element_header(:subsets)
      sleep 1
      context_menu_element("subsets-index-table", 3, "NP", :edit)
      wait_for_ajax(120)
      page.find("#deselect-all-button").click
      wait_for_ajax(120)
      expect(page).to have_content("This subset is empty.")
      ui_check_table_info("subset_children_table", 0, 0, 0)
      page.find("#select-all-button").click
      wait_for_ajax(120)
      ui_check_table_info("subset_children_table", 1, 7, 7)
    end

    it "edit timeout warnings and extend", js:true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2010-03-05 Release'
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      context_menu_element_header(:subsets)
      context_menu_element("subsets-index-table", 3, "PK Parameter Units of Measure", :edit)
      wait_for_ajax(10)
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
    end

    it "prevents add, remove and move item in subset, when token expires", js:true do
      Token.set_timeout(10)
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2010-03-05 Release'
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      context_menu_element_header(:subsets)
      context_menu_element("subsets-index-table", 3, "PK Parameter Units of Measure", :edit)
      sleep 13
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      expect(page).to have_content("The edit lock has timed out.")
    end

    it "clears token when leaving page", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(7)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(120)
      expect(page).to have_content '2010-03-05 Release'
      wait_for_ajax(10)
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      context_menu_element_header(:subsets)
      sleep 1
      context_menu_element("subsets-index-table", 3, "PK Parameter Units of Measure", :edit)
      expect(page).to have_content 'Edit Subset'
      tokens = Token.where(item_uri: "http://www.s-cubed.dk/S123/V19#S123")
      token = tokens[0]
      click_link 'Return'
      tokens = Token.where(item_uri: "http://www.s-cubed.dk/S123/V19#S123")
      expect(tokens).to match_array([])
    end

    it "edits properties of a subset MC in edit subset", js:true do
      audit_count = AuditTrail.count
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2009-10-06 Release", :show)
      wait_for_ajax(120)
      find(:xpath, "//tr[contains(.,'C78737')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      context_menu_element_header(:subsets)
      sleep 1
      expect(page).to have_content("No subsets found.")
      click_button "+ New subset"
      sleep 1
      expect(page).to have_content("Pick a Terminology")
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button "Select"
      wait_for_ajax(10)
      expect(page).to have_content("Preferred term: Not Set")
      context_menu_element_header(:edit_properties)
      sleep 1
      fill_in "preferred_term", with: "Term 1"
      click_button "Save changes"
      wait_for_ajax(120)
      sleep 1
      expect(page).to have_content("Preferred term: Term 1")
      expect(AuditTrail.count).to eq(audit_count+2)
    end

    it "edits tags of a subset MC in edit subset", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2009-10-06 Release", :show)
      wait_for_ajax(120)
      find(:xpath, "//tr[contains(.,'C78737')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      context_menu_element_header(:subsets)
      sleep 1
      click_button "+ New subset"
      sleep 1
      expect(page).to have_content("Pick a Terminology")
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button "Select"
      wait_for_ajax(10)
      expect(context_menu_element_header_present?(:edit_tags)).to eq(true)
      w = window_opened_by { context_menu_element_header(:edit_tags) }
      within_window w do
        wait_for_ajax(10)
        expect(page).to have_content "Attach / Detach Tags"
      end
      w.close
    end


    it "can refresh page while editing in a locked state, creates new version", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax 30
      context_menu_element("history", 5, "20.0.0", :show)
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'C87162')]/td/a", :text => 'Show').click
      wait_for_ajax 10
      context_menu_element_header(:subsets)
      sleep 1
      wait_for_ajax 10
      click_on "+ New subset"
      sleep 2
      click_on "Do not select"
      sleep 1
      click_link "Return"
      wait_for_ajax 10
      ui_check_table_info("history", 1, 1, 1)
      context_menu_element("history", 5, "0.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_link "Return"
      wait_for_ajax 10
      ui_check_table_info("history", 1, 1, 1)
      context_menu_element("history", 8, "0.1.0", :edit)
      expect(page).to have_content("Edit Subset")
      page.driver.browser.navigate.refresh
      expect(page).to have_content("Edit Subset")
      page.go_back
      wait_for_ajax 20
      ui_check_table_info("history", 1, 3, 3)
    end

  end

  describe "Subsets Released State", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_subsets_1.ttl", "thesaurus_subsets_3.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      load_local_file_into_triple_store(sub_dir, "subsets_input_4.ttl")
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
      ua_create
      Token.delete_all
    end

    after :all do
      ua_destroy
    end

    before :each do
      Token.restore_timeout
      ua_content_admin_login
    end

    after :each do
      ua_logoff
    end

    it "allows to edit a subset, add, remove and move_after item, WILL CURRENTLY FAIL (Drag-n-drop)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(7)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(120)
      expect(page).to have_content '2010-03-05 Release'
      wait_for_ajax(10)
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      context_menu_element_header(:subsets)
      sleep 1
      context_menu_element("subsets-index-table", 3, "PK Parameter Units of Measure", :edit)
      wait_for_ajax(120)
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      wait_for_ajax(120)
      ui_check_table_cell("subset_children_table", 3, 2, "Day Times Mole per Milliliter\nday*mol/mL (C85590)")
      ui_check_table_cell("subset_children_table", 4, 2, "Day Times Femtogram per Milliliter\nday*fg/mL (C85583)")
      source = page.find(:xpath, "//*[@id='subset_children_table']/tbody/tr[1]")
      target = page.find(:xpath, "//*[@id='subset_children_table']/tbody/tr[2]")
      source.drag_to(target)
      wait_for_ajax(10)
      ui_check_table_cell("subset_children_table", 1, 2, "Day Times Gram per Milliliter\nday*g/mL (C85584)")
      ui_check_table_cell("subset_children_table", 2, 2, "Day Times Kilogram per Milliliter\nday*kg/mL (C85585)")
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[4]/td").click
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      wait_for_ajax(10)
      ui_check_table_cell("subset_children_table", 4, 2, "Day Times Microgram per Milliliter\nday*ug/mL (C85586)")
    end

    it "prevents add, remove and move item in subset, when token expires", js:true do
      Token.set_timeout(10)
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2010-03-05 Release'
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      context_menu_element_header(:subsets)
      sleep 1
      context_menu_element("subsets-index-table", 3, "PK Parameter Units of Measure", :edit)

      sleep 13
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      expect(page).to have_content("The edit lock has timed out.")
    end

    it "clears token when leaving page", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(7)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(120)
      expect(page).to have_content '2010-03-05 Release'
      wait_for_ajax(10)
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      context_menu_element_header(:subsets)
      sleep 1
      context_menu_element("subsets-index-table", 3, "PK Parameter Units of Measure", :edit)
      expect(page).to have_content 'Edit Subset'
      tokens = Token.where(item_uri: "http://www.s-cubed.dk/S123/V19#S123")
      token = tokens[0]
      click_link 'Return'
      tokens = Token.where(item_uri: "http://www.s-cubed.dk/S123/V19#S123")
      expect(tokens).to match_array([])
    end

  end

  describe "The Community Reader", :type => :feature do

    before :all do
      ua_create
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_subsets_1.ttl", "thesaurus_subsets_3.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      Token.restore_timeout
    end

    after :all do
      ua_destroy
    end

    it "hides Subsets button from MC show page", js:true do
      ua_community_reader_login
      click_browse_every_version
      wait_for_ajax(10)
      expect(page).to have_content 'Item History'
      context_menu_element("history", 5, "2009-10-06 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2009-10-06 Release'
      find(:xpath, "//tr[contains(.,'C78738')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      expect(page).to have_content 'C78738'
      Capybara.ignore_hidden_elements = false
      expect(page).to_not have_link 'Subsets'
      Capybara.ignore_hidden_elements = true
      ua_logoff
    end

  end

end
