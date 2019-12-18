require 'rails_helper'

describe "Thesauri Release Select", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include TimeHelpers

  describe "The Curator User, initial state", :type => :feature, js:true do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "CDISCTerm.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..46)
      Token.delete_all
      ua_create
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

    it "display the release select page, initial state", :type => :feature do
      ui_create_terminology("TST0", "Test Thesaurus")
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'TST0')]/td/a").click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'TST0\''
      context_menu_element('history', 4, 'Test Thesaurus', :edit)
      wait_for_ajax 10
      click_link 'Release select'
      expect(page).to have_content("Find & Select Code Lists")
      expect(page).to have_content("CDISC version used: None")
      expect(page).to have_content("No items were found.")
      expect(page).to have_css(".tab-option.disabled", count: 4)
      page.find(".card-with-tabs .show-more-btn").click
      expect(page).to have_content("Select CDISC Terminology version by dragging the slider")
      expect(page).to have_content("ver. 2015-12-18")
    end

  end

  describe "The Curator User can", :type => :feature, js:true do

    before :all do
      timer_start
      load_test_file_into_triple_store("test_db_1.nq.gz")
      timer_stop("Triple store loaded")
      ua_create
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

    def navigate_to_release_sel
      visit '/thesauri/aHR0cDovL3d3dy5zLWN1YmVkLmRrL1RTVC9WMSNUSA==/release_select'
      expect(page).to have_content 'Find & Select Code Lists'
      wait_for_ajax 50
    end

    it "select a CDISC version", :type => :feature do
      navigate_to_release_sel
      page.find('.card-with-tabs .show-more-btn').click
      sleep 0.2
      ui_dashboard_single_slider '2013-12-20'
      click_button 'Submit selected version'
      ui_confirmation_dialog true
      wait_for_ajax 50
      ui_check_table_info("table-cdisc-cls", 1, 10, 372)
      ui_check_table_cell("table-cdisc-cls", 3, 1, "C99077")
      page.find('.card-with-tabs .show-more-btn').click
      sleep 0.2
      ui_dashboard_single_slider '2019-09-27'
      click_button 'Submit selected version'
      ui_confirmation_dialog true
      wait_for_ajax 50
      ui_check_table_info("table-cdisc-cls", 1, 10, 911)
      ui_check_table_cell("table-cdisc-cls", 2, 1, "C99078")
      ui_check_table_row_indicators("table-cdisc-cls", 1, 7, ["subsetted"])
      ui_check_table_row_indicators("table-cdisc-cls", 4, 7, ["extended"])
    end

    it "checks sponsor CLs, Subsets and Extensions and indicators", :type => :feature do
      navigate_to_release_sel
      ui_click_tab "Sponsor CLs"
      wait_for_ajax 10
      ui_check_table_info("table-sponsor-cls", 1, 2, 2)
      ui_check_table_cell("table-sponsor-cls", 1, 2, "Test CL 2")
      ui_check_table_cell("table-sponsor-cls", 2, 1, "NP000135P")
      ui_click_tab "Sponsor Subsets"
      wait_for_ajax 10
      ui_check_table_info("table-sponsor-subsets", 1, 2, 2)
      ui_check_table_cell("table-sponsor-subsets", 1, 1, "NP000138P")
      ui_check_table_cell("table-sponsor-subsets", 2, 1, "NP000137P")
      ui_check_table_row_indicators("table-sponsor-subsets", 1, 7, ["subset"])
      ui_click_tab "Sponsor Extensions"
      wait_for_ajax 10
      ui_check_table_info("table-sponsor-extensions", 1, 2, 2)
      ui_check_table_cell("table-sponsor-extensions", 1, 1, "C99076E")
      ui_check_table_cell("table-sponsor-extensions", 2, 2, "TUTEST")
      ui_check_table_row_indicators("table-sponsor-extensions", 1, 7, ["extension"])
    end

    it "select CLs for the thesaurus, single or bulk", :type => :feature do
      navigate_to_release_sel
      find(:xpath, '//*[@id="table-cdisc-cls"]/tbody/tr[contains(.,"C99079")]').click
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-cdisc-cls"]/tbody/tr[contains(.,"C99079")]')[:class].include? "selected"
      ui_click_tab "Test Terminology"
      ui_check_table_cell("table-selection-overview", 1, 1, "C99079")
      ui_click_tab "CDISC CLs"
      find(:xpath, '//*[@id="table-cdisc-cls"]/tbody/tr[contains(.,"C99079")]').click
      wait_for_ajax 10
      ui_click_tab "Test Terminology"
      expect(page).to_not have_xpath('//*[@id="table-selection-overview"]/tbody/tr[contains(.,"C99079")]')
      ui_click_tab "CDISC CLs"
      page.find("#table-cdisc-cls-bulk-select").click
      wait_for_ajax 100
      ui_click_tab "Test Terminology"
      ui_check_table_info("table-selection-overview", 1, 10, 911)
      ui_check_table_cell("table-selection-overview", 10, 1, "C96783")
      ui_check_table_row_indicators("table-selection-overview", 1, 7, ["subsetted"])
      ui_click_tab "Sponsor CLs"
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-sponsor-cls"]/tbody/tr[contains(.,"Test CL 2")]').click
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-sponsor-cls"]/tbody/tr[contains(.,"Test CL 2")]')[:class].include? "selected"
      ui_click_tab "Sponsor Extensions"
      wait_for_ajax 10
      ui_check_table_row_indicators("table-sponsor-extensions", 1, 7, ["extension"])
      page.find("#table-sponsor-extensions-bulk-select").click
      wait_for_ajax 20
      ui_click_tab "Test Terminology"
      ui_check_table_info("table-selection-overview", 1, 10, 914)
      ui_check_table_cell("table-selection-overview", 5, 1, "C99076E")
    end

    it "deselect CLs from the thesaurus, single or bulk", :type => :feature do
      navigate_to_release_sel
      ui_table_search("table-cdisc-cls", "Protocol")
      page.find("#table-cdisc-cls-bulk-deselect").click
      ui_confirmation_dialog true
      wait_for_ajax 50
      ui_check_table_info("table-cdisc-cls", 1, 10, 20)
      expect(page).to have_content ("891 rows selected")
      ui_click_tab "Test Terminology"
      ui_table_search("table-selection-overview", "Protocol")
      ui_check_table_info("table-selection-overview", 1, 1, 1)
      ui_table_search("table-selection-overview", "")
      ui_click_tab "Sponsor CLs"
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-sponsor-cls"]/tbody/tr[contains(.,"NP000136P")]').click
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-sponsor-cls"]/tbody/tr[contains(.,"NP000136P")]')[:class].exclude? "selected"
      ui_click_tab "Test Terminology"
      ui_table_search("table-selection-overview", "NP000136P")
      ui_check_table_info("table-selection-overview", 0, 0, 0)
    end

    it "exclude CLs from the thesaurus, single or bulk", :type => :feature do
      navigate_to_release_sel
      ui_click_tab "Test Terminology"
      find(:xpath, '//*[@id="table-selection-overview"]/tbody/tr[contains(.,"C99079")]/td[8]/span').click
      wait_for_ajax 10
      ui_click_tab "CDISC CLs"
      find(:xpath, '//*[@id="table-cdisc-cls"]/tbody/tr[contains(.,"C99079")]')[:class].exclude? "selected"
      ui_click_tab "Test Terminology"
      ui_table_search("table-selection-overview", "SEND")
      page.find("#table-selection-overview-bulk-deselect").click
      ui_confirmation_dialog true
      wait_for_ajax 50
      ui_table_search("table-selection-overview", "")
      ui_check_table_info("table-selection-overview", 1, 10, 775)
      ui_click_tab "CDISC CLs"
      expect(page).to have_content("773 rows selected")
    end


    it "change the CDISC version, clears selection"
    it "edit lock, extend"
    it "expires edit lock, prevents additional changes"
    it "clears token when leaving page"

  end

end
