require 'rails_helper'

describe "ISO Scoped Identifier", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UserAccountHelpers

  before :all do
    clear_triple_store
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_scoped_identifier.ttl")
    ua_create
  end

  after :all do
    ua_destroy
  end

  before :each do
    ua_curator_login
  end

  describe "View", :type => :feature do
  
    it "has had the UI disabled"
    
=begin
    it "allows all scoped identifiers to be viewed" do
      click_link 'Scoped Identifiers'
      expect(page).to have_content 'Scoped Identifiers'
      expect(page).to have_content 'SI-TEST_1-1'
      expect(page).to have_content 'SI-TEST_3-3'      
      expect(page).to have_content 'SI-TEST_2-2'      
      expect(page).to have_content 'SI-TEST_3-4'      
      expect(page).to have_content 'SI-TEST_3-5'      
    end

    it "allows a new scoped identifier to be added" do
      click_link 'Scoped Identifiers'
      click_link 'New Scoped Identifier'
      expect(page).to have_content 'New Scoped Identifier'
      fill_in 'Identifier', with: 'TEST1'
      fill_in 'Version Label', with: 'Issue 2'
      fill_in 'Internal Version', with: '2'
      select 'AAA Long', from: "iso_scoped_identifier_namespaceId"
      click_button 'Create'
      expect(page).to have_content 'Scoped Identifiers'
      expect(page).to have_content 'SI-TEST_1-1'
      expect(page).to have_content 'SI-AAA_TEST1-2'
      expect(page).to have_content 'SI-TEST_3-3'      
      expect(page).to have_content 'SI-TEST_2-2'      
      expect(page).to have_content 'SI-TEST_3-4'      
      expect(page).to have_content 'SI-TEST_3-5'      
    end
=end

  end

end