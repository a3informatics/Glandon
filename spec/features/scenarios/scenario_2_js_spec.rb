require 'rails_helper'

describe "Scenario 2 - Life Cycle", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include UserAccountHelpers
  include AuditTrailHelpers
  include ScenarioHelpers

  def sub_dir
    return "features/scenarios"
  end

  describe "Curator User", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..43)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      Token.destroy_all
      AuditTrail.destroy_all
      clear_downloads
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows an item to move through the lifecyle", scenario: true, js: true do
      click_navbar_terminology
      expect_page 'Index: Terminology'
      click_link 'New Terminology'
      sleep 1
      fill_in 'thesauri_identifier', with: 'TEST test'
      fill_in 'thesauri_label', with: 'Test Terminology'
      click_button 'Submit'
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a").click
      wait_for_ajax(10)
      context_menu_element('history', 4, 'Test Terminology', :document_control)
      wait_for_ajax(10)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")

      fill_in '[iso_managed]administrative_note', with: 'First step in the lifecyle.'
      fill_in '[iso_managed]unresolved_issue', with: 'None that we know of.'
      click_button "state_submit"
      wait_for_ajax(20)
      expect(page).to have_content("Candidate")

      find(:xpath, "//*[@id='version-label-edit']").click
      fill_in 'iso_scoped_identifier[version_label]', with: '1st Draft.'
      find(:xpath, "//*[@id='version-label-submit']").click

      fill_in '[iso_managed]administrative_note', with: 'Next step in the lifecyle.'
      fill_in '[iso_managed]unresolved_issue', with: 'Still none that we know of.'
      click_button "state_submit"
      wait_for_ajax(20)
      expect(page).to have_content("Recorded")

      click_button "state_submit"
      wait_for_ajax(20)
      expect(page).to have_content("Qualified")
      click_link 'Return'
      wait_for_ajax(120)

      find(:xpath, "//*[@id='history']/tbody/tr/td[7]/span/span").click
      wait_for_ajax(120)
      expect(page).to have_css ('.icon-lock-open')
      ui_check_table_info("history", 1, 1, 1)

      context_menu_element('history', 4, 'Test Terminology', :edit)
      wait_for_ajax(120)
      click_link 'Return'

      wait_for_ajax(20)
      ui_check_table_info("history", 1, 1, 1)
      find(:xpath, "//*[@id='history']/tbody/tr[1]/td[7]/span/span").click
      wait_for_ajax(20)
      expect(page).to have_css ('.icon-lock')

      context_menu_element('history', 4, 'Test Terminology', :edit)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)
      ui_check_table_info("history", 1, 2, 2)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      expect(page).to have_content 'Version Control'
      find(:xpath, "//*[@id='version-edit']").click
      find(:xpath, "//*[@id='select-release']/option[1]").click #Major release
      find(:xpath, "//*[@id='version-edit-submit']").click
      wait_for_ajax(120)
      expect(page).to have_xpath('//*[@id="imh_header"]/div/div/div[2]/div[3]/span[4]', text: '1.0.0')

      click_link 'Return'
      wait_for_ajax(120)


      context_menu_element('history', 4, 'Test Terminology', :edit, 1)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(120)
      ui_check_table_info("history", 1, 3, 3)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      expect(page).to have_content 'Version Control'
      find(:xpath, "//*[@id='version-edit']").click
      find(:xpath, "//*[@id='select-release']/option[2]").click #Minor release
      find(:xpath, "//*[@id='version-edit-submit']").click
      wait_for_ajax(120)
      expect(page).to have_xpath('//*[@id="imh_header"]/div/div/div[2]/div[3]/span[4]', text: '0.2.0')
      click_link 'Return'
      wait_for_ajax(120)
      ui_check_table_info("history", 1, 3, 3)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      click_button "state_submit"
      wait_for_ajax(20)
      expect(page).to have_content("Standard")
      click_link 'Return'
      wait_for_ajax(120)

      context_menu_element('history', 4, 'Test Terminology', :edit, 1)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)
      ui_check_table_info("history", 1, 4, 4)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      click_button "state_submit"
      expect(page).to have_content("Candidate")

      find(:xpath, "//*[@id='version-label-edit']").click
      fill_in 'iso_scoped_identifier[version_label]', with: 'Standard'
      find(:xpath, "//*[@id='version-label-submit']").click

      click_button "state_submit"
      wait_for_ajax(20)
      expect(page).to have_content("Recorded")

      click_button "state_submit"
      wait_for_ajax(20)
      expect(page).to have_content("Qualified")
      click_link 'Return'
      wait_for_ajax(120)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      expect(page).to have_content 'Version Control'
      find(:xpath, "//*[@id='version-edit']").click
      find(:xpath, "//*[@id='select-release']/option[1]").click #Major release
      find(:xpath, "//*[@id='version-edit-submit']").click
      wait_for_ajax(120)
      expect(page).to have_xpath('//*[@id="imh_header"]/div/div/div[2]/div[3]/span[4]', text: '1.0.0')

      click_link 'Return'
      wait_for_ajax(120)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      click_button "state_submit"
      wait_for_ajax(20)
      expect(page).to have_content("Standard")
      click_link 'Return'
      wait_for_ajax(120)
    end

    it "allows an item to move through the lifecyle 2", scenario: true, js: true do
      click_navbar_terminology
      expect_page 'Index: Terminology'
      click_link 'New Terminology'
      sleep 1
      fill_in 'thesauri_identifier', with: 'TEST2 test2'
      fill_in 'thesauri_label', with: 'Test2 Terminology2'
      click_button 'Submit'
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'Test2 Terminology2')]/td/a").click
      wait_for_ajax(10)
      context_menu_element('history', 4, 'Test2 Terminology2', :document_control)
      wait_for_ajax(10)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Candidate")

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Recorded")

      click_link 'Return'
      wait_for_ajax(120)

      expect(page).to have_css ('.icon-lock')

      context_menu_element('history', 4, 'Test2 Terminology2', :edit)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)

      ui_check_table_info("history", 1, 2, 2)

      find(:xpath, "//*[@id='history']/tbody/tr[1]/td[7]/span/span").click #Click padlock
      wait_for_ajax(120)
      expect(page).to have_css ('.icon-lock-open')

      context_menu_element('history', 4, 'Test2 Terminology2', :edit, 1)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)
      ui_check_table_info("history", 1, 2, 2)

      context_menu_element('history', 4, 'Test2 Terminology2', :document_control, 1)
      wait_for_ajax(10)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Recorded")

      click_button "state_submit"
      wait_for_ajax(20)
      expect(page).to have_content("Qualified")

      click_link 'Return'
      wait_for_ajax(120)

      expect(page).to have_css ('.icon-lock')

      context_menu_element('history', 4, 'Test2 Terminology2', :edit, 1)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)
      ui_check_table_info("history", 1, 3, 3)
    end

    it "allows an item to move through the lifecyle updating semaversion number", scenario: true, js: true do
      click_navbar_terminology
      expect_page 'Index: Terminology'
      click_link 'New Terminology'
      sleep 1
      fill_in 'thesauri_identifier', with: 'TEST3'
      fill_in 'thesauri_label', with: 'Test Terminology3'
      click_button 'Submit'
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'Test Terminology3')]/td/a").click
      wait_for_ajax(10)
      context_menu_element('history', 4, 'Test Terminology3', :document_control)
      wait_for_ajax(10)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")
      expect(page).to have_content("Version: 0.1.0")

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Candidate")
      page.find("#version-edit").click
      ui_select_check_options("select-release", ["Major: 1.0.0", "Minor: 0.1.0", "Patch: 0.0.1"])
      
      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Recorded")
      page.find("#version-edit").click
      ui_select_check_options("select-release", ["Major: 1.0.0", "Minor: 0.1.0", "Patch: 0.0.1"])
      
      select "1.0.0", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Recorded")
      expect(page).to have_content("Version: 1.0.0")

      page.find("#version-edit").click
      select "0.1.0", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 0.1.0")

      page.find("#version-edit").click
      select "0.0.1", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 0.0.1")

      page.find("#version-edit").click
      select "1.0.0", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 1.0.0")

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Qualified")

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Standard")
      expect(page).to have_content("Version: 1.0.0")

      click_link 'Return'
      wait_for_ajax(120)

      context_menu_element('history', 4, 'Test Terminology3', :edit)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)
      context_menu_element('history', 4, 'Test Terminology3', :document_control, 1)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")
      expect(page).to have_content("Version: 1.1.0")

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Candidate")
      page.find("#version-edit").click
      ui_select_check_options("select-release", ["Major: 2.0.0", "Minor: 1.1.0", "Patch: 1.0.1"])

    end

    it "allows an item to move through the lifecyle", scenario: true, js: true do
      click_navbar_terminology
      expect_page 'Index: Terminology'
      click_link 'New Terminology'
      sleep 1
      fill_in 'thesauri_identifier', with: 'TEST4'
      fill_in 'thesauri_label', with: 'Test Terminology4'
      click_button 'Submit'
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'Test Terminology4')]/td/a").click
      wait_for_ajax(10)
      context_menu_element('history', 4, 'Test Terminology4', :document_control)
      wait_for_ajax(10)
      # State: Incomplete
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")
      expect(page).to have_content("Version: 0.1.0")
      expect(page).not_to have_select("select-release")
      find(:xpath, "//*[@id='version-label-edit']").click
      fill_in 'iso_scoped_identifier[version_label]', with: '1st Draft. Incomplete'
      find(:xpath, "//*[@id='version-label-submit']").click
      expect(page).to have_css(".ico-btn-sec", class: 'disabled')
      click_button "state_submit"
      wait_for_ajax(10)
      # State: Candidate
      expect(page).to have_content("Candidate")
      page.find("#version-edit").click
      ui_select_check_options("select-release", ["Major: 1.0.0", "Minor: 0.1.0", "Patch: 0.0.1"])
      find(:xpath, "//*[@id='version-label-edit']").click
      fill_in 'iso_scoped_identifier[version_label]', with: '2nd Draft. Candidate'
      find(:xpath, "//*[@id='version-label-submit']").click
      expect(page).to have_css(".ico-btn-sec", class: 'disabled')
      click_button "state_submit"
      wait_for_ajax(10)
      #State: Recorded
      expect(page).to have_content("Recorded")
      page.find("#version-edit").click
      ui_select_check_options("select-release", ["Major: 1.0.0", "Minor: 0.1.0", "Patch: 0.0.1"])
      
      select "1.0.0", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Recorded")
      expect(page).to have_content("Version: 1.0.0")
      find(:xpath, "//*[@id='version-label-edit']").click
      fill_in 'iso_scoped_identifier[version_label]', with: '3rd Draft. Recorded'
      find(:xpath, "//*[@id='version-label-submit']").click
      wait_for_ajax(10)
      expect(page).to have_css(".ico-btn-sec", class: 'disabled')
      

      page.find("#version-edit").click
      select "0.1.0", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 0.1.0")

      page.find("#version-edit").click
      select "0.0.1", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 0.0.1")

      page.find("#version-edit").click
      select "1.0.0", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 1.0.0")

      click_button "state_submit"
      wait_for_ajax(10)
      #State: Qualified
      expect(page).to have_content("Qualified")
      find(:xpath, "//*[@id='version-label-edit']").click
      fill_in 'iso_scoped_identifier[version_label]', with: '4th Draft. Qualified'
      find(:xpath, "//*[@id='version-label-submit']").click
      expect(page).to have_css(".ico-btn-sec", class: 'disabled')
      click_button "state_submit"
      wait_for_ajax(10)
      #State: Standard
      expect(page).to have_content("Standard")
      expect(page).to have_content("Version: 1.0.0")
      find(:xpath, "//*[@id='version-label-edit']").click
      fill_in 'iso_scoped_identifier[version_label]', with: 'Standard'
      find(:xpath, "//*[@id='version-label-submit']").click
      expect(page).to have_css(".ico-btn-sec")
      

      click_link 'Return'
      wait_for_ajax(120)

      context_menu_element('history', 4, 'Test Terminology4', :edit)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)
      context_menu_element('history', 5, 'Standard', :document_control)
    
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Standard")
      expect(page).to have_content("Version: 1.0.0")
      find(:xpath, "//*[@id='make_current']").click
      wait_for_ajax(10)

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Superseded")
      
      expect(page).to_not have_button "state_submit"
      expect(page).to have_css(".ico-btn-sec", class: 'disabled')
      find(:xpath, "//*[@id='version-label-edit']").click
      fill_in 'iso_scoped_identifier[version_label]', with: 'Superseded'
      find(:xpath, "//*[@id='version-label-submit']").click

    end

  end

end
