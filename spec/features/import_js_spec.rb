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
    click_link 'Import Excel Terminology' if type == :excel
    click_link 'Import ODM Terminology' if type == :odm
    select "#{path}", from: "filename"
    select "Import Terminology", from: "thesaurus"
    click_button 'List'
    wait_for_ajax(10)
  end

  describe "Import Terminology, Curator User, Excel", :type => :feature do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      Token.destroy_all
      AuditTrail.destroy_all
      clear_downloads
      copy_file_to_public_files(sub_dir, "import_1.xlsx", "upload")
      copy_file_to_public_files(sub_dir, "import_2.xlsx", "upload")
      @path_1 = public_path("upload", "import_1.xlsx")
      @path_2 = public_path("upload", "import_2.xlsx")
    end

    after :all do
      ua_destroy
      delete_public_file("upload", "import_1.xlsx")
      delete_public_file("upload", "import_2.xlsx")
    end
    
    before :each do
      ua_content_admin_login
      create_terminology("IMPORT 1")
    end

    after :each do
      delete_terminology("IMPORT 1")
    end

    it "import into terminolgy, initial setup", scenario: true, js: true do
      click_table_link 'IMPORT 1', 'History'
      expect_page "History: IMPORT 1"
      click_navbar_import
      expect_page 'Import Centre'
      click_link 'Import Excel Terminology'
      expect_page 'Import Terminology - EXCEL'
      ui_select_check_selected("thesaurus", "Select the target terminology (Status = 'Incomplete') ...")
      ui_select_check_options("thesaurus", ["Import Terminology"])
      ui_button_enabled('list_button')
      ui_button_disabled('import_button')
      expect(page).to have_link "Close"
      ui_select_check_options("filename", ["#{@path_1}", "#{@path_2}"])
    end

    it "import into terminolgy, no selections", scenario: true, js: true do
      click_navbar_import
      click_link 'Import Excel Terminology'
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
      ui_check_table_cell("list_table", 1, 1, "SN667XX1")
      ui_check_table_cell("list_table", 2, 1, "SN667XX2")
      ui_button_enabled('import_button')
    end

    it "import into terminolgy, selection"

    it "import into terminolgy, import, single", scenario: true, js: true do
      get_excel_code_lists
      ui_table_row_click("list_table", "SN667XX1")
    #pause
      click_button 'Import'
      wait_for_ajax(20)
      ui_check_flash_message_present
      expect_page 'Code lists imported, no errors detected.'
      flash_cleared
    end

    it "import into terminolgy, re-import check", scenario: true, js: true do
      get_excel_code_lists
      ui_table_row_click("list_table", "SN667XX2")
      click_button 'Import'
      wait_for_ajax(20)
      ui_check_flash_message_present
      expect_page 'Code lists imported, no errors detected.'
      flash_cleared
      ui_table_row_click("list_table", "SN667XX2")
      click_button 'Import'
      wait_for_ajax(20)
      ui_check_flash_message_present
      expect_page 'Code lists imported, some errors detected.'
      expect_page 'The Thesaurus Concept, identifier SN667XX2, already exists in the database.'
      flash_cleared
    end

    it "import into terminolgy, import, multiple, clear terminology, re-import", scenario: true, js: true do
      get_excel_code_lists
      ui_table_row_click("list_table", "SN667XX1")
      ui_table_row_click("list_table", "SN667XX2")
      click_button 'Import'
      wait_for_ajax(20)
      ui_check_flash_message_present
      expect_page 'Code lists imported, no errors detected.'
      flash_cleared
      delete_terminology("IMPORT 1")
      create_terminology("IMPORT 1")
      get_excel_code_lists
      ui_table_row_click("list_table", "SN667XX1")
      ui_table_row_click("list_table", "SN667XX2")
      click_button 'Import'
      wait_for_ajax(20)
      ui_check_flash_message_present
      expect_page 'Code lists imported, no errors detected.'
      flash_cleared
    end

  end

 describe "Import Terminology, Curator User, ODM", :type => :feature do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      Token.destroy_all
      AuditTrail.destroy_all
      clear_downloads
      copy_file_to_public_files(sub_dir, "import_3.xml", "upload")
      copy_file_to_public_files(sub_dir, "import_4.xml", "upload")
      @path_3 = public_path("upload", "import_3.xml")
      @path_4 = public_path("upload", "import_4.xml")
    end

    after :all do
      ua_destroy
      delete_public_file("upload", "import_3.xml")
      delete_public_file("upload", "import_4.xml")
    end
    
    before :each do
      ua_content_admin_login
      create_terminology("IMPORT 1")
    end

    after :each do
      delete_terminology("IMPORT 1")
    end

    it "import into terminolgy, import, multiple, clear terminology, re-import", scenario: true, js: true do
      get_odm_code_lists
      ui_table_row_click("list_table", "cl_ethnic")
      ui_table_row_click("list_table", "c_cbp")
      click_button 'Import'
      wait_for_ajax(20)
      ui_check_flash_message_present
      expect_page 'Code lists imported, no errors detected.'
      flash_cleared
      delete_terminology("IMPORT 1")
      create_terminology("IMPORT 1")
      get_odm_code_lists
      ui_table_row_click("list_table", "cl_ethnic")
      ui_table_row_click("list_table", "c_cbp")
      click_button 'Import'
      wait_for_ajax(20)
      ui_check_flash_message_present
      expect_page 'Code lists imported, no errors detected.'
      flash_cleared
    end

  end

end