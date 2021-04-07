require 'rails_helper'

describe "Thesauri Search", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include UiHelpers
  include ItemsPickerHelpers

  before :each do
    ua_curator_login
  end

  after :each do
    ua_logoff
  end

  describe "Search Terminologies (REQ-MDR-TR-040)", type: :feature, js: true do

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

    it "Single item selection leads to Terminology Search" do
      search_terminologies([
        { identifier: 'CT', version: '2010-04-08' }
      ])
 
      expect(page).to have_content("Controlled Terminology")
      expect(page).to have_content("20.0.0")
      expect(page).to have_content("Make a new column or global search to see data")
    end

    it "Multiple item selection leads to Multiple Terminologies Search (REQ-MDR-TR-040)" do
      search_terminologies([
        { identifier: 'CT', version: '2009-02-18' },
        { identifier: 'AIRPORTS', version: '1' },
        { identifier: 'SPONSOR TEST', version: '1' }
      ])
     
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

    it "Search latest Terminologies" do
      search_all('latest')
      expect(page).to have_content("Search Latest")

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

    it "Search current Terminologies (REQ-MDR-ST-030)" do
      make_current('Airports', '1')
      make_current('CT', '2009-10-06')

      search_all('current')
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

    it "Search table with 'All' set as default" do
      click_link 'settings_button'
      click_link 'All'

      search_all('latest')
      ui_check_page_options("searchTable", { "5" => 5, "10" => 10, "15" => 15, "25" => 25, "50" => 50, "100" => 100})
      ui_term_column_search(:code_list, 'C')
      ui_check_table_info("searchTable", 1, 100, 4365)
    end

  end

  describe "Search Terminologies, Advanced features (REQ-MDR-TR-040)", type: :feature, js: true do

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

    it "Search, Search Help" do
      search_all('latest')

      find("#search-help").click
      ui_in_modal do 
        expect(page).to have_content "How to use Search"
        find(".expandable-content-btn").click
        expect(page).to have_content "Valid examples:"
        click_on "Dismiss"
      end

      expect(page).to_not have_content "How to use Search"
    end

    it "Search, Filters (single, combine, clear)" do
      search_all('latest')

      ui_term_column_search(:code_list, 'C8')
      ui_check_table_info("searchTable", 1, 10, 2004)
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

    it "Search, Multiple Terminologies, Source and Version" do
      search_terminologies([
        { identifier: 'CT', version: '2012-03-23' },
        { identifier: 'CT', version: '2012-01-02' },
        { identifier: 'CT', version: '2011-12-09' }
      ])
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

    it "Search, can abort search" do
      search_all('latest')

      ui_term_column_search(:code_list, 'C', false)
      expect(page).to have_content("Search running in background")
      click_button "Abort"
      expect(page).to_not have_content("Search running in background")
      ui_check_table_info("searchTable", 0, 0, 0)
    end

    it "Search, advanced syntax - NOTE - CHECK FOR TAGS" do
      search_all('latest')

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
      ui_check_table_info("searchTable", 1, 2, 2)
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

    it "Search, special characters in search and filters" do
      search_all('latest')

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

    it "Search, multiple, differences" do
      search_terminologies([
        { identifier: 'CT', version: '2012-03-23' },
        { identifier: 'CT', version: '2011-06-10' }
      ])

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

  def search_all(type)
    click_navbar_terminology
    wait_for_ajax 10 
    click_on 'Search Terminologies'

    ui_in_modal do
      click_on 'Search in Latest' if type.eql? 'latest'
      click_on 'Search in Current' if type.eql? 'current'
    end 
    wait_for_ajax 10
  end

  def search_terminologies(terminologies) 
    click_navbar_terminology
    wait_for_ajax 10 

    click_on 'Search Terminologies'
    ui_in_modal do
      ip_pick_managed_items( :thesauri, terminologies, 'th-search' )
    end
    wait_for_ajax 10
  end

  def make_current(identifier, version)
    click_navbar_terminology
    wait_for_ajax 10

    find(:xpath, "//tr[contains(.,'#{ identifier }')]/td/a").click
    wait_for_ajax 10
    context_menu_element_v2("history", version, :make_current)
    wait_for_ajax 10

    ui_table_search('history', version)
    ui_check_table_row_indicators("history", 1, 8, ["Current version"], new_style: true)
  end

end
