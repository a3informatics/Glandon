require 'rails_helper'

describe "Biomedical Concepts", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers

  def sub_dir
    return "features"
  end

  describe "BCs", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
        "BusinessOperational.ttl", "BusinessForm.ttl", "CDISCBiomedicalConcept.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl", "BC.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..42)

      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
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
      find(:xpath, "//tr[contains(.,'BC C49677')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C49677'
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C25206'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'Temperature (BC C25206)')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
    end

    it "history allows the status page to be viewed", js:true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C25206'
      find(:xpath, "//tr[contains(.,'Temperature (BC C25206)')]/td/a", :text => 'Status').click
      expect(page).to have_content 'Status: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
      click_link 'Close'
      expect(page).to have_content 'History: BC C25206'
    end

    it "allows for a BC to be cloned", js:true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C25206'
      find(:xpath, "//tr[contains(.,'Temperature (BC C25206)')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
      click_link 'Clone'
      expect(page).to have_content 'Cloning: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
      fill_in "biomedical_concept[identifier]", with: 'NEW NEW BC'
      fill_in "biomedical_concept[label]", with: 'A very new new BC'
      #save_and_open_page

      click_button 'Clone'
      expect(page).to have_content("Biomedical Concept was successfully created.")
    end

    it "allows for a BC to be edited (REQ-MDR-BC-010)", js:true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C25206'
      find(:xpath, "//tr[contains(.,'Temperature (BC C25206)')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: Temperature (BC C25206) BC C25206 (V1.1.0, 2, Incomplete)'
      click_link 'main_nav_bc'
      expect(page).to have_content 'Index: Biomedical Concepts'
    end

  end

end
