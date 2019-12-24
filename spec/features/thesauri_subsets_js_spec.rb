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
      ui_check_table_cell("ssIndexTable", 1, 2, "S000001")
      ui_check_table_cell("ssIndexTable", 2, 2, "S000002")
      click_button "Close"
      sleep 1
    end

    it "adds a new subset (REQ-MDR-?????)", js:true do
      audit_count = AuditTrail.count
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      expect(page).to have_content '2010-03-05 Release'
      find(:xpath, "//tr[contains(.,'C85495')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      expect(page).to have_content("MSRESCAT")
      context_menu_element_header(:subsets)
      expect(page).to have_content("No subsets found.")
      click_button "+ New subset"
      expect(page).to have_content("Select Terminology")
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button "Select"
      wait_for_ajax(10)
      expect(page).to have_content("Edit Subset")
      expect(AuditTrail.count).to eq(audit_count+1)
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
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)
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
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)
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
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)
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
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)
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
      wait_for_ajax(10)
      expect(page).to have_content("No subsets found.")
      click_button "+ New subset"
      wait_for_ajax(10)
      expect(page).to have_content("Select Terminology")
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button "Select"
      wait_for_ajax(10)
      expect(page).to have_content("Preferred term: Not Set")
      click_link "Edit properties"
      fill_in "edit_preferred_term", with: "Term 1"
      click_button "Submit"
      wait_for_ajax(120)
      expect(page).to have_content("Preferred term: Term 1")
      expect(AuditTrail.count).to eq(audit_count+2)
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
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)

      expect(page).to have_content 'Error raised editting a subset. Can only handle draft versions in this release.'

      # wait_for_ajax(10)
      # sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      # page.find("#imh_header")[:class].include?("warning")
      # page.find("#timeout").click
      # wait_for_ajax(120)
      # expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
      # sleep Token.get_timeout - (@user_c.edit_lock_warning.to_i / 2) + 2
      # page.find("#imh_header")[:class].include?("danger")
      # sleep 28
      # page.find("#timeout")[:class].include?("disabled")
      # page.find("#imh_header")[:class].include?("danger")
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
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)

      expect(page).to have_content 'Error raised editting a subset. Can only handle draft versions in this release.'

      # wait_for_ajax(120)
      # find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      # wait_for_ajax(120)
      # ui_check_table_cell("subset_children_table", 4, 2, "Day Times Femtogram per Milliliter\nday*fg/mL (C85583)")
      # ui_check_table_cell("subset_children_table", 3, 2, "Day Times Mole per Milliliter\nday*mol/mL (C85590)")
      # source = page.find(:xpath, "//*[@id='subset_children_table']/tbody/tr[1]")
      # target = page.find(:xpath, "//*[@id='subset_children_table']/tbody/tr[2]")
      # source.drag_to(target)
      # wait_for_ajax(10)
      # ui_check_table_cell("subset_children_table", 2, 2, "Day Times Gram per Milliliter\nday*g/mL (C85584)")
      # find(:xpath, "//*[@id='source_children_table']/tbody/tr[4]/td").click
      # find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      # wait_for_ajax(10)
      # ui_check_table_cell("subset_children_table", 4, 2, "Day Times Microgram per Milliliter\nday*ug/mL (C85586)")
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
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)
      
      expect(page).to have_content 'Error raised editting a subset. Can only handle draft versions in this release.'

      # sleep 13
      # find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      # expect(page).to have_content("The edit lock has timed out.")
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
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)

      expect(page).to have_content 'Error raised editting a subset. Can only handle draft versions in this release.'

      # expect(page).to have_content 'Edit Subset'
      # tokens = Token.where(item_uri: "http://www.s-cubed.dk/S123/V19#S123")
      # token = tokens[0]
      # click_link 'Return'
      # tokens = Token.where(item_uri: "http://www.s-cubed.dk/S123/V19#S123")
      # expect(tokens).to match_array([])
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
