require 'rails_helper'

describe "Upload Files", :type => :feature do

  include UserAccountHelpers
  
  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end

  before :each do
    ua_content_admin_login
  end
    
  def sub_dir
    return "controllers"
  end

  describe "valid user", :type => :feature do
  
    it "allows file upload" do
      click_link 'Upload'
      expect(page).to have_content 'File Upload'
      attach_file('upload_datafile', Rails.root.join("spec/fixtures/files/features/upload.txt"))
    end

  end

end