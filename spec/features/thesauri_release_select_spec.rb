require 'rails_helper'

describe "Thesauri Release Select", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include TimeHelpers

  describe "The Curator User can", :type => :feature, js:true do

    before :all do
      timer_start
      load_files(schema_files, [])
      load_test_file_into_triple_store("test_db_1.nq.gz")
      timer_stop("Triple store loaded")
      Token.delete_all
      ua_create
      IsoRegistrationAuthority.clear_scopes
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
      IsoRegistrationAuthority.clear_scopes
    end

    def navigate_to_release_sel
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'TST')]",).click
      wait_for_ajax 10
      context_menu_element("history", 5, "TST", :edit)
      wait_for_ajax 50
      expect(page).to have_content 'Find & Select Code Lists'
    end

    it "link to Edit Tags page", js:true do
      navigate_to_release_sel
      expect(context_menu_element_header_present?(:edit_tags)).to eq(true)
      w = window_opened_by { context_menu_element_header(:edit_tags) }
      within_window w do
        wait_for_ajax(10)
        expect(page).to have_content "TST"
        expect(page).to have_content "Attach / Detach Tags"
      end
      w.close
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
      ui_check_table_row_indicators("table-cdisc-cls", 1, 7, ["9 versions", "subsetted"])
      ui_check_table_row_indicators("table-cdisc-cls", 4, 7, ["3 versions", "extended"])
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
      ui_check_table_row_indicators("table-sponsor-extensions", 2, 7, ["4 versions", "extension"])
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
      ui_check_table_row_indicators("table-selection-overview", 1, 7, ["9 versions", "subsetted"])
      ui_click_tab "Sponsor CLs"
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-sponsor-cls"]/tbody/tr[contains(.,"Test CL 2")]').click
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-sponsor-cls"]/tbody/tr[contains(.,"Test CL 2")]')[:class].include? "selected"
      ui_click_tab "Sponsor Extensions"
      wait_for_ajax 10
      ui_check_table_row_indicators("table-sponsor-extensions", 2, 7, ["4 versions", "extension"])
      page.find("#table-sponsor-extensions-bulk-select").click
      wait_for_ajax 20
      ui_click_tab "Test Terminology"
      ui_check_table_info("table-selection-overview", 1, 10, 914)
      ui_check_table_cell("table-selection-overview", 5, 1, "C99076E")
      ui_check_table_cell("table-selection-overview", 1, 6, "0.1.0")
      ui_check_table_cell("table-selection-overview", 2, 6, "58.0.0")
      ui_check_table_row_indicators("table-selection-overview", 2, 7, ["9 versions", "subsetted"])
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

    it "changes version of a sponsor multi-versioned codelist, and corrent exclusion UI update", :type => :feature do
      navigate_to_release_sel
      ui_click_tab "Test Terminology"
      wait_for_ajax 10
      ui_check_table_row_indicators("table-selection-overview", 6, 7, ["4 versions", "extension"])
      ui_check_table_cell("table-selection-overview", 6, 6, "0.3.0")
      find(:xpath, '//*[@id="table-selection-overview"]/tbody/tr[contains(.,"C96783E")]/td[6]/span').click
      sleep 1
      wait_for_ajax 20
      expect(page).to have_content("Select Code Lists Version")
      ui_check_table_cell("history", 3, 7, "Recorded")
      ui_check_table_row_indicators("history", 4, 8, ["Current"])
      ui_check_table_cell("history", 4, 1, "0.1.0")
      find(:xpath, '//*[@id="history"]/tbody/tr[contains(.,"0.1.0")]').click
      click_button "Submit"
      sleep 1
      wait_for_ajax 30
      ui_check_table_row_indicators("table-selection-overview", 6, 7, ["4 versions", "extension", "Current"])
      ui_check_table_cell("table-selection-overview", 6, 6, "0.1.0")
      ui_click_tab "Sponsor Extensions"
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-sponsor-extensions"]/tbody/tr[contains(.,"C96783E")]')[:class].include? "selected"
      ui_click_tab "Test Terminology"
      find(:xpath, '//*[@id="table-selection-overview"]/tbody/tr[contains(.,"C96783E")]/td[8]/span').click
      wait_for_ajax 10
      ui_click_tab "Sponsor Extensions"
      find(:xpath, '//*[@id="table-sponsor-extensions"]/tbody/tr[contains(.,"C96783E")]')[:class].exclude? "selected"
      find(:xpath, '//*[@id="table-sponsor-extensions"]/tbody/tr[contains(.,"C96783E")]').click
      wait_for_ajax 10
    end

    it "change the CDISC version, clears selection", :type => :feature do
      navigate_to_release_sel
      page.find('.card-with-tabs .show-more-btn').click
      sleep 0.2
      ui_dashboard_single_slider '2018-03-30'
      click_button 'Submit selected version'
      ui_confirmation_dialog true
      wait_for_ajax 50
      expect(page).to_not have_content ("rows selected")
      page.evaluate_script 'window.location.reload()'
      wait_for_ajax 10
      ui_click_tab "Test Terminology"
      ui_check_table_info("table-selection-overview", 1, 2, 2)
      ui_check_table_cell("table-selection-overview", 2, 1, "C96783E")
    end

    it "edit lock, extend", :type => :feature do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      navigate_to_release_sel
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#imh_header")[:class].include?("warning")
      page.find("#timeout").click
      wait_for_ajax(120)
      expect(page.find("#imh_header")[:class]).to eq("col-md-12 card")
      sleep Token.get_timeout - (@user_c.edit_lock_warning.to_i / 2) + 2
      page.find("#imh_header")[:class].include?("danger")
      sleep 28
      page.find("#timeout")[:class].include?("disabled")
      page.find("#imh_header")[:class].include?("danger")
      Token.restore_timeout
    end

    it "expires edit lock, prevents additional changes", :type => :feature do
      Token.set_timeout(10)
      navigate_to_release_sel
      sleep 12
      find(:xpath, '//*[@id="table-cdisc-cls"]/tbody/tr[contains(.,"C99078")]').click
      wait_for_ajax 10
      expect(page).to have_content("The changes were not saved as the edit lock has timed out")
      Token.restore_timeout
    end

    it "clears token when leaving page", :type => :feature do
      navigate_to_release_sel
      tokens = Token.where(item_uri: "http://www.s-cubed.dk/TST/V1#TH")
      token = tokens[0]
      click_link 'Return'
      tokens = Token.where(item_uri: "http://www.s-cubed.dk/TST/V1#TH")
      expect(tokens).to match_array([])
    end

  end


  describe "The Curator User", :type => :feature, js:true do

    before :all do
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
      #click_link 'Release select'
      expect(page).to have_content("Find & Select Code Lists")
      expect(page).to have_content("CDISC version used: None")
      expect(page).to have_content("No items were found.")
      expect(page).to have_css(".tab-option.disabled", count: 4)
      page.find(".card-with-tabs .show-more-btn").click
      expect(page).to have_content("Select CDISC Terminology version by dragging the slider")
      expect(page).to have_content("ver. 2015-12-18")
    end

    it "can refresh page while editing in a locked state, creates new version", :type => :feature do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'TST0')]/td/a").click
      wait_for_ajax 10
      context_menu_element("history", 8, "0.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_link "Return"
      wait_for_ajax 10
      ui_check_table_info("history", 1, 1, 1)
      context_menu_element("history", 8, "0.1.0", :edit)
      expect(page).to have_content("Find & Select Code Lists")
      page.driver.browser.navigate.refresh
      expect(page).to have_content("Find & Select Code Lists")
      page.go_back
      wait_for_ajax 20
      ui_check_table_info("history", 1, 3, 3)
    end

  end


end
