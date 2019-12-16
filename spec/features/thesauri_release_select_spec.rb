require 'rails_helper'

describe "Thesauri Release Select", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  describe "The Curator User can", :type => :feature, js:true do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "CDISCTerm.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl", "thesaurus_concept_new_2.ttl", "CT_ACME_TEST.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..46)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      # NameValue.destroy_all
      # NameValue.create(name: "thesaurus_parent_identifier", value: "10")
      # NameValue.create(name: "thesaurus_child_identifier", value: "999")
      Token.delete_all
      ua_create
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

    it "display the release select page, initial state", :type => :feature do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element('history', 4, 'CDISC Extensions', :edit)
      wait_for_ajax(10)
      click_link 'Release select'
      expect(page).to have_content("Find & Select Code Lists")
      expect(page).to have_content("CDISC version used: None")
      expect(page).to have_content("No items were found.")
      expect(page).to have_css(".tab-option.disabled", count: 4)
      page.find(".card-with-tabs .show-more-btn").click
      expect(page).to have_content("Select CDISC Terminology version by dragging the slider")
    end

    it "select a CDISC version", :type => :feature do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, '//tr[contains(.,"CDISC EXT")]/td/a').click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element('history', 4, 'CDISC Extensions', :edit)
      click_link 'Release select'
      expect(page).to have_content 'Find & Select Code Lists'
      page.find('.card-with-tabs .show-more-btn').click
      sleep 0.2
      ui_dashboard_single_slider '2013-12-20'
      click_button 'Submit selected version'
      wait_for_ajax 20
      ui_check_table_info("table-cdisc-cls", 1, 10, 372)
      ui_check_table_cell("table-cdisc-cls", 3, 1, "C99077")
    end

    it "switch tabs"
    it "select CLs for the thesaurus, single or bulk"
    it "deselect CLs from the thesaurus, single or bulk"
    it "exclude CLs from the thesaurus, single or bulk"
    it "change the CDISC version, clears selection"
    it "initializes saved thesauri selection state correctly"
    it "edit lock, extend"
    it "expires edit lock, prevents additional changes"
    it "clears token when leaving page"

  end

end
