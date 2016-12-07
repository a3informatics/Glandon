require 'rails_helper'

describe "Thesaurus", :type => :feature do
  
  include DataHelpers

  before :each do
    user = FactoryGirl.create(:user)
    user.add_role :curator
    visit '/users/sign_in'
    fill_in 'Email', with: 'user@example.com'
    fill_in 'Password', with: 'example1234'
    click_button 'Log in'
  end

  describe "Sponsor Terminology", :type => :feature do
  
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("thesaurus_concept.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "allows access to index page" do
      visit '/'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
    end

    it "allows a terminology to be created" do
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      click_link 'New'
      expect(page).to have_content 'New Terminology:'
      fill_in 'thesauri_identifier', with: 'TEST test'
      fill_in 'thesauri_label', with: 'Test Terminology'
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: TEST test'
    end

    it "allows the history page to be viewed" do
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: TEST test'
    end

    it "history allows the show page to be viewed" do
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: CDISC Extensions CDISC EXT (0.1, V1, Standard)'
      expect(page).to have_content 'A00001'
      expect(page).to have_content 'A00010'
      expect(page).to have_content 'A00020'
    end

    it "history allows the view page to be viewed" do
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'View').click
      expect(page).to have_content 'View: CDISC Extensions CDISC EXT (0.1, V1, Standard)'
      click_link 'Close'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "history allows the status page to be viewed" do
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'Status').click
      expect(page).to have_content 'Status: CDISC Extensions CDISC EXT (0.1, V1, Standard)'
      click_link 'Close'
      expect(page).to have_content 'History: CDISC EXT'
    end
    
    it "history allows the search page to be viewed" do
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Extensions CDISC EXT (0.1, V1, Standard)'
      click_link 'Close'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "allows the lower level show pages to be viewed" do
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: CDISC Extensions CDISC EXT (0.1, V1, Standard)'
      expect(page).to have_content 'A00001'
      expect(page).to have_content 'A00010'
      expect(page).to have_content 'A00020'
      find(:xpath, "//tr[contains(.,'VSTEST')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Vital Sign Test Codes Extension A00001'
      expect(page).to have_content 'A00003'
      expect(page).to have_content 'A00002'
      find(:xpath, "//tr[contains(.,'MUAC')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Mid upper arm circumference A00003'
      #save_and_open_page
    end

    it "history allows the edit page to be viewed" do # Put this after other tests, creates V2
      visit '/thesauri'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (0.1, V2, Incomplete)' # Note the up version because V1 is at 'Standard'
      #click_button 'Close' # This requires Javascript so wont work in this test.
      #expect(page).to have_content 'History: CDISC EXT'
    end

    
  end

end