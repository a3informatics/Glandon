require 'rails_helper'

describe "ISO Concept System", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UserAccountHelpers
  include UiHelpers

  describe "General", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl",
        "BusinessOperational.ttl", "BusinessForm.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_concept_system_generic_data.ttl"]
      load_files(schema_files, data_files)
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

    it "allows concept systems to be displayed", js:true do
      click_navbar_tags
      expect(page).to have_content 'Classifications'
      expect(page).to have_content 'Tags'
    end

    it "allows a new system to be added", js:true do
      click_navbar_tags
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
