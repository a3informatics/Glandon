require 'rails_helper'

describe "ISO Concept JS", :type => :feature do

  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

  before :all do

    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
      "BusinessOperational.ttl", "BusinessForm.ttl", "CDISCBiomedicalConcept.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BC.ttl", "form_example_vs_baseline.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..42)
    clear_iso_concept_object
    ua_create
  end

  after :all do
    ua_destroy
  end

  describe "Curator User", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows the metadata graph to be viewed", js: true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC A00003')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC A00003'
      find(:xpath, "//tr[contains(.,'BC A00003')]/td/a", :text => 'Gr+').click
      expect(page).to have_content 'Graph:'
      expect(page).to have_button('graph_focus', disabled: true)
      #expect(page).to have_field('concept_type', disabled: true) # No longer part of view
      #expect(page).to have_field('concept_label', disabled: true) # No longer part of view
      click_button 'graph_stop'
      expect(page).to have_button('graph_focus', disabled: false)
    end

    it "allows a impact page to be displayed", js: true do
      click_navbar_cdisc_terminology
      pause
      ui_check_page_has('Item History')
      ui_check_page_has('Controlled Terminology')
      context_menu_element("history", 1, "42.0.0", :show)
      ui_check_page_has('Controlled Terminology')
      ui_check_page_has('2015-03-27')
      ui_main_search("VSTESTCD")
      ui_table_row_link_click('VSTESTCD', 'Show')
      ui_check_page_has('Show: Vital Signs Test Code C66741')
      ui_main_search("HR")
      ui_table_row_link_click('C49677', 'Impact')
      ui_check_page_has('Impact Analysis: Heart Rate')
    	wait_for_ajax(10)
      ui_check_table_row('managed_item_table', 1, ["BC C49677", "Heart Rate (BC C49677)", "1.0.0", "0.1"])
      ui_check_table_row('managed_item_table', 2, ["CDISC Terminology", "CDISC Terminology 2015-09-25", "42.0.0", "2015-09-25"])
      ui_check_table_row('thesaurus_concept_table', 1, ["C66741", "C49677", "HR", "Heart Rate", "Heart Rate"])
      click_button 'close'
      ui_check_page_has('Show: Vital Signs Test Code C66741')
      ui_main_search("HR")
      ui_table_row_link_click('C49677', 'Impact')
      ui_check_page_has('Impact Analysis: Heart Rate')
      ui_table_row_link_click('BC C49677', 'Show')
      ui_check_page_has("Show: Heart Rate (BC C49677)")
    end

    it "allows a impact graph to be clicked"

  end

end
