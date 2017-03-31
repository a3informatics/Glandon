require 'rails_helper'

describe "ISO Concept System", :type => :feature do
  
  include PauseHelpers
  include DataHelpers

  describe "General", :type => :feature do
  
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
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("iso_concept_system_generic_data.ttl")
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
      expect(page).to have_content 'Signed in successfully'  
    end

    it "allows concept systems to be displayed" do
      click_link 'Classifications (tags)'
      expect(page).to have_content 'Classifications'
      expect(page).to have_content 'Tags'
    end

    it "allows a new system to be added" do
      click_link 'Classifications (tags)'
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