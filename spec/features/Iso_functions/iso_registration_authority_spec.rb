require 'rails_helper'

describe "ISO Registration Authority", :type => :feature do
  
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
  
    it "allows all registration authorities to be viewed" do
      click_link 'Registration Authorities'
      expect(page).to have_content 'Registration Authorities'
      expect(page).to have_content '123456789'
      expect(page).to have_content '111111111'      
    end

    it "allows a new namespace to be added" do
      click_link 'Registration Authorities'
      expect(page).to have_content 'Registration Authorities'
      click_link 'New Authority'
      expect(page).to have_content 'Registration Authority'
      fill_in 'DUNS Number', with: '111122223'
      select 'AAA Long', from: "iso_registration_authority_namespaceId"
      click_button 'Submit'
      expect(page).to have_content 'Registration Authorities'
      expect(page).to have_content '111122223'   
    end

  end

end