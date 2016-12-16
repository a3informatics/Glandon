require 'rails_helper'

describe "Thesaurus", :type => :feature do
  
  include DataHelpers

  describe "Sponsor Terminology", :type => :feature do
  
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

    it "allows access to index page" do
      visit '/'
      find(:xpath, "//a[@href='/forms']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Forms'
    end

    it "allows a form to be created" #do
=begin
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      click_link 'New'
      expect(page).to have_content 'New Terminology:'
      fill_in 'thesauri_identifier', with: 'TEST test'
      fill_in 'thesauri_label', with: 'Test Terminology'
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: TEST test'
    end
=end

    it "allows the history page to be viewed" do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'T2')]/td/a", :text => 'History').click
      #save_and_open_page
      expect(page).to have_content 'History: T2'
    end

    it "history allows the show page to be viewed" do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'T2')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: T2'
      find(:xpath, "//tr[contains(.,'Test 2')]/td/a", :text => 'Show').click
      #save_and_open_page
      expect(page).to have_content 'Show: Test 2 T2 (, V1, Incomplete)'
      expect(page).to have_content 'A00001'
      #expect(page).to have_content 'A00010'
      #expect(page).to have_content 'A00020'
    end

    it "history allows the view page to be viewed" do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'Demographics')]/td/a", :text => 'View').click
      #save_and_open_page
      expect(page).to have_content 'View: Demographics DM1 01 (, V1, Candidate)'
      click_link 'Close'
      expect(page).to have_content 'History: DM1 01'
    end

    it "history allows the status page to be viewed" do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'Demographics')]/td/a", :text => 'Status').click
      #save_and_open_page
      expect(page).to have_content 'Status: Demographics DM1 01'
      click_link 'Close'
      expect(page).to have_content 'History: DM1 01'
    end
    
    it "history allows the edit page to be viewed" do 
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'T2')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'Test 2')]/td/a", :text => 'Edit').click
      save_and_open_page
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (0.1, V2, Incomplete)' # Note the up version because V1 is at 'Standard'
      #click_button 'Close' # This requires Javascript so wont work in this test.
      #expect(page).to have_content 'History: CDISC EXT'
    end

    
  end

end