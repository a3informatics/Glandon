require 'rails_helper'

describe "Biomedical Concept Instances", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  def sub_dir
    return "features"
  end

  describe "BCs", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows access to index page (REQ-MDR-MIT-015)", js:true do
      click_navbar_bc
      find(:xpath, "//a[@href='/biomedical_concepts']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Biomedical Concepts'
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'HEIGHT\''
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'HEIGHT\''
      context_menu_element('history', 4, 'HEIGHT', :show)
      wait_for_ajax(10)
      expect(page).to have_content 'Show: Biomedical Concept'
      ui_check_table_info("show", 1, 3, 3)
    end

    # it "history allows the status page to be viewed", js:true do
    #   click_navbar_bc
    #   expect(page).to have_content 'Index: Biomedical Concepts'
    #   find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: BC C25206'
    #   find(:xpath, "//tr[contains(.,'Temperature (BC C25206)')]/td/a", :text => 'Status').click
    #   expect(page).to have_content 'Status: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
    #   click_link 'Close'
    #   expect(page).to have_content 'History: BC C25206'
    # end

    # it "allows for a BC to be cloned", js:true do
    #   click_navbar_bc
    #   expect(page).to have_content 'Index: Biomedical Concepts'
    #   find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: BC C25206'
    #   find(:xpath, "//tr[contains(.,'Temperature (BC C25206)')]/td/a", :text => 'Show').click
    #   expect(page).to have_content 'Show: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
    #   click_link 'Clone'
    #   expect(page).to have_content 'Cloning: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
    #   fill_in "biomedical_concept[identifier]", with: 'NEW NEW BC'
    #   fill_in "biomedical_concept[label]", with: 'A very new new BC'
    #   #save_and_open_page

    #   click_button 'Clone'
    #   expect(page).to have_content("Biomedical Concept was successfully created.")
    # end

    # it "allows for a BC to be edited (REQ-MDR-BC-010)", js:true do
    #   click_navbar_bc
    #   expect(page).to have_content 'Index: Biomedical Concepts'
    #   find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: BC C25206'
    #   find(:xpath, "//tr[contains(.,'Temperature (BC C25206)')]/td/a", :text => 'Edit').click
    #   expect(page).to have_content 'Edit: Temperature (BC C25206) BC C25206 (V1.1.0, 2, Incomplete)'
    #   click_link 'main_nav_bc'
    #   expect(page).to have_content 'Index: Biomedical Concepts'
    # end

  end

end
