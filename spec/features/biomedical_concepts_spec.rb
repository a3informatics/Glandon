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
      find(:xpath, "//a[@href='/biomedical_concepts']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Biomedical Concepts'
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'HEIGHT\''
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'HEIGHT\''
      context_menu_element_v2('history', 'HEIGHT', :show)
      wait_for_ajax(10)
      expect(page).to have_content 'Show: Biomedical Concept'
      ui_check_table_info("show", 1, 3, 3)
    end

    it "allows to download show BC table as a csv file", js:true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'DIABP')]/td/a", :text => 'History').click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'DIABP\''
      context_menu_element_v2('history', 'DIABP', :show)
      wait_for_ajax(10)
      expect(page).to have_content 'Show: Biomedical Concept'
      ui_check_table_info("show", 1, 6, 6)
      click_on 'CSV'

      file = download_content
      expected = read_text_file_2(sub_dir, "show_csv_expected.csv")
    end

    it "allows to download show BC table as an excel file", js:true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'WEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'WEIGHT\''
      context_menu_element_v2('history', 'WEIGHT', :show)
      wait_for_ajax(10)
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
