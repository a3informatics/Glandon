require 'rails_helper'

describe "Biomedical Concept Instances", :type => :feature do

  include DataHelpers
  include UserAccountHelpers
  include UiHelpers
  include ItemsPickerHelpers
  include EditorHelpers
  include WaitForAjaxHelper
  include DownloadHelpers

  def sub_dir
    return "features/biomedical_concepts"
  end

  describe "BCs", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
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
      wait_for_ajax 20
      find(:xpath, "//a[@href='/biomedical_concept_instances']").click
      expect(page).to have_content 'Index: Biomedical Concepts'
      ui_check_table_info("index", 1, 10, 14)
      find(:xpath, "//table[@id='index']/thead/tr/th[contains(.,'Label')]").click #Order data
      ui_check_table_cell("index", 3, 2, "BMI")
      ui_check_table_cell("index", 3, 3, "BMI")
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
      ui_check_table_cell("show", 3, 8, "HEIGHT C25347 (VSTESTCD C66741 v61.0.0)")
    end

    it "show page has terminology reference links", js:true do
      click_navbar_bc
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'Heart Rate')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'HR\''
      context_menu_element_v2('history', 'HR', :show)
      wait_for_ajax 10
      click_on "ARM C32141 (LOC C74456 v62.0.0)"
      wait_for_ajax 10
      expect(page).to have_content 'Shared Preferred Terms'
      expect(page).to have_content 'C32141'
      expect(page).to have_content 'The portion of the upper extremity between the shoulder and the elbow.'
      page.go_back
      click_on "HR C49677 (VSTESTCD C66741 v61.0.0)"
      wait_for_ajax 10
      expect(page).to have_content 'C49677'
      expect(page).to have_content 'The number of heartbeats per unit of time, usually expressed as beats per minute.'
    end

    it "allows to download show BC table as a csv file", js:true do
      click_navbar_bc
      wait_for_ajax 10
      expect(page).to have_content 'Index: Biomedical Concepts'
      ui_table_search("index", "DIABP")
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
      ui_table_search("index", "WEIGHT")
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


    describe "Create a BC", :type => :feature do

      before :all do
        data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
        load_cdisc_term_versions(1..62)
        load_data_file_into_triple_store("mdr_identification.ttl")
        load_data_file_into_triple_store("biomedical_concept_templates.ttl")
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

      it "allows to create a new BC", js:true do
        click_navbar_bc
        wait_for_ajax 20
        expect(page).to have_content 'Index: Biomedical Concepts'
        click_on 'New Biomedical Concept'

        ui_in_modal do
          fill_in 'identifier', with: 'BC Test'
          fill_in 'label', with: 'Test Label'
          find('#new-bc-template').click
          ip_pick_managed_items(:bct, [ { identifier: 'BASIC OBS', version: '1' } ], 'new-bc')

          click_on 'Submit'
        end

        wait_for_ajax 10
        expect(page).to have_content 'Version History of \'BC Test\''
      end

      # Depends on previous test
      it "create BC, clear fields, field validation", js:true do
        click_navbar_bc
        wait_for_ajax 20
        expect(page).to have_content 'Index: Biomedical Concepts'
        click_on 'New Biomedical Concept'

        ui_in_modal do
          click_on 'Submit'

          expect(page).to have_content('Field cannot be empty', count: 3)
          expect(page).to have_selector('.form-group.has-error', count: 3)

          fill_in 'identifier', with: 'BC Test'
          fill_in 'label', with: 'Test Label'

          click_on 'Submit'

          expect(page).to have_content('Field cannot be empty', count: 1)
          expect(page).to have_selector('.form-group.has-error', count: 1)

          click_on 'Clear fields'

          expect(find_field('identifier').value).to eq('')
          expect(find_field('label').value).to eq('')

          fill_in 'identifier', with: 'BC Test'
          fill_in 'label', with: 'Test Label'
          find('#new-bc-template').click
          ip_pick_managed_items(:bct, [ { identifier: 'BASIC OBS', version: '1' } ], 'new-bc')

          click_on 'Submit'
          wait_for_ajax 10

          expect(page).to have_content 'already exists in the database'
          click_on 'Close'
        end

      end

    end

end
