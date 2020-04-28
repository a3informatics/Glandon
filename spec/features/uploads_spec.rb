require 'rails_helper'

describe "Upload Files", :type => :feature do

  include UserAccountHelpers
  include PublicFileHelpers
  include WaitForAjaxHelper
  include UiHelpers

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end

  #before :each do
  #  ua_content_admin_login
  #end

  #after :each do
  #  ua_logoff
  #end

  def sub_dir
    return "controllers"
  end

  describe "valid user", :type => :feature do

    it "allows file upload (REQ-MDR-UPL-020)", js: true do
      ua_content_admin_login
      click_navbar_upload
      expect(page).to have_content 'File Upload'
      attach_file('upload_datafile', Rails.root.join("spec/fixtures/files/features/upload.txt"))
      ua_logoff
    end

    it "upload, no file chosen (REQ-MDR-UPL-020)", js: true do
      ua_content_admin_login
      click_navbar_upload
      expect(page).to have_content 'File Upload'
      click_on "Start upload"
      expect(page).to have_content "No file selected"
      ua_logoff
    end


  end


  describe "Remove uploads", :type => :feature do

    before :each do
      delete_all_public_files
      filename = PublicFile.save("test", "PublicFile1.txt", "Contents of the file 1")
      filename = PublicFile.save("test", "PublicFile2.xml", "Contents of the file 2")
      filename = PublicFile.save("test", "PublicFile3.xml", "Contents of the file 3")
      filename = PublicFile.save("test", "PublicFile3.json", "Contents of the file 4")
    end

    it "remove multiple uploads", js: true do
      ua_content_admin_login
      click_navbar_upload
      expect(page).to have_content 'File Upload'
      expect(page).to have_xpath("//*[@id='uploaded-files']/tbody/tr", :count => 4)
      ui_check_table_cell("uploaded-files", 1, 1, "json")
      find(:xpath, "//tr[contains(.,'json')]").click
      find(:xpath, "//tr[contains(.,'txt')]").click
      find("#remove-selected-files").click
      ui_confirmation_dialog true
      wait_for_ajax 10
      page.driver.browser.navigate.refresh
      expect(page).to have_xpath("//*[@id='uploaded-files']/tbody/tr", :count => 2)
      ua_logoff
    end

    it "remove all uploads", js: true do
      ua_content_admin_login
      click_navbar_upload
      expect(page).to have_content 'File Upload'
      expect(page).to have_xpath("//*[@id='uploaded-files']/tbody/tr", :count => 4)
      find("#select-all-files").click
      find("#remove-selected-files").click
      ui_confirmation_dialog true
      wait_for_ajax 10
      page.driver.browser.navigate.refresh
      expect(page).to have_xpath("//*[@id='uploaded-files']/tbody/tr", :count => 1)
      expect(page).to have_content "No files in the Uploads directory."
      ua_logoff
    end

  end

  describe "not valid user", :type => :feature do

    it "do not allows file upload (REQ-MDR-UPL-020)", js: true do
      ua_sys_admin_login
      ui_expand_section('main_nav_impexp')
      expect(page).not_to have_content 'File Upload'
      ua_logoff
    end

  end

end
