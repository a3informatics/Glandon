require 'rails_helper'

describe "Biomedical Concept Templates", :type => :feature do
  
  include DataHelpers
  include UserAccountHelpers

  describe "BCTs", :type => :feature do
  
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

      load_test_file_into_triple_store("BCT.ttl")
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

    it "allows access to index page" do
      visit '/'
      find(:xpath, "//a[@href='/biomedical_concept_templates']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Biomedical Concept Templates'
    end

    it "allows the history page to be viewed" do
      visit '/biomedical_concept_templates'
      expect(page).to have_content 'Index: Biomedical Concept Templates'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'Obs CD')]/td/a", :text => 'History').click
      #save_and_open_page
      expect(page).to have_content 'History: Obs CD'
    end

    it "history allows the show page to be viewed" do
      visit '/biomedical_concept_templates'
      expect(page).to have_content 'Index: Biomedical Concept Templates'
      find(:xpath, "//tr[contains(.,'Obs PQR')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: Obs PQR'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'Simple Observation PQR Biomedical Research Concept Template')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Simple Observation PQR Biomedical Research Concept Template Obs PQR (V1.0.0, 1, Standard)'
    end

    it "history allows the status page to be viewed" do
      visit '/biomedical_concept_templates'
      expect(page).to have_content 'Index: Biomedical Concept Templates'
      find(:xpath, "//tr[contains(.,'Obs CD')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: Obs CD'
      find(:xpath, "//tr[contains(.,'Simple Observation CD Biomedical Research Concept Template')]/td/a", :text => 'Status').click
      expect(page).to have_content 'Status: Simple Observation CD Biomedical Research Concept Template Obs CD (V1.0.0, 1, Standard)'
      click_link 'Close'
      expect(page).to have_content 'History: Obs CD'
    end

  end

end