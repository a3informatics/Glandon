require 'rails_helper'

describe "ISO Managed JS", :type => :feature do
  
  include DataHelpers
  include PauseHelpers
  include FeatureHelpers
  
  before :all do
    user = User.create :email => "curator@example.com", :password => "12345678" 
    user.add_role :curator
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    clear_iso_concept_object
  end

  after :all do
    user = User.where(:email => "curator@example.com").first
    user.destroy
  end

  describe "Curator User", :type => :feature do

    it "allows the metadata graph to be viewed", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      #pause
      click_link 'Biomedical Concepts'
      #pause
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC_A00003')]/td/a", :text => 'History').click
      #pause
      expect(page).to have_content 'History: BC_A00003'
      find(:xpath, "//tr[contains(.,'BC_A00003')]/td/a", :text => 'Gr-').click
      expect(page).to have_content 'Metadata View:'
      expect(page).to have_button('graph_focus', disabled: true)
      expect(page).to have_field('concept_type', disabled: true)
      expect(page).to have_field('concept_label', disabled: true)
      click_button 'graph_stop'
      expect(page).to have_button('graph_focus', disabled: false)
      #pause
    end

    it "allows a impact page to be displayed"

    it "allows the comments to be updated", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Forms'
      expect(page).to have_content 'Index: Forms'
      #pause
      find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'History').click
      #pause
      find(:xpath, "//table[@id='secondary']/tbody/tr/td/a", :text => 'Edit').click
      expect(page).to have_content 'Comments:'
      #pause
      fill_in "iso_managed_changeDescription", with: "Hello world. This is a change description"
      click_button "Preview"
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("Hello world. This is a change description")
      fill_in "iso_managed_explanatoryComment", with: "I am a comment"
      click_button "Preview"
      #pause
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("I am a comment")
      fill_in "iso_managed_origin", with: "I am the origin"
      click_button "Preview"
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("I am the origin")
      fill_in "iso_managed_origin", with: "@@@@@"
      expect(page).to have_content 'Please enter valid markdown.'
      #pause
      set_focus("iso_managed_explanatoryComment")
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("I am a comment")
      set_focus("iso_managed_changeDescription")
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("Hello world. This is a change description")
      fill_in "iso_managed_origin", with: "Origin"
      click_button 'Submit'
      expect(page).to have_content 'Hello world. This is a change description'   
      expect(page).to have_content 'I am a comment'   
      expect(page).to have_content 'Origin'   
    end

    it "allows the status to be updated", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Forms'
      expect(page).to have_content 'Index: Forms'
      #pause
      find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'History').click
      #pause
      find(:xpath, "//table[@id='main']/tbody/tr/td/a", :text => 'Status').click
      expect(page).to have_content 'Status:'
      #pause
      fill_in "iso_scoped_identifier_versionLabel", with: "@@@@@"
      click_button "version_submit"
      expect(page).to have_content "Versionlabel contains invalid characters"
      fill_in "iso_scoped_identifier_versionLabel", with: "Draft 1"
      click_button "version_submit"
      expect(page).to have_content "Draft 1"
      #pause      
      fill_in "iso_registration_state_administrativeNote", with: "£££££££££"
      fill_in "iso_registration_state_unresolvedIssue", with: "Draft 1"
      click_button "state_submit"
      expect(page).to have_content "Administrativenote contains invalid characters"
      fill_in "iso_registration_state_administrativeNote", with: "Good text"
      fill_in "iso_registration_state_unresolvedIssue", with: "&&&&"
      click_button "state_submit"
      expect(page).to have_content "Unresolvedissue contains invalid characters"
      fill_in "iso_registration_state_administrativeNote", with: "Good text"
      fill_in "iso_registration_state_unresolvedIssue", with: "Very good text"
      click_button "state_submit"
      #pause
      expect(page).to have_content "Current Status: Superseded"
      #pause
    end

  end

end