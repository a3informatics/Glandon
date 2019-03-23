require 'rails_helper'

describe "Imports", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include UserAccountHelpers
  include AuditTrailHelpers
  include ScenarioHelpers
  include PublicFileHelpers

  def sub_dir
    return "features/import"
  end

  def delete_all_imports
    click_link 'Delete All'
    ui_click_ok "Are you sure?"
  end

  def check_successful_import(row)
    ui_table_row_col_link_click("main", row, 8)
    expect_page "No errors were detected with the import."
    expect_page "Auto load was not set so the item was not imported."
    click_link 'Close'
  end

  def check_unsuccessful_import(row)
    ui_table_row_col_link_click("main", row, 8)
    expect_page 'Errors were detected during the processing of the import file. See the error table to the right.'
    click_link 'Close'
  end

  def flash_cleared
    sleep 6 # allow flash message to disappear
    ui_check_no_flash_message_present
  end

  def delete_terminology(identifier)
    click_navbar_terminology
    click_table_link "#{identifier}", 'History'
    click_table_link "#{identifier}", 'Delete'
    ui_click_ok
    expect_page 'Index: Terminology'     
  end

  def create_terminology(identifier)
    click_navbar_terminology
    expect_page 'Index: Terminology'
    click_link 'New'
    expect_page 'New Terminology:'
    fill_in 'thesauri[identifier]', with: identifier
    fill_in 'thesauri[label]', with: 'Import Terminology'
    click_button 'Create'
    expect_page "Terminology was successfully created."   
  end

  def get_excel_code_lists
    get_code_lists(:excel, @path_1)
  end

  def get_odm_code_lists
    get_code_lists(:odm, @path_4)
  end

  def get_code_lists(type, path)
    click_navbar_import
    click_link 'Import Terminology from Excel' if type == :excel
    click_link 'Import Terminology from ODM' if type == :odm
    select "#{path}", from: "filename"
    select "Import Terminology", from: "thesaurus"
    click_button 'List'
    wait_for_ajax(10)
  end

  describe "Import Terminology, Curator User, Excel", :type => :feature do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      Token.destroy_all
      AuditTrail.destroy_all
      Import.delete_all
      clear_downloads
      copy_file_to_public_files(sub_dir, "import_1.xlsx", "test")
      copy_file_to_public_files(sub_dir, "import_2.xlsx", "test")
      @path_1 = public_path("test", "import_1.xlsx")
      @path_2 = public_path("test", "import_2.xlsx")
    end

    after :all do
      ua_destroy
      delete_public_file("test", "import_1.xlsx")
      delete_public_file("test", "import_2.xlsx")
      Import.delete_all
    end
    
    before :each do
      ua_content_admin_login
      create_terminology("IMPORT 1")
      Import.delete_all
    end

    after :each do
      delete_terminology("IMPORT 1")
      Import.delete_all
    end

    it "import into terminolgy, initial setup", scenario: true, js: true do
      click_table_link 'IMPORT 1', 'History'
      expect_page "History: IMPORT 1"
      click_navbar_import
      expect_page 'Import Centre'
      click_link 'Import Terminology from Excel'
      expect_page 'Import Terminology from Excel'
      ui_select_check_selected("thesaurus", "Select the target terminology (Status = 'Incomplete') ...")
      ui_select_check_options("thesaurus", ["Import Terminology"])
      ui_button_enabled('list_button')
      #ui_button_disabled('import_button')
      expect(page).to have_link "Close"
      ui_select_check_options("filename", ["#{@path_1}", "#{@path_2}"])
    end

    it "import into terminolgy, no selections", scenario: true, js: true do
      click_navbar_import
      click_link 'Import Terminology from Excel'
      click_button 'List'
      ui_check_flash_message_present
      expect_page 'You need to select a terminology and a file.'
      flash_cleared
      select "#{@path_1}", from: "filename"
      click_button 'List'
      expect_page 'You need to select a terminology and a file.'
      select "Import Terminology", from: "thesaurus"
      click_button 'List'
      wait_for_ajax(10)
      ui_check_table_cell("items_table", 1, 1, "SN667XX1")
      ui_check_table_cell("items_table", 2, 1, "SN667XX2")
      ui_button_enabled('import_button')
    end

    it "import into terminolgy, selection"

    it "import into terminolgy, import, single", scenario: true, js: true do
      get_excel_code_lists
      ui_table_row_click("items_table", "SN667XX1")
      click_button 'Import'
      wait_for_ajax
      ui_button_enabled('import_index_button')
      click_button 'import_index_button'
    #pause
      ui_check_table_cell("main", 1, 3, "SN667XX1")
      check_successful_import(1)
      delete_all_imports
    end

    it "import into terminolgy, re-import check", scenario: true, js: true do
      get_excel_code_lists
      ui_table_row_click("items_table", "SN667XX2")
      click_button 'Import'
      wait_for_ajax
      ui_button_enabled('import_index_button')
      click_button 'import_index_button'
      get_excel_code_lists
      ui_table_row_click("items_table", "SN667XX2")
      click_button 'Import'
      wait_for_ajax
      ui_button_enabled('import_index_button')
      click_button 'import_index_button'
      ui_check_table_cell("main", 1, 3, "SN667XX2")
      ui_check_table_cell("main", 2, 3, "SN667XX2")
      check_successful_import(1)
      check_unsuccessful_import(2)
      delete_all_imports
    end

    it "import into terminolgy, import, multiple, clear terminology, re-import", scenario: true, js: true do
      get_excel_code_lists
      ui_table_row_click("items_table", "SN667XX1")
      ui_table_row_click("items_table", "SN667XX2")
      click_button 'Import'
      wait_for_ajax
      ui_button_enabled('import_index_button')
      delete_terminology("IMPORT 1")
      create_terminology("IMPORT 1")
      get_excel_code_lists
      ui_table_row_click("items_table", "SN667XX1")
      ui_table_row_click("items_table", "SN667XX2")
      click_button 'Import'
      wait_for_ajax
      ui_button_enabled('import_index_button')
      click_button 'import_index_button'
      ui_check_table_cell("main", 1, 3, "SN667XX2")
      ui_check_table_cell("main", 2, 3, "SN667XX1")
      ui_check_table_cell("main", 3, 3, "SN667XX2")
      ui_check_table_cell("main", 4, 3, "SN667XX1")
      check_successful_import(1)
      check_successful_import(2)
      check_successful_import(3)
      check_successful_import(4)
      delete_all_imports
    end

  end

 describe "Import Terminology, Curator User, ODM", :type => :feature do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      Token.destroy_all
      AuditTrail.destroy_all
      Import.delete_all
      clear_downloads
      copy_file_to_public_files(sub_dir, "import_3.xml", "test")
      copy_file_to_public_files(sub_dir, "import_4.xml", "test")
      @path_3 = public_path("test", "import_3.xml")
      @path_4 = public_path("test", "import_4.xml")
    end

    after :all do
      ua_destroy
      Import.delete_all
      delete_public_file("test", "import_3.xml")
      delete_public_file("test", "import_4.xml")
    end
    
    before :each do
      Import.delete_all
      ua_content_admin_login
      create_terminology("IMPORT 1")
    end

    after :each do
      Import.delete_all
      delete_terminology("IMPORT 1")
    end

    it "import into terminolgy, import, multiple, clear terminology, re-import", scenario: true, js: true do
      get_odm_code_lists
      ui_table_row_click("items_table", "cl_ethnic")
      ui_table_row_click("items_table", "c_cbp")
      click_button 'Import'
      wait_for_ajax
      ui_button_enabled('import_index_button')
      click_button 'import_index_button'
      delete_terminology("IMPORT 1")
      create_terminology("IMPORT 1")
      get_odm_code_lists
      ui_table_row_click("items_table", "cl_ethnic")
      ui_table_row_click("items_table", "c_cbp")
      click_button 'Import'
      wait_for_ajax
      ui_button_enabled('import_index_button')
      click_button 'import_index_button'
    end

  end

end