require 'rails_helper'

describe "Background Jobs", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)

    Background.delete_all
    Background.create(description: "job 1", complete: true, percentage: 100, status: "Doing something", started: Time.now, completed: Time.now)
    Background.create(description: "job 2", complete: false, percentage: 50, status: "Doing something", started: Time.now, completed: Time.now)
    Background.create(description: "job 3", complete: false, percentage: 60, status: "Doing something", started: Time.now, completed: Time.now)
    Background.create(description: "job 4", complete: true, percentage: 100, status: "Doing something", started: Time.now, completed: Time.now)
    Background.create(description: "job 5", complete: true, percentage: 100, status: "Doing something", started: Time.now, completed: Time.now)

    ua_create
  end

  before :each do
    ua_content_admin_login
  end

  after :each do
    ua_logoff
  end

  after :all do
    ua_destroy
  end

  describe "Background Jobs, Content Admin User", :type => :feature, js: true do

    it "allows all background jobs to be viewed" do
      click_navbar_background_jobs
      expect(page).to have_content 'Background Jobs'
      expect(page).to have_content 'List of active and past background jobs.'

      expect(page).to have_content 'Doing something'
      expect(page).to have_content 'job 1'
      expect(page).to have_content 'job 2'
      expect(page).to have_content 'job 3'

      expect(page).to have_button 'Delete Completed'
      expect(page).to have_button 'Delete All'
    end

    it "allows a background job to be removed" do
      click_navbar_background_jobs
      expect(page).to have_content 'Background Jobs'

      find(:xpath, "//tr[contains(.,'job 1')]/td/button").click
      ui_confirmation_dialog true
      wait_for_ajax 10

      expect(page).to have_content 'job 2'
      expect(page).to have_content 'job 3'
      expect(page).to have_no_content 'job 1'
    end

    it "allows completed background jobs to be removed" do
      click_navbar_background_jobs
      expect(page).to have_content 'Background Jobs'

      click_on 'Delete Completed'
      ui_confirmation_dialog true
      wait_for_ajax 10

      expect(page).to have_content 'job 2'
      expect(page).to have_content 'job 3'
      expect(page).to have_no_content 'job 4'
      expect(page).to have_no_content 'job 5'
    end


    it "allows all background jobs to be removed" do
      click_navbar_background_jobs
      expect(page).to have_content 'Background Jobs'

      click_on 'Delete All'
      ui_confirmation_dialog true
      wait_for_ajax 10

      expect(page).to have_no_content 'job 2'
      expect(page).to have_no_content 'job 3'
      expect(page).to have_content 'No data available'
    end

  end

end
