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

    it "allows edit lock timeout to be amended", js: true do
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
      audit_count = AuditTrail.count
      user = User.create :email => "amend@assero.co.uk", :password => "Changeme1%", :name => "A Amend"
      ua_generic_login "amend@assero.co.uk", "Changeme1%"
      click_link 'settings_button'
      fill_in 'user_password', with: 'Changeme1@'
      fill_in 'user_password_confirmation', with: 'Changeme1@'
      fill_in 'user_current_password', with: 'Changeme1%'
      click_button 'password_update_button'
      expect(page).to have_content 'Your account has been updated successfully.'
      expect(AuditTrail.count).to eq(audit_count + 3)
    end

    it "allows a user to change their password - incorrect current password" do
      audit_count = AuditTrail.count
      user = User.create :email => "amend@assero.co.uk", :password => "Changeme1@", :name => "A Amend"
      ua_generic_login "amend@assero.co.uk", "Changeme1@"
      click_link 'settings_button'
      fill_in 'user_password', with: 'Changeme1^'
      fill_in 'user_password_confirmation', with: 'Changeme1^'
      fill_in 'user_current_password', with: 'Changeme1x'
      click_button 'password_update_button'
      expect(page).to have_content 'Current password is invalid'
      expect(AuditTrail.count).to eq(audit_count + 2)
    end

    it "allows a user to update the display name" do
      audit_count = AuditTrail.count
      user = User.create :email => "amend@assero.co.uk", :password => "Changeme1@", :name => "A Amend"
      ua_generic_login "amend@assero.co.uk", "Changeme1@"
      click_link 'settings_button'
      expect(page).to have_content 'Email: amend@assero.co.uk'
      expect(page).to have_content 'Display Name: A Amend'
      fill_in 'user_name', with: 'New Name for A Amend'
      click_button 'name_update_button'
      expect(page).to have_content 'Display Name: New Name for A Amend'
    end

  end

end
