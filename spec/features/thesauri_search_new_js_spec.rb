require 'rails_helper'

describe "Thesauri Search", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include UiHelpers

  before :each do
    ua_curator_login
  end

  after :each do
    ua_logoff
  end

  def search_latest
    click_navbar_terminology
    click_link 'Search Terminologies'
    sleep 0.6
    wait_for_ajax(10)
    page.find("#select-all-latest").click
    click_button "Submit and proceed"
    wait_for_ajax(10)
    expect(page).to have_content("Search Latest")
  end

  describe "Search Terminologies (REQ-MDR-TR-040)", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      load_data_file_into_triple_store("thesaurus_sponsor5_impact.ttl")
      ua_create
    end

    after :all do
      ua_destroy
    end

    it "Terminology Selector", js: true do
      click_navbar_terminology
      click_link 'Search Terminologies'
      sleep 0.6
      wait_for_ajax(10)
      expect(page.find("#submit-im-select-button")[:class]).to include("disabled")
      expect(page).to have_css("table#index")
      expect(page).to have_css("table#history")
      expect(page.find("#number-selected")).to have_content("0")
      find(:xpath, "//div[@id='im-select-modal']//table[@id='index']//tr[contains(.,'SPONSOR TEST')]").click
      wait_for_ajax(10)
      ui_check_table_cell("history", 1, 1, "0.1.0")
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[1]").click
      expect(page.find("#number-selected")).to have_content("1")
      expect(find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[1]")[:class]).to include("selected")
      find(:xpath, "//div[@id='im-select-modal']//table[@id='index']/tbody/tr[contains(.,'Controlled Terminology')]").click
      wait_for_ajax(30)
      ui_check_table_cell("history", 1, 2, "2010-04-08 Release")
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[1]").click
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[5]").click
      expect(page.find("#number-selected")).to have_content("3")
      expect(page.find("#submit-im-select-button")[:class]).to_not include("disabled")
      page.find("#select-all-latest").click
      expect(page.find("#number-selected")).to have_content("0")
      expect(page.find("#im-select-modal #index")[:class]).to include("table-disabled")
      expect(page.find("#im-select-modal #history")[:class]).to include("table-disabled")
      page.find("#select-all-current").click
      expect(page.find("#select-all-latest").checked?).to eq(false)
      expect(page.find("#im-select-modal #index")[:class]).to include("table-disabled")
      expect(page.find("#im-select-modal #history")[:class]).to include("table-disabled")
      expect(page.find("#submit-im-select-button")[:class]).to_not include("disabled")
      click_button "Close"
      sleep 0.6
    end

    it "Terminology Selector, single item selection redirects to terminology search page", js: true do
      click_navbar_terminology
      click_link 'Search Terminologies'
      sleep 0.6
      wait_for_ajax(10)
      find(:xpath, "//div[@id='im-select-modal']//table[@id='index']/tbody/tr[contains(.,'Controlled Terminology')]").click
      wait_for_ajax(30)
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[1]").click
      click_button "Submit and proceed"
      wait_for_ajax(10)
      expect(page).to have_content("Controlled Terminology")
      expect(page).to have_content("20.0.0")
      expect(page).to have_content("Search Terminology")
    end

    it "Search multiple Terminologies (REQ-MDR-TR-040)", js:true do
      click_navbar_terminology
      click_link 'Search Terminologies'
      sleep 0.6
      wait_for_ajax(10)
      find(:xpath, "//div[@id='im-select-modal']//table[@id='index']/tbody/tr[contains(.,'Controlled Terminology')]").click
      wait_for_ajax(30)
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[6]").click
      find(:xpath, "//div[@id='im-select-modal']//table[@id='index']/tbody/tr[contains(.,'Airports')]").click
      wait_for_ajax(30)
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[1]").click
      find(:xpath, "//div[@id='im-select-modal']//table[@id='index']/tbody/tr[contains(.,'SPONSOR TEST')]").click
      wait_for_ajax(30)
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[1]").click
      expect(page.find("#number-selected")).to have_content("3")
      click_button "Submit and proceed"
      wait_for_ajax(10)
      expect(page).to have_content("Search Multiple")
      ui_term_column_search(:notation, 'MICROORG')
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_column_search(:notation, 'SKINTYP')
      ui_check_table_info("searchTable", 1, 2, 2)
      click_button 'clear_button'
      ui_term_column_search(:code_list, '124C')
      ui_check_table_cell("searchTable", 1, 4, "ACN_03")
      click_button 'clear_button'
      ui_term_column_search(:code_list, 'A00001')
      ui_check_table_info("searchTable", 1, 8, 8)
      ui_term_column_filter(:thesaurus, "Airports")
      ui_check_table_info("searchTable", 1, 4, 4)
    end

    it "Search latest Terminologies", js:true do
      search_latest
      ui_term_column_search(:notation, 'MICROORG')
      ui_check_table_info("searchTable", 1, 1, 1)
      ui_check_table_cell("searchTable", 1, 9, "CT")
      click_button 'clear_button'
      ui_term_column_search(:code_list, '124C')
      ui_check_table_cell("searchTable", 1, 4, "ACN_03")
      click_button 'clear_button'
      ui_term_column_search(:code_list, 'A00001')
      ui_check_table_info("searchTable", 1, 8, 8)
    end

    it "Search current Terminologies (REQ-MDR-ST-030)", js:true do
      click_navbar_terminology
      wait_for_ajax(10)
      find(:xpath, "//tr[contains(.,'Airports')]/td/a").click
      wait_for_ajax(10)
      context_menu_element("history", 1, "0.1.0", :make_current)
      wait_for_ajax(10)
      ui_check_table_row_indicators("history", 1, 8, ["Current version"], new_style: true)
      click_navbar_cdisc_terminology
      wait_for_ajax(30)
      context_menu_element("history", 1, "2009-10-06", :make_current)
      wait_for_ajax(10)
      ui_check_table_row_indicators("history", 3, 8, ["Current version"], new_style: true)
      click_navbar_terminology
      click_link 'Search Terminologies'
      sleep 0.6
      wait_for_ajax(10)
      page.find("#select-all-current").click
      click_button "Submit and proceed"
      wait_for_ajax(10)
      expect(page).to have_content("Search Current")
      ui_term_column_search(:code_list, 'C85492')
      ui_check_table_info("searchTable", 0, 0, 0)
      click_button 'clear_button'
      ui_term_column_search(:code_list, 'C66741')
      ui_check_table_info("searchTable", 1, 10, 14)
      click_button 'clear_button'
      ui_term_column_search(:definition, 'The oldest LHR Terminal')
      ui_check_table_info("searchTable", 1, 1, 1)
    end

    it "Search table with 'All' set as default", js:true do
      click_link 'settings_button'
      click_link 'All'
      search_latest
      ui_check_page_options("searchTable", { "5" => 5, "10" => 10, "15" => 15, "25" => 25, "50" => 50, "100" => 100})
      ui_term_column_search(:code_list, 'C')
      ui_check_table_info("searchTable", 1, 100, "4,365")
    end

  end

  describe "Search Terminologies, Advanced features (REQ-MDR-TR-040)", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..30)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      ua_create
    end

    after :all do
      ua_destroy
    end

    it "Search, Search Help", js:true do
      search_latest
      find("#search-help").click
      sleep 0.7
      dialog = find "#information-dialog-search"
      expect(dialog).to have_content "How to use Search"
      dialog.find(".show-more-btn").click
      expect(dialog).to have_content "Valid examples:"
      click_on "Dismiss"
      sleep 0.7
      expect(page).to_not have_content "How to use Search"
    end

    it "Search, Filters (single, combine, clear)", js:true do
      search_latest
      ui_term_column_search(:code_list, 'C8')
      ui_check_table_info("searchTable", 1, 10, "2,004")
      ui_term_overall_filter("liter")
      ui_check_table_info("searchTable", 1, 10, 156)
      ui_term_column_filter(:preferred_term, "gram")
      ui_check_table_info("searchTable", 1, 10, 89)
      ui_term_column_filter(:item, "C67")
      ui_check_table_info("searchTable", 1, 4, 4)
      click_button "clear_button"
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_column_search(:code_list, 'C8')
      ui_term_input_empty?("filter", :preferred_term)
      ui_term_input_empty?("filter", :item)
      expect(find("#searchTable_filter input").text).to eq("")
    end

    it "Search, Multiple Terminologies, Source and Version", js:true do
      click_navbar_terminology
      click_link 'Search Terminologies'
      sleep 0.6
      wait_for_ajax(10)
      find(:xpath, "//div[@id='im-select-modal']//table[@id='index']/tbody/tr[contains(.,'Controlled Terminology')]").click
      wait_for_ajax(30)
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[1]").click
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[2]").click
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[3]").click
      expect(page.find("#number-selected")).to have_content("3")
      click_button "Submit and proceed"
      wait_for_ajax(10)
      expect(page).to have_content("Search Multiple")

      ui_term_column_search(:item, 'C62656')
      ui_check_table_info("searchTable", 1, 6, 6)
      ui_check_table_cell("searchTable", 1, 9, "CT")
      ui_check_table_cell("searchTable", 1, 10, "28.0.0")
      ui_check_table_cell("searchTable", 2, 10, "29.0.0")
      ui_check_table_cell("searchTable", 3, 10, "30.0.0")
      ui_term_column_filter(:thesaurus_version, "28")
      ui_check_table_info("searchTable", 1, 2, 2)
    end

    it "Search, can abort search", js:true do
      search_latest
      ui_term_column_search(:code_list, 'C', false)
      expect(page).to have_content("Search running in background")
      click_button "Abort"
      expect(page).to_not have_content("Search running in background")
      ui_check_table_info("searchTable", 0, 0, 0)
    end

    it "Search, advanced syntax", js:true do
      search_latest

      ui_term_overall_search("blood OR muscle")
      ui_check_table_info("searchTable", 1, 10, 279)
      ui_term_overall_search("blood AND muscle")
      ui_check_table_info("searchTable", 1, 1, 1)
      ui_term_overall_search("blood AND muscle -tissue")
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_overall_search(" \"a bone of\"")
      ui_check_table_info("searchTable", 1, 2, 2)
      click_button "clear_button"

      ui_term_column_search(:code_list_name, 'Epoch OR Category')
      ui_check_table_info("searchTable", 1, 10, 65)
      ui_term_column_search(:item, 'C42872 OR C99158')
      ui_check_table_info("searchTable", 1, 2, 2)
      ui_check_table_cell("searchTable", 1, 3, "C99158")
      ui_check_table_cell("searchTable", 2, 3, "C42872")
      click_button "clear_button"

      ui_term_column_search(:item, 'C17634')
      ui_term_column_search(:tags, 'SEND')
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_column_search(:tags, 'SDTM')
      ui_check_table_info("searchTable", 1, 2, 2)
      click_button "clear_button"

      ui_term_column_search(:definition, 'sex AND gender')
      ui_check_table_info("searchTable", 1, 4, 4)
      ui_term_column_search(:definition, 'sex AND gender -sperm')
      ui_check_table_info("searchTable", 1, 2, 2)
      ui_term_column_search(:definition, 'sex AND gender')
      ui_term_column_search(:notation, 'F -M')
      ui_check_table_info("searchTable", 1, 2, 2)

      click_button "clear_button"
      ui_term_column_search(:definition, 'sex AND gender OR person')
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_column_search(:definition, 'sex - gender')
      ui_check_table_info("searchTable", 0, 0, 0)
    end

    it "Search, special characters in search and filters", js:true do
      search_latest

      ui_term_column_search(:code_list_name, 'Unit')
      ui_check_table_info("searchTable", 1, 10, 734)
      ui_term_column_search(:notation, '*')
      ui_check_table_info("searchTable", 1, 10, 72)
      ui_term_column_search(:notation, '/')
      ui_check_table_info("searchTable", 1, 10, 444)
      ui_term_column_search(:notation, '/ AND *')
      ui_check_table_info("searchTable", 1, 10, 72)
      ui_term_column_search(:notation, '/ -*')
      ui_check_table_info("searchTable", 1, 10, 372)

      click_button "clear_button"

      ui_term_column_search(:code_list_name, 'Unit')
      ui_term_column_filter(:notation, '%')
      ui_check_table_info("searchTable", 1, 5, 5)
      ui_term_column_filter(:notation, '/')
      ui_check_table_info("searchTable", 1, 10, 444)

      click_button "clear_button"
      ui_term_column_search(:code_list_name, 'Unit')
      ui_term_column_search(:definition, 'twenty-four hours')
      ui_check_table_info("searchTable", 1, 10, 20)

    end

    it "Search, multiple, differences", js:true do
      click_navbar_terminology
      click_link 'Search Terminologies'
      sleep 0.6
      wait_for_ajax(10)
      find(:xpath, "//div[@id='im-select-modal']//table[@id='index']/tbody/tr[contains(.,'Controlled Terminology')]").click
      wait_for_ajax(30)
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[1]").click
      find(:xpath, "//div[@id='im-select-modal']//table[@id='history']/tbody/tr[5]").click
      click_button "Submit and proceed"
      wait_for_ajax(10)

      ui_term_column_search(:code_list, 'C66781')
      ui_check_table_info("searchTable", 1, 10, 12)
      ui_term_column_search(:definition, 'person')
      ui_check_table_info("searchTable", 1, 1, 1)
      ui_check_table_cell("searchTable", 1, 10, "26.0.0")
      ui_term_column_search(:definition, 'subject')
      ui_check_table_info("searchTable", 1, 1, 1)
      ui_check_table_cell("searchTable", 1, 10, "30.0.0")

      click_button "clear_button"

      ui_term_column_search(:code_list, 'C66781')
      ui_term_column_filter(:synonym, 'hour')
      ui_check_table_info("searchTable", 1, 1, 1)
      ui_check_table_cell("searchTable", 1, 10, "30.0.0")
      ui_term_column_filter(:synonym, '')
      ui_term_overall_filter('hour')
      ui_check_table_info("searchTable", 1, 4, 4)
      ui_term_overall_filter('')
      ui_term_overall_search('hour')
      ui_check_table_info("searchTable", 1, 4, 4)
    end

  end

end
