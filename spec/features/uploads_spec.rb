require 'rails_helper'

describe "Upload Files", :type => :feature do
  
  before :each do
    user = FactoryGirl.create(:user)
    user.add_role :content_admin
  end

  describe "valid user", :type => :feature do
  
    it "allows file upload" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Upload'
      expect(page).to have_content 'File Upload'
      attach_file('upload_datafile', Rails.root.join("db/load/test/upload.txt"))
    end

  end

end