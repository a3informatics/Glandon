require 'rails_helper'

describe "Thesauri", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  def sub_dir
    return "features/thesaurus/subset"
  end

  describe "The Content Admin User can", :type => :feature do

    before :all do
      data_files = ["CT_SUBSETS.ttl", "CT_SUBSETS_new.ttl", "iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      load_local_file_into_triple_store(sub_dir, "subsets_input_4.ttl")
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
      ua_create
      Token.delete_all
    end

    before :each do
      Token.restore_timeout
      ua_content_admin_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

     #Index subsets
    it "index subsets (REQ-MDR-?????)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(7)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(120)
      expect(page).to have_content '2010-03-05 Release'
      wait_for_ajax
      ui_child_search("C66726")
      ui_check_table_info('children_table', 1, 1, 1)
      find(:xpath, "//tr[contains(.,'C66726')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      expect(page).to have_content("CDISC SDTM Pharmaceutical Dosage Form Terminology")
      expect(page).to have_link("Subsets")
      click_link "Subsets"
      ui_check_table_cell("ssIndexTable", 1, 2, "S000001")
      ui_check_table_cell("ssIndexTable", 2, 2, "S000002")
      click_button "Close"
      wait_for_ajax
    end

    it "adds a new subset (REQ-MDR-?????)", js:true do
      audit_count = AuditTrail.count
      click_navbar_cdisc_terminology
      wait_for_ajax
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      expect(page).to have_content '2010-03-05 Release'
      find(:xpath, "//tr[contains(.,'C85495')]/td/a", :text => 'Show').click
      wait_for_ajax
      expect(page).to have_content("MSRESCAT")
      click_link "Subsets"
      expect(page).to have_content("No subsets found.")
      click_button "+ New subset"
      expect(page).to have_content("Select Terminology")
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button "Select"
      wait_for_ajax
      expect(page).to have_content("Edit Subset")
      expect(AuditTrail.count).to eq(audit_count+1)
    end

    it "edit timeout warnings and extend", js:true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      click_navbar_cdisc_terminology
      wait_for_ajax
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax
      expect(page).to have_content '2010-03-05 Release'
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax
      expect(page).to have_link("Subsets")
      click_link "Subsets"
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)
      wait_for_ajax
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#imh_header")[:class].include?("warning")
      page.find("#timeout").click
      expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
      sleep Token.get_timeout - (@user_c.edit_lock_warning.to_i / 2) + 2
      page.find("#imh_header")[:class].include?("danger")
      sleep 28
      page.find("#timeout")[:class].include?("disabled")
      page.find("#imh_header")[:class].include?("danger")
    end

    it "allows to access the edit subset page (from CT edit)", js:true do
      click_navbar_terminology
      wait_for_ajax
      find(:xpath, "//tr[contains(.,'SUBSETPK')]/td/a", :text => 'History').click
      wait_for_ajax
      context_menu_element("history", 5, "2010-03-05 Release", :edit)
      wait_for_ajax
      find(:xpath, "//tr[contains(.,'PKUNIT')]/td/a", :text => 'Edit').click
      expect(page).to have_content("Edit Subset")
      expect(page).to have_content("Preferred term: PK unit")
    end

    it "allows to edit a subset, add, remove and move_after item", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(7)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(120)
      expect(page).to have_content '2010-03-05 Release'
      wait_for_ajax
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      expect(page).to have_link("Subsets")
      click_link "Subsets"
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      wait_for_ajax
      ui_check_table_cell("subset_children_table", 4, 2, "Day Times Femtogram per Milliliter\nday*fg/mL (C85583)")
      ui_check_table_cell("subset_children_table", 3, 2, "Day Times Mole per Milliliter\nday*mol/mL (C85590)")
      source = page.find(:xpath, "//*[@id='subset_children_table']/tbody/tr[2]")
      target = page.find(:xpath, "//*[@id='source_children_table']/tbody/tr[3]")
      source.drag_to(target)
      wait_for_ajax
      ui_check_table_cell("subset_children_table", 2, 2, "Day Times Mole per Milliliter\nday*mol/mL (C85590)")
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[4]/td").click
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      wait_for_ajax
      ui_check_table_cell("subset_children_table", 4, 2, "Day Times Microgram per Milliliter\nday*ug/mL (C85586)")
    end

    it "prevents add, remove and move item in subset, when token expires", js:true do
      Token.set_timeout(10)
      click_navbar_cdisc_terminology
      wait_for_ajax
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax
      expect(page).to have_content '2010-03-05 Release'
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax
      expect(page).to have_link("Subsets")
      click_link "Subsets"
      context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)
      sleep 11
      find(:xpath, "//*[@id='source_children_table']/tbody/tr[1]/td").click
      expect(page).to have_content("The edit lock has timed out.")
    end

    it "clears token when leaving page", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(7)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      wait_for_ajax(120)
      expect(page).to have_content '2010-03-05 Release'
      wait_for_ajax
      ui_child_search("C85494")
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      expect(page).to have_link("Subsets")
      click_link "Subsets"
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
      wait_for_ajax
      context_menu_element("history", 5, "2009-10-06 Release", :show)
      wait_for_ajax
      find(:xpath, "//tr[contains(.,'C78737')]/td/a", :text => 'Show').click
      wait_for_ajax
      click_link "Subsets"
      expect(page).to have_content("No subsets found.")
      click_button "+ New subset"
      expect(page).to have_content("Select Terminology")
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button "Select"
      wait_for_ajax
      expect(page).to have_content("Preferred term: Not Set")
      click_link "Edit properties"
      fill_in "edit_preferred_term", with: "Term 1"
      click_button "Submit"
      expect(page).to have_content("Preferred term: Term 1")
      expect(AuditTrail.count).to eq(audit_count+2)
    end


  end

end
