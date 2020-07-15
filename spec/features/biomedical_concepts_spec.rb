require 'rails_helper'

describe "Biomedical Concept Instances", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers

  def sub_dir
    return "features/biomedical_concepts"
  end

  describe "BCs", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      ua_create
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

    it "allows access to index page (REQ-MDR-MIT-015)", js:true do
      click_navbar_bc
      wait_for_ajax 10
      find(:xpath, "//a[@href='/biomedical_concepts']").click
      expect(page).to have_content 'Index: Biomedical Concepts'
      ui_check_table_info("index", 1, 10, 14)
      ui_check_table_cell("index", 3, 2, "SYSBP")
      ui_check_table_cell("index", 3, 3, "Systolic Blood Pressure")
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_bc
      wait_for_ajax 10
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'HEIGHT\''
      ui_check_table_cell("history", 1, 1, "0.1.0")
      ui_check_table_cell("history", 1, 4, "HEIGHT")
      ui_check_table_cell("history", 1, 5, "Height")
      ui_check_table_cell("history", 1, 7, "Incomplete")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_bc
      wait_for_ajax 10
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'HEIGHT\''
      context_menu_element_v2('history', 'HEIGHT', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: Biomedical Concept'
      expect(page).to have_content 'Incomplete'
      ui_check_table_info("show", 1, 3, 3)
      ui_check_table_cell("show", 1, 3, "value")
      ui_check_table_cell("show", 1, 4, "Result")
      ui_check_table_cell("show", 1, 5, "Height")
      ui_check_table_cell("show", 1, 6, "PQR")
      ui_check_table_cell("show", 1, 7, "5.2")
      ui_check_table_cell("show", 3, 8, "HEIGHT (Code List: C66741 v61.0.0)")
    end

    it "show page has terminology reference links", js:true do
      click_navbar_bc
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'Heart Rate')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'HR\''
      context_menu_element_v2('history', 'HR', :show)
      wait_for_ajax 10
      click_on "ARM (Code List: C74456 v62.0.0)"
      wait_for_ajax 10
      expect(page).to have_content 'Shared Preferred Terms'
      expect(page).to have_content 'C32141'
      expect(page).to have_content 'The portion of the upper extremity between the shoulder and the elbow.'
      page.go_back
      click_on "HR (Code List: C66741 v61.0.0)"
      wait_for_ajax 10
      expect(page).to have_content 'C49677'
      expect(page).to have_content 'The number of heartbeats per unit of time, usually expressed as beats per minute.'
    end

    it "allows to download show BC table as a csv file", js:true do
      click_navbar_bc
      wait_for_ajax 10
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'DIABP')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'DIABP\''
      context_menu_element_v2('history', 'DIABP', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: Biomedical Concept'
      ui_check_table_info("show", 1, 6, 6)
      click_on 'CSV'

      file = download_content
      expected = read_text_file_2(sub_dir, "show_csv_expected.csv")
    end

    it "allows to download show BC table as an excel file", js:true do
      click_navbar_bc
      wait_for_ajax 10
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'WEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'WEIGHT\''
      context_menu_element_v2('history', 'WEIGHT', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: Biomedical Concept'
      ui_check_table_info("show", 1, 3, 3)
      click_on 'Excel'

      file = download_content
      expected = read_text_file_2(sub_dir, "show_excel_expected.xlsx")
    end

    # it "allows for a BC to be cloned", js:true do

    # it "allows for a BC to be edited (REQ-MDR-BC-010)", js:true do


  end

end
