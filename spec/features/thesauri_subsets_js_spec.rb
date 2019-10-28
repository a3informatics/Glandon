require 'rails_helper'

describe "Thesauri", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  describe "The Content Admin User can", :type => :feature do

    before :all do
      data_files = ["CT_SUBSETS.ttl", "thesaurus_new_airports.ttl", "iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      # clear_iso_concept_object
      # clear_iso_namespace_object
      # clear_iso_registration_authority_object
      # clear_iso_registration_state_object
      ua_create
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
      
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      # NameValue.destroy_all
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
    end

    # PROBLEM WITH TERMINOLOGY LOAD DIFFERENT ONE
    it "adds a new subset (REQ-MDR-?????)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      expect(page).to have_content '2010-03-05 Release'
      find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      expect(page).to have_content("PKUNIT")
      click_link "Subsets"
      wait_for_ajax(120)
      expect(page).to have_content("No subsets found.")
      click_button "+ New subset"
      expect(page).to have_content("Select Terminology")
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      wait_for_ajax(120)
      click_button 'Select'
      wait_for_ajax(120)
      expect(page).to have_content("Edit Subset")
    end


  end

end
