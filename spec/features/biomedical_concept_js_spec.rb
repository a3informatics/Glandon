require 'rails_helper'

describe "Biomedical Concepts", :type => :feature do
  
  include DataHelpers
  include UiHelpers
  include PauseHelpers
  include UserAccountHelpers
  include DownloadHelpers
  include SparqlHelpers

  def sub_dir
    return "features"
  end

  describe "BCs", :type => :feature do
  
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
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

    it "allows for a BC to be exported as JSON", js: true do
      clear_downloads
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C25206'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'1.0.0')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
      click_link 'Export JSON'
      file = download_content 
    #write_text_file_2(file, sub_dir, "bc_export.json")
      expected = read_text_file_2(sub_dir, "bc_export.json")
      expect(file).to eq(expected)
    end

    it "allows for a BC to be exported as TTL", js: true do
      clear_downloads
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C25206'
      find(:xpath, "//tr[contains(.,'1.0.0')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
      click_link 'Export Turtle'
      file = download_content
    #write_text_file_2(file, sub_dir, "bc_export.ttl")
      write_text_file_2(file, sub_dir, "bc_export_results.ttl")
      expected = read_text_file_2(sub_dir, "bc_export.ttl")
      check_triples("bc_export_results.ttl", "bc_export.ttl")
      delete_data_file(sub_dir, "bc_export_results.ttl")
    end

    it "allows for a new BC to be created, error", js: true do
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      click_link 'New'
      expect(page).to have_content 'New: Biomedical Concept'
      fill_in "biomedical_concept[identifier]", with: 'NEW NEW NEW BC'
      fill_in "biomedical_concept[label]", with: 'A very new new new BC'
      click_button 'Create'
      expect(page).to have_content("A Biomedical Concept Template must be selected.")   
    end

    it "allows for a new BC to be created, I", js: true do
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      click_link 'New'
      expect(page).to have_content 'New: Biomedical Concept'
      fill_in "biomedical_concept[identifier]", with: 'NEW NEW NEW BC'
      fill_in "biomedical_concept[label]", with: 'A very new new new BC'
      ui_table_row_click("ims_list_table", "Obs CD")
      ui_click_by_id("ims_add_button")
      click_button 'Create'
      expect(page).to have_content("Biomedical Concept was successfully created.")   
    end

    it "allows for a new BC to be created, II", js: true do
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      click_link 'New'
      expect(page).to have_content 'New: Biomedical Concept'
      fill_in "biomedical_concept[identifier]", with: 'NEW BC II'
      fill_in "biomedical_concept[label]", with: 'A very new new new BC II'
      ui_click_by_id("ims_list_all_button")
      expect(page).to have_content 'You are now using unreleased forms.'
      ui_table_row_click("ims_all_table", "Obs CD")
      ui_click_by_id("ims_add_button")
      ui_click_by_id("ims_list_all_button")
      expect(page).to have_content 'You are now using released forms.'
      click_button 'Create'
      expect(page).to have_content("Biomedical Concept was successfully created.")   
    end

    it "allows for a new BC to be created, field validation", js: true do
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      click_link 'New'
      expect(page).to have_content 'New: Biomedical Concept'
      click_button 'Create'
      expect(page).to have_content("This field is required.")
      fill_in "biomedical_concept[identifier]", with: 'NEW BC III'  
      click_button 'Create'
      expect(page).to have_content("This field is required.")
      fill_in "biomedical_concept[label]", with: 'A very new new new BC III'
      click_button 'Create'
      expect(page).to have_content("A Biomedical Concept Template must be selected.")
    end

  end

end