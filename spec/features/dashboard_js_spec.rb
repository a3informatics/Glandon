require 'rails_helper'

describe "Dashboard JS", :type => :feature do

  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper


  def triples_search(search_text)
    input = find(:xpath, '//*[@id="triplesTable_filter"]/label/input')
    input.set("#{search_text}")
    input.native.send_keys(:return)
  end

  before :all do
    ua_create
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BC.ttl", "form_example_vs_baseline.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..42)
    clear_iso_concept_object
  end

  after :all do
    ua_destroy
  end

  # before :each do
  #   ua_reader_login
  # end

  after :each do
    ua_logoff
  end

  describe "Reader User", :type => :feature do

    it "allows the dashboard to be viewed, header (REQ-MDR-UD-NONE)", js: true do
      ua_reader_login
      expect(page).to have_content 'Dashboard'
      expect(page).to have_content 'Terminologies'
      expect(page).to have_content 'Today is'
      expect(page).to have_content 'You have'
    end

    it "allows the dashboard to be viewed, customize, select items (REQ-MDR-UD-NONE)", js: true do
      ua_sys_and_content_admin_login
      expect(page).to have_content 'Dashboard'
      expect(page).to have_content 'Customize'
      click_link 'Customize'
      sleep 0.5
      uncheck 'Terminologies'
      sleep 0.5
      click_button 'Save'
      wait_for_ajax(120)
      expect(page).not_to have_content 'Terminologies'
      expect(page).to have_content 'Statistics'
    end

    it "allows the dashboard to be viewed, customize, uncheck and check items (REQ-MDR-UD-NONE)", js: true do
      ua_sys_and_content_admin_login
      expect(page).to have_content 'Dashboard'
      expect(page).to have_content 'Customize'
      click_link 'Customize'
      wait_for_ajax(120)
      uncheck 'Terminologies'
      uncheck 'Statistics'
      click_button 'Save'
      wait_for_ajax(120)
      expect(page).not_to have_content 'Terminologies'
      expect(page).not_to have_content 'Statistics'
      click_link 'Customize'
      wait_for_ajax(120)
      check 'Terminologies'
      check 'Statistics'
      click_button 'Save'
    end

    # it "allows the dashboard to be viewed, customize, drag & drop items (REQ-MDR-UD-NONE)", js: true do
    #   ua_sys_and_content_admin_login
    #   expect(page).to have_content 'Dashboard'
    #   expect(page).to have_content 'Customize'
    #   click_link 'Customize'
    #   # //*[@id="dashboard-editor"]/div[1] #Header
    #   # //*[@id="dashboard-editor"]/div[2] #Terminologies
    #   # //*[@id="dashboard-editor"]/div[3] #Statistics
    #   from = page.find(:xpath, "//*[@id='dashboard-editor']/div[2]")
    #   target = page.find(:xpath, "//*[@id='dashboard-editor']/div[3]")
    #   from.drag_to(target)
    # end

    it "allows the dashboard to be viewed, terminologies panel (REQ-MDR-UD-NONE)", js: true do
      ua_sys_and_content_admin_login
      wait_for_ajax(120)
      expect(page).to have_content 'Dashboard'
      expect(page).to have_content 'Customize'
      expect(page).to have_content 'Terminologies'
      expect(page).to have_content 'CDISC'
      click_link 'Terminologies'
      wait_for_ajax(120)
      expect(page).to have_content 'Index: Terminology'
    end

    it "allows the dashboard to be viewed, statistics panel (REQ-MDR-UD-NONE)", js: true do
      ua_sys_and_content_admin_login
      wait_for_ajax(120)
      expect(page).to have_content 'Dashboard'
      expect(page).to have_content 'Customize'
      expect(page).to have_content 'Statistics'
      find(:xpath, "//*[@id='tab_by_domain']").click
      wait_for_ajax(120)
      expect(page).to have_content 'User logins by domain'
      find(:xpath, "//*[@id='tab_by_time']").click
      expect(page).to have_content 'User logins by year, by month'
      expect(page).to have_content 'User logins by day, this week'
      expect(page).to have_content 'User logins by year, by week'
      expect(page).to have_content 'User logins by year'
    end

    # it "allows the history to be accessed (REQ-MDR-UD-NONE)", js: true do
    #   find(:xpath, "//tr[contains(.,'APGAR Score (BC A00002)')]/td/a", :text => /\AHistory\z/).click
    #   expect(page).to have_content 'History: BC A00002'
    # end

    it "displays the organization name (REQ-MDR-UD-NONE)", js: true do
      ua_reader_login
      expect(page).to have_content "#{APP_CONFIG['application_name']} (v#{Version::VERSION})"
    end

  end

end
