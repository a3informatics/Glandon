require 'rails_helper'

describe "ISO Registration State", :type => :feature do
  
  include PauseHelpers
  include DataHelpers

  before :all do
    clear_triple_store
    load_test_file_into_triple_store("IsoNamespace.ttl")
    load_test_file_into_triple_store("IsoScopedIdentifier.ttl")
  end 

  before :each do
    user = FactoryGirl.create(:user)
    user.add_role :sys_admin
    visit '/users/sign_in'
    fill_in 'Email', with: 'user@example.com'
    fill_in 'Password', with: 'example1234'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'  
  end

  describe "View", :type => :feature do
  
    it "allows all registration states to be viewed" do
      click_link 'Registration States'
      expect(page).to have_content 'Registration States'
      expect(page).to have_content 'RS-TEST_1-1'
      expect(page).to have_content 'RS-TEST_3-3'      
      expect(page).to have_content 'RS-TEST_2-2'      
      expect(page).to have_content 'RS-TEST_3-4'      
      expect(page).to have_content 'RS-TEST_3-5'      
    end

  end

end