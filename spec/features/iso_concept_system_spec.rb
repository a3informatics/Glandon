require 'rails_helper'

describe "ISO Concept System", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UserAccountHelpers

  describe "General", :type => :feature do
  
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

      load_test_file_into_triple_store("iso_concept_system_generic_data.ttl")
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
	    ua_content_admin_login
	  end

	  after :each do
	    ua_logoff
	  end

    it "allows concept systems to be displayed" do
      click_link 'Tags'
      expect(page).to have_content 'Classifications'
      expect(page).to have_content 'Tags'
    end

    it "allows a new system to be added" do
      click_link 'Tags'
      click_link 'New'
      expect(page).to have_content 'New Classification'
      fill_in 'iso_concept_system_label', with: 'XXXX'
      fill_in 'iso_concept_system_description', with: 'XXXX Description'
      click_button 'Create'
      expect(page).to have_content 'XXXX'
    end

    it "allows a tag to be added, first level"

    it "allows a tag to be added, child"

    it "allows a tag to be deleted"

    it "allows a concept system to be deleted"

    it "allows a tag to be displayed"

  end

end