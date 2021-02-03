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
  include IsoManagedHelpers 

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

    it "allows an item to move through the lifecyle (REQ-GENERIC-MI-020, REQ-GENERIC-MI-060)", scenario: true, js: true do
      ui_create_terminology('TEST test', 'Test Terminology')

      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a").click
      wait_for_ajax(10)
      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax(10)

      dc_check_status('Incomplete')
      fill_in 'Administrative note', with: 'First step in the lifecyle.'
      fill_in 'Unresolved issue', with: 'None that we know of.'
      dc_forward_to('Candidate')

      dc_update_version_label('1st Draft')

      fill_in 'Administrative note', with: 'Next step in the lifecyle.'
      fill_in 'Unresolved issue', with: 'Still none that we know of.'
      dc_forward_to('Qualified')

      click_on 'Return'
      wait_for_ajax(10)

      find('.registration-state').click
      wait_for_ajax(10)
      expect( find(:xpath, "//td[contains(.,'Qualified')]") ).to have_selector('.icon-lock-open')
      ui_check_table_info("history", 1, 1, 1)

      context_menu_element_v2('history', '0.1.0', :edit)
      wait_for_ajax(10)
      click_on 'Return'
      wait_for_ajax(10)

      ui_check_table_info("history", 1, 1, 1)
      find('.registration-state').click
      wait_for_ajax(10)
      expect( find(:xpath, "//td[contains(.,'Qualified')]") ).to have_selector('.icon-lock')

      context_menu_element_v2('history', '0.1.0', :edit)
      wait_for_ajax(10)
      click_on 'Return'
      wait_for_ajax(10)
      ui_check_table_info("history", 1, 2, 2)

      context_menu_element_v2('history', 1, :document_control)
      wait_for_ajax(10)
      dc_update_version('1.0.0')
      click_on 'Return'
      wait_for_ajax(10)

      context_menu_element_v2('history', '1.0.0', :edit)
      wait_for_ajax(10)
      click_on 'Return'
      wait_for_ajax(10)
      ui_check_table_info("history", 1, 3, 3)

      context_menu_element_v2('history', 1, :document_control)
      wait_for_ajax(10)
      dc_update_version('0.2.0')
      click_on 'Return'
      wait_for_ajax(10)
      ui_check_table_info("history", 1, 3, 3)

      context_menu_element_v2('history', 1, :document_control)
      wait_for_ajax(10)
      dc_forward_to('Standard')
      click_on 'Return'
      wait_for_ajax(10)

      context_menu_element_v2('history', 'Standard', :edit)
      wait_for_ajax(10)
      click_on 'Return'
      wait_for_ajax(10)
      ui_check_table_info("history", 1, 4, 4)

      context_menu_element_v2('history', '0.3.0', :document_control)
      wait_for_ajax(10)
      dc_forward_to('Candidate')

      dc_update_version_label('Standard')
      dc_forward_to('Qualified')
      click_on 'Return'
      wait_for_ajax(10)

      context_menu_element_v2('history', '0.3.0', :document_control)
      wait_for_ajax(10)
      dc_update_version('1.0.0')

      click_on 'Return'
      wait_for_ajax(10)

      context_menu_element_v2('history', 1, :document_control)
      wait_for_ajax(10)
      dc_forward_to('Standard')
      click_on 'Return'
      wait_for_ajax(10)
    end

    it "allows an item to move through the lifecyle 2 (REQ-GENERIC-MI-020, REQ-GENERIC-MI-060)", scenario: true, js: true do
      ui_create_terminology('TEST2 test2', 'Test2 Terminology2')

      find(:xpath, "//tr[contains(.,'Test2 Terminology2')]/td/a").click
      wait_for_ajax(10)
      context_menu_element_v2('history', '0.1.0', :document_control)
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

      expect( find(:xpath, "//table[@id='history']") ).to have_selector ('.icon-lock')

      context_menu_element_v2('history', '0.1.0', :edit)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)

      ui_check_table_info("history", 1, 2, 2)

      find('.registration-state').click
      wait_for_ajax(120)
      expect( find(:xpath, "//table[@id='history']") ).to have_selector ('.icon-lock-open')

      context_menu_element_v2('history', 1, :edit)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)
      ui_check_table_info("history", 1, 2, 2)

      context_menu_element_v2('history', 1, :document_control)
      wait_for_ajax(10)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Recorded")

      click_button "state_submit"
      wait_for_ajax(20)
      expect(page).to have_content("Qualified")

      click_link 'Return'
      wait_for_ajax(120)

      expect( find(:xpath, "//table[@id='history']") ).to have_selector ('.icon-lock')

      context_menu_element_v2('history', 1, :edit)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)
      ui_check_table_info("history", 1, 3, 3)
    end

    it "allows an item to move through the lifecyle updating semaversion number", scenario: true, js: true do
      ui_create_terminology('TEST3', 'Test Terminology3')

      find(:xpath, "//tr[contains(.,'TEST3')]/td/a").click
      wait_for_ajax(10)
      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax(10)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")
      expect(page).to have_content("Version: 0.1.0")

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Candidate")
      find("#version-edit").click
      ui_select_check_options("select-release", ["Major: 1.0.0", "Minor: 0.1.0", "Patch: 0.0.1"])

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Recorded")
      find("#version-edit").click
      ui_select_check_options("select-release", ["Major: 1.0.0", "Minor: 0.1.0", "Patch: 0.0.1"])

      select "1.0.0", from: "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Recorded")
      expect(page).to have_content("Version: 1.0.0")

      find("#version-edit").click
      select "0.1.0", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 0.1.0")

      find("#version-edit").click
      select "0.0.1", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 0.0.1")

      find("#version-edit").click
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

      context_menu_element_v2('history', '1.0.0', :edit)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)
      context_menu_element_v2('history', 1, :document_control)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")
      expect(page).to have_content("Version: 1.1.0")

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Candidate")
      find("#version-edit").click
      ui_select_check_options("select-release", ["Major: 2.0.0", "Minor: 1.1.0", "Patch: 1.0.1"])

    end

    it "allows an item to move through the lifecyle (REQ-GENERIC-MI-020, REQ-GENERIC-MI-060)", scenario: true, js: true do
      ui_create_terminology('TEST4', 'Test Terminology4')

      find(:xpath, "//tr[contains(.,'TEST4')]/td/a").click
      wait_for_ajax(10)
      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax(10)
      # State: Incomplete
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")
      expect(page).to have_content("Version: 0.1.0")
      expect(page).not_to have_select("select-release")
      find('#version-label-edit').click
      fill_in 'iso_scoped_identifier[version_label]', with: '1st Draft. Incomplete'
      find('#version-label-submit').click
      expect(page).to have_css("#make_current", class: 'disabled')
      click_button "state_submit"
      wait_for_ajax(10)
      # State: Candidate
      expect(page).to have_content("Candidate")
      find("#version-edit").click
      ui_select_check_options("select-release", ["Major: 1.0.0", "Minor: 0.1.0", "Patch: 0.0.1"])
      find('#version-label-edit').click
      fill_in 'iso_scoped_identifier[version_label]', with: '2nd Draft. Candidate'
      find('#version-label-submit').click
      expect(page).to have_css("#make_current", class: 'disabled')
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
      find('#version-label-edit').click
      fill_in 'iso_scoped_identifier[version_label]', with: '3rd Draft. Recorded'
      find('#version-label-submit').click
      wait_for_ajax(10)
      expect(page).to have_css("#make_current", class: 'disabled')


      find("#version-edit").click
      select "0.1.0", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 0.1.0")

      find("#version-edit").click
      select "0.0.1", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 0.0.1")

      find("#version-edit").click
      select "1.0.0", :from => "select-release"
      click_button "version-edit-submit"
      expect(page).to have_content("Version: 1.0.0")

      click_button "state_submit"
      wait_for_ajax(10)
      #State: Qualified
      expect(page).to have_content("Qualified")
      find('#version-label-edit').click
      fill_in 'iso_scoped_identifier[version_label]', with: '4th Draft. Qualified'
      find('#version-label-submit').click
      expect(page).to have_css("#make_current", class: 'disabled')
      click_button "state_submit"
      wait_for_ajax(10)
      #State: Standard
      expect(page).to have_content("Standard")
      expect(page).to have_content("Version: 1.0.0")
      find('#version-label-edit').click
      fill_in 'iso_scoped_identifier[version_label]', with: 'Standard'
      find('#version-label-submit').click
      expect( find('#make_current')[:class] ).not_to include('disabled')

      click_link 'Return'
      wait_for_ajax(120)

      context_menu_element_v2('history', '1.0.0', :edit)
      wait_for_ajax(120)
      click_link 'Return'
      wait_for_ajax(20)
      context_menu_element_v2('history', 'Standard', :document_control)

      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Standard")
      expect(page).to have_content("Version: 1.0.0")
      click_on 'make_current'
      wait_for_ajax(10)

      click_button "state_submit"
      wait_for_ajax(10)
      expect(page).to have_content("Superseded")

      expect(page).to_not have_button "state_submit"
      expect(page).to have_css("#make_current", class: 'disabled')
      find('#version-label-edit').click
      fill_in 'iso_scoped_identifier[version_label]', with: 'Superseded'
      find('#version-label-submit').click

    end

  end

end
