require 'rails_helper'

describe "ISO Registration State", :type => :feature do
  
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
    it "allows all registration states to be viewed" do
      click_link 'Registration States'
      expect(page).to have_content 'Registration States'
      expect(page).to have_content 'RS-TEST_1-1'
      expect(page).to have_content 'RS-TEST_3-3'      
      expect(page).to have_content 'RS-TEST_2-2'      
      expect(page).to have_content 'RS-TEST_3-4'      
      expect(page).to have_content 'RS-TEST_3-5'      
    end
=end

  end

end