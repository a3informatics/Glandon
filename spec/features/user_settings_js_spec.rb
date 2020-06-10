require 'rails_helper'

describe "User Settings", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers

  def check_selected(title, description, selected, options)
    tr = page.find('#user_settings tbody tr', text: "#{title}")
    within tr do
      expect(find(:xpath, 'th[1]/div[contains(@class, "setting-title")]').text).to eq(title)
      expect(find(:xpath, 'th[1]/div[contains(@class, "setting-descr")]').text).to eq(description)
      expect(find(:xpath, 'td[1]').text).to eq(selected + " " + options)
    end
  end

  def check_options(title, description, options)
  	tr = page.find('#user_settings tbody tr', text: "#{title}")
    options.each do |option|
  		others = options - [option]
  		link = get_td(tr, 1, option)
  		# if link.nil?
	  	# 	link = get_td(tr, 2, option)
  		# end
  		link.click
  		check_selected(title, description, option, others.join(" "))
    end
  end

  def get_td(tr, col, option)
  	x = tr.find(:xpath, "td[#{col}]/a[text()='#{option}']")
  	return x
  rescue => e
  	return nil
  end

  def select_option(title, description, selected, options, select_click)
  	click_link selected if select_click
    others = options - [selected]
    check_selected(title, description, selected, others.join(" "))
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl", "BC.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..1)
    ua_create
  end

  after :all do
    ua_destroy
  end

  describe "amending settings", :type => :feature do

    it "allows paper size to be amended", js: true do
      title = "Paper Size"
      description = "The paper size to be used for PDF reports exported by the system."
      options = ["A3", "A4", "Letter"]
      ua_curator_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: curator@example.com'
      check_options(title, description, options)
    end

    it "allows table rows to be amended", js: true do
      title = "Table Rows"
      description = "The number of rows to be used within table displays."
      options = ["5", "10", "15", "25", "50", "100", "All"]
      ua_curator_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: curator@example.com'
      check_options(title, description, options)
    end

    it "allows edit lock timeout to be amended (REQ-MDR-EL-040)", js: true do
      title = "Edit Lock Warning"
      description = "The time at which a warning will be issued before an edit lock is lost. Half way to the lock being lost a second warning " +
      	"will be issued. Times are expressed in minutes and seconds."
      options = ["30s", "1m", "1m 30s", "2m", "3m", "5m"]
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: reader@example.com'
      check_options(title, description, options)
    end

    it "allows display user name to be amended", js: true do
      title = "Display User Name"
      description = "Display the user name in the top navigation bar."
      options = ["Yes", "No"]
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: reader@example.com'
      check_options(title, description, options)
    end

    it "allows display user role to be amended", js: true do
      title = "Display User Roles"
      description = "Display the user roles in the top navigation bar."
      options = ["Yes", "No"]
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: reader@example.com'
      check_options(title, description, options)
    end

    it "displays Layout of the dashboard setting", js: true do
      title = "Layout of the Dashboard"
      description = "Customize this setting in the Dashboard page."
      options = []
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: reader@example.com'
      check_options(title, description, options)
    end

    it "settings are user specific", js: true do
      title = "Table Rows"
      description = "The number of rows to be used within table displays."
      options = ["5", "10", "15", "25", "50", "100", "All"]
      ua_curator_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: curator@example.com'
      select_option(title, description, "10", options, true)
      select_option(title, description, "50", options, true)
      click_link 'logoff_button'
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: reader@example.com'
      select_option(title, description, "10", options, true)
      select_option(title, description, "25", options, true)
      click_link 'logoff_button'
      ua_curator_login
      expect(page).to have_content 'Signed in successfully'
      click_link 'settings_button'
      expect(page).to have_content 'Email: curator@example.com'
      select_option(title, description, "50", options, false)
      click_link 'logoff_button'
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: reader@example.com'
      select_option(title, description, "25", options, false)
    end

    it "allows term display count to be amended", js: true do
      title = "Terminology Versions Displayed"
      description = "Number of terminologies to be displayed in change tables."
      options = ["4", "8", "12"]
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: reader@example.com'
      check_options(title, description, options)
    end

    it "allows a user to change their password" do
      user = User.create :email => "amend@assero.co.uk", :password => "Changeme1%", :name => "A Amend"
      unforce_first_pass_change user
      ua_generic_login "amend@assero.co.uk", "Changeme1%"
      audit_count = AuditTrail.count
      click_link 'settings_button'
      expect(page).to have_content "Account Settings"
      fill_in 'user_password', with: 'Changeme1@'
      fill_in 'user_password_confirmation', with: 'Changeme1@'
      fill_in 'user_current_password', with: 'Changeme1%'
      click_button 'password_update_button'
      expect(page).to have_content 'Your account has been updated successfully.'
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it "allows a user to change their password - incorrect current password" do
      user = User.create :email => "amend@assero.co.uk", :password => "Changeme1@", :name => "A Amend"
      unforce_first_pass_change user
      ua_generic_login "amend@assero.co.uk", "Changeme1@"
      audit_count = AuditTrail.count
      click_link 'settings_button'
      expect(page).to have_content "Account Settings"
      fill_in 'user_password', with: 'Changeme1^'
      fill_in 'user_password_confirmation', with: 'Changeme1^'
      fill_in 'user_current_password', with: 'Changeme1x'
      click_button 'password_update_button'
      expect(page).to have_content 'Current password is invalid'
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "allows a user to update the display name" do
      audit_count = AuditTrail.count
      user = User.create :email => "amend@assero.co.uk", :password => "Changeme1@", :name => "A Amend"
      unforce_first_pass_change user
      ua_generic_login "amend@assero.co.uk", "Changeme1@"
      click_link 'settings_button'
      expect(page).to have_content "Account Settings"
      expect(page).to have_content 'Email: amend@assero.co.uk'
      expect(page).to have_content 'A Amend'
      fill_in 'user_name', with: 'New Name for A Amend'
      click_button 'name_update_button'
      expect(page).to have_content 'New Name for A Amend'
    end

    it "prohibits the user from changing their display name to an empty string" do
      ua_sys_admin_login
      click_link 'settings_button'
      expect(page).to have_content "Account Settings"
      fill_in 'user_name', with: ''
      click_button 'name_update_button'
      expect(page).to have_content 'Failed to update user display name. Name is too short (minimum is 1 character)'
    end

    it "validates access to user settings for a community reader" do
      ua_community_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'Email: comm_reader@example.com'
      expect(page).to have_content 'Application Settings'
      expect(page).to have_content 'Account Settings'
    end

  end

end
