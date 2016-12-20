require 'rails_helper'

describe "Forms", :type => :feature do
  
  include DataHelpers

  describe "Forms", :type => :feature do
  
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
      load_test_file_into_triple_store("form_example_dm1.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
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

    it "allows a placeholder form to be created", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      click_link 'New Placeholder'
      expect(page).to have_content 'New Placeholder Form:'
      fill_in 'form[identifier]', with: 'A PLACEHOLDER FORM'
      fill_in 'form[label]', with: 'Test Placeholder Form'
      fill_in 'form[freeText]', with: 'This is **some** mardown with a little mardown in *it*'
      click_button 'markdown_preview'
      ui_check_div_text('generic_markdown', 'This is some mardown with a little mardown in it') # Need Javascript for this
      click_button 'Create'
      expect(page).to have_content 'Index: Forms'
      expect(page).to have_content 'Test Placeholder Form'
    end

  end

end