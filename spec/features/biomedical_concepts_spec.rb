require 'rails_helper'

describe "Biomedical Concepts", :type => :feature do
  
  include DataHelpers
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
    end

    before :each do
      user = FactoryGirl.create(:user)
      user.add_role :curator
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
    end

    it "allows access to index page" do
      visit '/'
      find(:xpath, "//a[@href='/biomedical_concepts']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Biomedical Concepts'
    end

    it "allows the history page to be viewed" do
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C49677')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C49677'
    end

    it "history allows the show page to be viewed" do
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C25206'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'Temperature (BC C25206)')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
    end

    it "history allows the status page to be viewed" do
      visit '/biomedical_concepts'
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C25206')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C25206'
      find(:xpath, "//tr[contains(.,'Temperature (BC C25206)')]/td/a", :text => 'Status').click
      expect(page).to have_content 'Status: Temperature (BC C25206) BC C25206 (V1.0.0, 1, Standard)'
      click_link 'Close'
      expect(page).to have_content 'History: BC C25206'
    end
    
    it "allows for a BC to be cloned" do
      visit '/biomedical_concepts'
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

    it "allows for a BC to be edited" do
      visit '/biomedical_concepts'
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