require 'rails_helper'

describe "ISO Namespace", :type => :feature do
  
  include PauseHelpers
  include DataHelpers

  before :all do
    clear_triple_store
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
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
  
    it "allows all namespaces to be viewed" do
      click_link 'Namespaces'
      expect(page).to have_content 'Namespaces'
      expect(page).to have_content 'BBB Pharma'
      expect(page).to have_content 'AAA Long'      
    end

    it "allows a new namespace to be added" do
      click_link 'Namespaces'
      click_link 'New Namespace'
      expect(page).to have_content 'New Namespace'
      fill_in 'iso_namespace_shortName', with: 'NEWORG'
      fill_in 'iso_namespace_name', with: 'New Organisation'
      click_button 'Submit'
      expect(page).to have_content 'Namespaces'
      expect(page).to have_content 'New Organisation'  
    end

  end

end