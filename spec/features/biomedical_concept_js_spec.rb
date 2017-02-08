require 'rails_helper'

describe "Biomedical Concepts", :type => :feature do
  
  include DataHelpers
  include UiHelpers
  include PauseHelpers
  include UserAccountHelpers
  include DownloadHelpers

  def sub_dir
    return "features"
  end

  describe "BCs", :type => :feature do
  
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
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
      clear_downloads
    end

    after :all do
      ua_destroy
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    it "allows for a BC to be exported as JSON", js: true do
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C25206'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'1.0.0')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
      click_link 'Export JSON'
      file = download_content
      #write_text_file_2(file, sub_dir, "bc_json_export.json")
      expected = read_text_file_2(sub_dir, "bc_json_export.json")
      expect(file).to eq(expected)
    end

    it "allows for a BC to be exported as TTL", js: true do
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C25206'
      find(:xpath, "//tr[contains(.,'1.0.0')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
      click_link 'Export Turtle'
      file = download_content
      #write_text_file_2(file, sub_dir, "bc_json_export.ttl")
      expected = read_text_file_2(sub_dir, "bc_json_export.ttl")
      expect(file).to eq(expected)
    end

  end

end