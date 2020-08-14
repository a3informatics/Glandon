require 'rails_helper'
require 'allure-rspec'

#Latest version settings for CDISC terminology
LST_VERSION = 65
LATEST_VERSION='2020-06'
FILEPATH="/Users/Kirsten/Documents/Testing/Run01/"
#TURN_ON_SCREEN_SHOT=false
TURN_ON_SCREEN_SHOT=true
FILENAME="/Users/Kirsten/Documents/Testing/Run01/Run01.txt"

RSpec.configure do |config|
  config.formatter = AllureRspecFormatter
end

AllureRspec.configure do |config|
      config.results_directory = FILEPATH
      config.clean_results_directory = true
      config.logging_level = Logger::INFO
      # these are used for creating links to bugs or test cases where {} is replaced with keys of relevant items
      config.link_tms_pattern = "http://www.jira.com/browse/GLAN"
      config.link_issue_pattern = "http://www.jira.com/browse/GLAN/issues"
    end

def save_screen(step,file_path=FILEPATH,screen_shot_enabled=TURN_ON_SCREEN_SHOT)
   if screen_shot_enabled
     save_screenshot "#{file_path}#{Time.now.strftime("Actual_#{step}_%d_%m_%Y__%H_%M")}.png"
      Allure.add_attachment(
       name: "#{Time.now.strftime("Actual_#{step}_%d_%m_%Y__%H_%M")}",
       source: File.open("#{file_path}#{Time.now.strftime("Actual_#{step}_%d_%m_%Y__%H_%M")}.png"),
       type: Allure::ContentType::PNG,
       test_case: true)
   end
end

describe "Community Version Test Cases: TC MDR-PQ-1, TC MDR-PQ-2, TC MDR-PQ-3, TC MDR-PQ-4 ", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include AuditTrailHelpers
  include ScenarioHelpers
  include QualificationUserHelpers

  describe "Load in CDISC terminology", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..LST_VERSION)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      quh_create
      Token.destroy_all
      AuditTrail.destroy_all
      clear_downloads
    end

    after :all do
      quh_destroy
    end

    before :each do
      puts colourize("Step 1: Login as Community Reader", "brown")
      quh_community_reader_login
      save_screen("s2")
      puts colourize("Step 2: Verified that the user is signed in successfully", "green")
    end
  
    after :each do
      puts colourize("Log-off", "brown")
      quh_logoff
    end

    
  it "Verified that a community user can browse code list versions and display a specific code list and code list items", scenario: true, js: true do

    puts colourize("Testing REQ-MDR-CT-010 : The system shall allow for multiple versions of the CDISC terminology to be held within the system","blue")
    puts colourize("Step 3: Click ** Browse every version of CDISC CT **", "blue") 
    puts colourize("Info *Latests version loaded: v#{LST_VERSION}, #{LATEST_VERSION}*", "blue")
      click_browse_every_version
      expect_page 'Version History of'
      expect(page).to have_content LATEST_VERSION

    puts colourize("Step 4: Verified that CDISC Terminology History is Displayed with the latest release version", "green")
       save_screen("s4") 
   
    puts colourize("Step 5: Click ** Context menu for 2019-06-28 **", "blue")
    row = find("table#history tr", text: "2019-06-28")
    expect(row).to have_selector(".context-menu .option.disabled", text: "Edit", visible: false)
    expect(row).to have_selector(".context-menu .option.disabled", text: "Delete", visible: false)
    expect(row).to have_selector(".context-menu .option.disabled", text: "Document control", visible: false)
    expect(row).not_to have_selector(".context-menu .option.disabled", text: "Show", visible: false)
    expect(row).not_to have_selector(".context-menu .option.disabled", text: "Search", visible: false)
      within(row) do
      ui_table_search("history", "2019-06-28")
      find(".icon-context-menu").click
      save_screen("s6") 
      end
    puts colourize("Step 6: Verified that Show and Search are enabled and all other menus are disabled", "green")
    puts colourize("Step 7: In context menu for 2019-06-28 and click ** Show **", "blue")
      context_menu_element("history",6,"2019-06-28 Release", :show)
      wait_for_ajax(20)
      expect(page).to have_content '2019-06-28 Release'
      ui_check_table_info("children_table", 1, 10, 891)
      wait_for_ajax(20)
      save_screen("s8")
    puts colourize("Step 8: Verified that controlled terminology 2019-06-28 Release is displayed and has 891 entries", "green")
    
    puts colourize("Step 9: Enter C66729 in the Code List search area and click ** Show ** to display the ROUTE code list", "blue")
      ui_child_search("C66729")
      find(:xpath, "//tr[contains(.,'C66729')]/td/a", :text => 'Show').click
      ui_check_table_info("children_table", 1, 10, 132)
      expect(page).to have_content 'ROUTE'
      expect(page).to have_content 'C66729'
      expect(page).to have_content 'CDISC SDTM Route of Administration Terminology'
      wait_for_ajax(20)
      save_screen("s10")
    puts colourize("Step 10: Verified that the ROUTE (C667299 code list items are displayed (132 entries)", "green")
    
    puts colourize("Step 11: Enter C38299 in the Code List Items search area and click ** Show ** to display the SUBCUTANEOUS code list item", "blue")
      ui_child_search("C38299")
      find(:xpath, "//tr[contains(.,'C38299')]/td/a", :text => 'Show').click
      expect(page).to have_selector("#pts-panel .card-content", text: "CMROUTE (C78420)")
      expect(page).to have_selector("#pts-panel .card-content", text: "EXROUTE (C78425)")
      expect(page).to have_selector("#pts-panel .card-content", text: "Subcutaneous Route of Administration")
      expect(page).to have_selector("#synonyms-panel .card-content", text: "CMROUTE (C78420)")
      expect(page).to have_selector("#synonyms-panel .card-content", text: "EXROUTE (C78425)")
      expect(page).to have_selector("#synonyms-panel .card-content", text: "SC")
      expect(page).to have_selector("#synonyms-panel .card-content", text: "Subdermal Route of Administration")
      wait_for_ajax(10)
      save_screen("s12")
    puts colourize("Step 12: Verified that Shared Preferred Term and Synonym is displayed as CMROUTE and EXROUTE", "green")
    
    end

  end

end
