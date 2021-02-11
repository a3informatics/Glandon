require 'rails_helper'

describe "Scenario 8, Import and Custom Properties", type: :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include UserAccountHelpers
  include ScenarioHelpers
  include NameValueHelpers
  include EditorHelpers
  include PublicFileHelpers
  include DownloadHelpers

  def sub_dir
    return "features/scenarios"
  end

  describe "System and Content Admin User", type: :feature, js: true do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties_migration_one.ttl")
      load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
      load_cdisc_term_versions(1..45)
      Token.destroy_all
      nv_destroy
      nv_create(parent: '10', child: '999')
      ua_create

      clear_downloads
      delete_all_public_test_files
      copy_file_to_public_files(sub_dir, "scenario_8_import.xlsx", "test")
    end
  
    after :all do
      Import.delete_all
      delete_all_public_test_files
      ua_destroy
    end
  
    before :each do
      ua_sys_and_content_admin_login
    end
  
    after :each do
      ua_logoff
    end

    it "Import Code List and edit its Custom Properties" do
      # Code List Import
      click_navbar_import 
      click_on 'Import Terminology from Excel'

      find(:xpath, "//option[contains(.,'scenario_8_import')]").click
      find('.material-switch').click
      click_on 'Start Import'

      wait_for_ajax 10
      expect(page).to have_content('No errors were detected with the import')

      # Imported Code List Edit 
      click_navbar_code_lists
      wait_for_ajax 20
      ui_table_search('index', 'DMTESTCD')
      find(:xpath, "//tr[contains(.,'DMTESTCD')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2('history', '0.1.0', :edit)
      wait_for_ajax 10

      # Custom Properties Edit 
      click_on 'Show Custom Properties'
      wait_for_ajax 10 

      ui_editor_select_by_location(1, 7)
      ui_editor_fill_inline('crf_display_value', "Test CRF\n")
      ui_editor_check_value(1, 7, 'Test CRF')

      ui_editor_select_by_location(1, 8)
      ui_editor_fill_inline('synonym_sponsor', "Test Synonym\n")
      ui_editor_check_value(1, 8, 'Test Synonym')

      # Adam stage
      ui_editor_select_by_location(1, 9)
      ui_editor_change_bool
      ui_check_table_cell_icon('editor', 1, 9, 'sel-filled')
      
      # DC stage 
      ui_editor_select_by_location(1, 10)
      ui_editor_change_bool
      ui_check_table_cell_icon('editor', 1, 10, 'sel-filled')

      # ED use 
      ui_editor_select_by_location(1, 11)
      ui_editor_change_bool
      ui_check_table_cell_icon('editor', 1, 11, 'sel-filled')

      # SDTM stage 
      ui_editor_select_by_location(1, 12)
      ui_editor_change_bool
      ui_check_table_cell_icon('editor', 1, 12, 'sel-filled')

      click_on 'Return'
      wait_for_ajax 10 

      # Custom Properties Show 
      context_menu_element_v2('history', '0.1.0', :show)
      wait_for_ajax 10

      click_on 'Show Custom Properties'
      wait_for_ajax 10

      # Check Custom Properties were saved 
      ui_check_table_cell('children', 1, 7, 'Test CRF')
      ui_check_table_cell('children', 1, 8, 'Test Synonym')
      ui_check_table_cell_icon('children', 1, 9, 'sel-filled')
      ui_check_table_cell_icon('children', 1, 10, 'sel-filled')
      ui_check_table_cell_icon('children', 1, 11, 'sel-filled')
      ui_check_table_cell_icon('children', 1, 12, 'sel-filled')
    end

  end

end
