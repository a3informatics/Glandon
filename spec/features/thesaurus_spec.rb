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
  
    it "clears triple store and loads test data" do
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
      fill_in 'thesaurus_identifier', with: 'TEST test'
      fill_in 'thesaurus_label', with: 'Test Terminology'
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: TEST test'
    end

  end

end