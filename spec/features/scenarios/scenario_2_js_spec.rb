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

  describe "Curator User", type: :feature, js: true do

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

    it "allows an item to move through the lifecyle (REQ-GENERIC-MI-020, REQ-GENERIC-MI-060)", scenario: true do
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

    it "allows an item to move through the lifecyle 2 (REQ-GENERIC-MI-020, REQ-GENERIC-MI-060)", scenario: true do
      ui_create_terminology('TEST2 test2', 'Test2 Terminology2')

      find(:xpath, "//tr[contains(.,'Test2 Terminology2')]/td/a").click
      wait_for_ajax(10)
      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax(10)

      dc_check_status('Incomplete')
      dc_forward_to('Recorded')
      
      click_on 'Return'
      wait_for_ajax(10)
      expect( find(:xpath, "//table[@id='history']") ).to have_selector('.icon-lock')

      context_menu_element_v2('history', '0.1.0', :edit)
      wait_for_ajax(10)
      click_on 'Return'
      wait_for_ajax(10)
      ui_check_table_info("history", 1, 2, 2)

      find('.registration-state').click
      wait_for_ajax(10)
      expect( find(:xpath, "//table[@id='history']") ).to have_selector('.icon-lock-open')

      context_menu_element_v2('history', 1, :edit)
      wait_for_ajax(10)
      click_on 'Return'
      wait_for_ajax(10)
      ui_check_table_info("history", 1, 2, 2)

      context_menu_element_v2('history', 1, :document_control)
      wait_for_ajax(10)
      dc_forward_to('Qualified')

      click_on 'Return'
      wait_for_ajax(10)
      expect( find(:xpath, "//table[@id='history']") ).to have_selector('.icon-lock')

      context_menu_element_v2('history', 1, :edit)
      wait_for_ajax(10)
      click_on 'Return'
      wait_for_ajax(10)
      ui_check_table_info("history", 1, 3, 3)
    end

    it "allows an item to move through the lifecyle updating semaversion number", scenario: true do
      ui_create_terminology('TEST3', 'Test Terminology3')

      find(:xpath, "//tr[contains(.,'TEST3')]/td/a").click
      wait_for_ajax(10)
      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax(10)

      dc_check_status('Incomplete')
      dc_forward_to('Candidate')
      dc_check_version_options(["major: 1.0.0", "minor: 0.1.0", "patch: 0.0.1"])
      dc_forward_to('Recorded')
      dc_check_version_options(["major: 1.0.0", "minor: 0.1.0", "patch: 0.0.1"])

      dc_update_version('0.0.1')
      dc_update_version('0.1.0')
      dc_update_version('1.0.0')

      dc_forward_to('Standard')

      click_on 'Return'
      wait_for_ajax(10)

      context_menu_element_v2('history', '1.0.0', :edit)
      wait_for_ajax(10)
      click_on 'Return'
      wait_for_ajax(10)

      context_menu_element_v2('history', 1, :document_control)
      dc_check_status('Incomplete')
      dc_check_version('1.1.0')

      dc_forward_to('Candidate')
      dc_check_version_options(["major: 2.0.0", "minor: 1.1.0", "patch: 1.0.1"])
    end

    it "allows an item to move through the lifecyle (REQ-GENERIC-MI-020, REQ-GENERIC-MI-060)", scenario: true do
      ui_create_terminology('TEST4', 'Test Terminology4')

      find(:xpath, "//tr[contains(.,'TEST4')]/td/a").click
      wait_for_ajax(10)
      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax(10)

      # State: Incomplete
      dc_check_status('Incomplete')
      dc_check_version('0.1.0')

      dc_update_version_label('1st Draft. Incomplete')
      dc_check_current(:not_standard)

      # State: Candidate
      dc_forward_to('Candidate')
      dc_check_version_options(["major: 1.0.0", "minor: 0.1.0", "patch: 0.0.1"])
      dc_update_version_label('2nd Draft. Candidate')
      dc_check_current(:not_standard)

      # State: Recorded
      dc_forward_to('Recorded')
      dc_check_version_options(["major: 1.0.0", "minor: 0.1.0", "patch: 0.0.1"])
      dc_update_version('1.0.0')
      dc_update_version_label('3rd Draft. Recorded')
      dc_check_current(:not_standard)

      dc_update_version('0.1.0')
      dc_update_version('0.0.1')
      dc_update_version('1.0.0')

      # State: Qualified 
      dc_forward_to('Qualified')
      dc_update_version_label('3rd Draft. Qualified')
      dc_check_current(:not_standard)
      
      # State: Standard
      dc_forward_to('Standard')
      dc_update_version_label('Standard')
      dc_check_current(:can_be_current)

      click_on 'Return'
      wait_for_ajax(10)

      context_menu_element_v2('history', '1.0.0', :edit)
      wait_for_ajax(10)
      click_on 'Return'
      wait_for_ajax(10)

      context_menu_element_v2('history', 'Standard', :document_control)
      wait_for_ajax(10)
      dc_check_status('Standard')
      dc_check_version('1.0.0')
      
      click_on 'Make Current'
      wait_for_ajax(10)

      # State: Superseded
      dc_forward_to('Superseded')
      dc_check_current(:is_current)
      dc_update_version_label('Superseded')
    end

  end

end
