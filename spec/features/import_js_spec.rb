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
    click_button 'Delete All'
    ui_confirmation_dialog true
  end

  def check_successful_import(row)
    ui_table_row_col_link_click("main", row, 8)
    expect_page "No errors were detected with the import."
    expect_page "Auto load was not set so the item was not imported."
    click_on 'Return'
  end

  def check_unsuccessful_import(row)
    ui_table_row_col_link_click("main", row, 8)
    expect_page 'Errors were detected during the processing of the import file. See the error table.'
    click_on 'Return'
  end

  def flash_cleared
    sleep 6 # allow flash message to disappear
    ui_check_no_flash_message_present
  end

  def delete_terminology(identifier)
    click_navbar_terminology
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
    wait_for_ajax 10
    context_menu_element_v2("history", identifier, :delete)
    ui_confirmation_dialog true
    wait_for_ajax 10
  end

  def create_terminology(identifier)
    ui_create_terminology(identifier, "Import Terminology")
  end

  def import_select_files(names)
    names.each do |name|
      find(:xpath, "//select[@id='imports_files_']/option[contains(.,'#{name}')]").click(:shift)
    end
  end

  def import_check_file_count(count)
    expect(all(:xpath, "//*[@id='imports_files_']/option").count).to eq(count)
  end

  def import_set_date(date)
    fill_in "imports_date", with: date
  end

  def check_import_table(row, file, complete, successful, auto_load)
    page.has_xpath?("//table[@id='main']/tbody/tr[#{row}]/td[contains(.,\"#{file}\")]")
    page.has_xpath?("//table[@id='main']/tbody/tr[#{row}]/td[5]/span[@class=\"icon-#{complete ? "ok" : "times"}\"]")
    page.has_xpath?("//table[@id='main']/tbody/tr[#{row}]/td[6]/span[@class=\"icon-#{successful ? "ok" : "times"}\"]")
    page.has_xpath?("//table[@id='main']/tbody/tr[#{row}]/td[7]/span[@class=\"icon-#{auto_load ? "ok" : "times"}\"]")
  end

  # def get_excel_code_lists
  #   get_code_lists(:excel, @path_1)
  # end
  #
  # def get_odm_code_lists
  #   get_code_lists(:odm, @path_4)
  # end
  #
  # def get_code_lists(type, path)
  #   click_navbar_import
  #   click_link 'Import CDISC Term (Excel)' if type == :excel
  #   # click_link 'Import Terminology from ODM' if type == :odm
  #   select "#{path}", from: "imports_files_"
  #   select "Import Terminology", from: "thesaurus"
  #   click_button 'List'
  #   wait_for_ajax(10)
  # end

  describe "Import CDISC Terminology, Content Admin User", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..46)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      Token.destroy_all
      AuditTrail.destroy_all
      Import.delete_all
      clear_downloads
      delete_all_public_test_files
      copy_file_to_public_files(sub_dir, "import_input_1a.xlsx", "test")
      copy_file_to_public_files(sub_dir, "import_input_2.xlsx", "test")
      ua_create
    end

    after :all do
      ua_destroy
      Import.delete_all
      delete_all_public_test_files
    end

    before :each do
      ua_content_admin_login
    end

    after :each do
      ua_logoff
    end

    it "Import a CDISC Terminology (Excel), no auto-load, success", js: true do
      click_navbar_import
      expect_page 'Import Centre'
      click_on 'Import CDISC Term (Excel)'
      expect_page 'Import CDISC Terminology using Excel'
      import_check_file_count 2
      import_select_files ["import_input_1a"]
      import_set_date "22/11/2018"
      click_on "Start Import"
      wait_for_ajax 10
      expect_page "Identifier: CT, Owner: CDISC"
      expect_page "No errors were detected with the import."
      expect_page "Auto load was not set so the item was not imported."
    end

    it "Import a CDISC Terminology (Excel), auto-load, success", js: true do
      click_navbar_import
      expect_page 'Import Centre'
      click_on 'Import CDISC Term (Excel)'
      expect_page 'Import CDISC Terminology using Excel'
      import_check_file_count 2
      import_select_files ["import_input_1a"]
      import_set_date "22/11/2018"
      find(".material-switch").click
      click_on "Start Import"
      wait_for_ajax 10
      expect_page "Identifier: CT, Owner: CDISC"
      expect_page "No errors were detected with the import."
      click_on "Go to history"
      wait_for_ajax 20
      ui_check_table_cell("history", 1, 1, "47.0.0")
      ui_check_table_cell("history", 1, 6, "2018-11-22")
    end

    it "Import a CDISC Terminology (Excel), error", js: true do
      click_navbar_import
      expect_page 'Import Centre'
      click_on 'Import CDISC Term (Excel)'
      expect_page 'Import CDISC Terminology using Excel'
      import_check_file_count 2
      import_select_files ["import_input_2"]
      import_set_date "25/11/2018"
      click_on "Start Import"
      wait_for_ajax 10
      expect_page "Identifier: CT, Owner: CDISC"
      expect_page "Errors were detected during the processing of the import file. See the error table."
      expect(all(:xpath, "//table[@id='errors']/tbody/tr").count).to eq(10)
    end

    it "Current Imports, list, show and delete imports", js: true do
      click_navbar_import
      expect_page 'Import Centre'
      click_on 'Current Imports'
      wait_for_ajax 10
      expect_page 'Showing all import jobs.'
      expect(all(:xpath, "//table[@id='main']/tbody/tr").count).to eq(3)
      check_import_table(1, "import_input_1a", true, true, false)
      check_import_table(2, "import_input_1a", true, true, true)
      check_import_table(3, "import_input_2", true, false, false)
      find(:xpath, "//tr[contains(.,'import_input_2')]/td/a", :text => "Show").click
      wait_for_ajax 10
      expect_page "Identifier: CT, Owner: CDISC"
      expect_page "Errors were detected during the processing of the import file. See the error table."
      click_on "Return"
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'import_input_2')]/td/a", :text => "Delete").click
      ui_confirmation_dialog true
      wait_for_ajax 10
      expect(all(:xpath, "//table[@id='main']/tbody/tr").count).to eq(2)
      click_on "Delete all"
      ui_confirmation_dialog true
      wait_for_ajax 10
      expect_page "No Imports found."
      expect(Import.all.count).to eq(0)
    end

    it "Import a CDISC Terminology (API), error", js: true do
      click_navbar_import
      expect_page 'Import Centre'
      click_on 'Import CDISC Term (API)'
      expect_page 'Import CDISC Terminology using API'
      import_set_date "01/01/2019"
      click_on "Start Import"
      wait_for_ajax 20
      expect_page "Identifier: CT, Owner: CDISC"
      expect_page "Errors were detected during the processing of the import file. See the error table."
    end

  end

  # describe "Import Terminology, Curator User", :type => :feature do
  #
  #   before :all do
  #     data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_2.ttl", "CT_V43.ttl", "CT_ACME_TEST.ttl"]
  #     load_files(schema_files, data_files)
  #     ua_create
  #     Token.destroy_all
  #     AuditTrail.destroy_all
  #     Import.delete_all
  #     clear_downloads
  #     delete_all_public_test_files
  #     copy_file_to_public_files(sub_dir, "import_1.xlsx", "test")
  #     copy_file_to_public_files(sub_dir, "import_2.xlsx", "test")
  #     @path_1 = public_path("test", "import_1.xlsx")
  #     @path_2 = public_path("test", "import_2.xlsx")
  #   end
  #
  #   after :all do
  #     ua_destroy
  #     delete_all_public_test_files
  #   end
  #
  #   before :each do
  #     ua_content_admin_login
  #     create_terminology("IMPORT 1")
  #   end
  #
  #   after :each do
  #     delete_terminology("IMPORT 1")
  #     Import.delete_all
  #     ua_logoff
  #   end

    #
    # it "import into terminolgy, initial setup", scenario: true, js: true do
    #   click_table_link 'IMPORT 1', 'History'
    #   expect_page "History: IMPORT 1"
    #   click_navbar_import
    #   expect_page 'Import Centre'
    #   click_link 'Import Terminology from Excel'
    #   expect_page 'Import Terminology from Excel'
    #   ui_select_check_selected("thesaurus", "Select the target terminology (Status = 'Incomplete') ...")
    #   ui_select_check_options("thesaurus", ["Import Terminology"])
    #   ui_button_enabled('list_button')
    #   #ui_button_disabled('import_button')
    #   expect(page).to have_link "Close"
    #   ui_select_check_options("filename", ["#{@path_1}", "#{@path_2}"])
    # end
    #
    # it "import into terminolgy, no selections", scenario: true, js: true do
    #   click_navbar_import
    #   click_link 'Import Terminology from Excel'
    #   click_button 'List'
    #   ui_check_flash_message_present
    #   expect_page 'You need to select a terminology and a file.'
    #   flash_cleared
    #   select "#{@path_1}", from: "filename"
    #   click_button 'List'
    #   expect_page 'You need to select a terminology and a file.'
    #   select "Import Terminology", from: "thesaurus"
    #   click_button 'List'
    #   wait_for_ajax(10)
    #   ui_check_table_cell("items_table", 1, 1, "SN667XX1")
    #   ui_check_table_cell("items_table", 2, 1, "SN667XX2")
    #   ui_button_enabled('import_button')
    # end
    #
    # it "import into terminolgy, selection"
    #
    # it "import into terminolgy, import, single", scenario: true, js: true do
    #   get_excel_code_lists
    #   ui_table_row_click("items_table", "SN667XX1")
    #   click_button 'Import'
    #   wait_for_ajax
    #   ui_button_enabled('import_index_button')
    #   click_button 'import_index_button'
    #   ui_check_table_cell("main", 1, 3, "SN667XX1")
    #   check_successful_import(1)
    #   delete_all_imports
    # end
    #
    # it "import into terminolgy, re-import check", scenario: true, js: true do
    #   get_excel_code_lists
    #   ui_table_row_click("items_table", "SN667XX2")
    #   click_button 'Import'
    #   wait_for_ajax
    #   ui_button_enabled('import_index_button')
    #   click_button 'import_index_button'
    #   get_excel_code_lists
    #   ui_table_row_click("items_table", "SN667XX2")
    #   click_button 'Import'
    #   wait_for_ajax
    #   ui_button_enabled('import_index_button')
    #   click_button 'import_index_button'
    #   ui_check_table_cell("main", 1, 3, "SN667XX2")
    #   ui_check_table_cell("main", 2, 3, "SN667XX2")
    #   check_successful_import(1)
    #   check_unsuccessful_import(2)
    #   delete_all_imports
    # end
    #
    # it "import into terminolgy, import, multiple, clear terminology, re-import", scenario: true, js: true do
    #   get_excel_code_lists
    #   ui_table_row_click("items_table", "SN667XX1")
    #   ui_table_row_click("items_table", "SN667XX2")
    #   click_button 'Import'
    #   wait_for_ajax
    #   ui_button_enabled('import_index_button')
    #   delete_terminology("IMPORT 1")
    #   create_terminology("IMPORT 1")
    #   get_excel_code_lists
    #   ui_table_row_click("items_table", "SN667XX1")
    #   ui_table_row_click("items_table", "SN667XX2")
    #   click_button 'Import'
    #   wait_for_ajax
    #   ui_button_enabled('import_index_button')
    #   click_button 'import_index_button'
    #   ui_check_table_cell("main", 1, 3, "SN667XX2")
    #   ui_check_table_cell("main", 2, 3, "SN667XX1")
    #   ui_check_table_cell("main", 3, 3, "SN667XX2")
    #   ui_check_table_cell("main", 4, 3, "SN667XX1")
    #   check_successful_import(1)
    #   check_successful_import(2)
    #   check_successful_import(3)
    #   check_successful_import(4)
    #   delete_all_imports
    # end

  # end

 # describe "Import Terminology, Curator User, ODM", :type => :feature do
 #
 #    before :all do
 #      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl"]
 #      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
 #      load_files(schema_files, data_files)
 #      clear_iso_concept_object
 #      clear_iso_namespace_object
 #      clear_iso_registration_authority_object
 #      clear_iso_registration_state_object
 #      ua_create
 #      Token.destroy_all
 #      AuditTrail.destroy_all
 #      Import.delete_all
 #      clear_downloads
 #      copy_file_to_public_files(sub_dir, "import_3.xml", "test")
 #      copy_file_to_public_files(sub_dir, "import_4.xml", "test")
 #      @path_3 = public_path("test", "import_3.xml")
 #      @path_4 = public_path("test", "import_4.xml")
 #    end
 #
 #    after :all do
 #      ua_destroy
 #      Import.delete_all
 #      delete_public_file("test", "import_3.xml")
 #      delete_public_file("test", "import_4.xml")
 #    end
 #
 #    before :each do
 #      Import.delete_all
 #      ua_content_admin_login
 #      create_terminology("IMPORT 1")
 #    end
 #
 #    after :each do
 #      Import.delete_all
 #      delete_terminology("IMPORT 1")
 #      ua_logoff
 #    end
 #
 #    it "import into terminolgy, import, multiple, clear terminology, re-import", scenario: true, js: true do
 #      get_odm_code_lists
 #      ui_table_row_click("items_table", "cl_ethnic")
 #      ui_table_row_click("items_table", "c_cbp")
 #      click_button 'Import'
 #      wait_for_ajax
 #      ui_button_enabled('import_index_button')
 #      click_button 'import_index_button'
 #      delete_terminology("IMPORT 1")
 #      create_terminology("IMPORT 1")
 #      get_odm_code_lists
 #      ui_table_row_click("items_table", "cl_ethnic")
 #      ui_table_row_click("items_table", "c_cbp")
 #      click_button 'Import'
 #      wait_for_ajax
 #      ui_button_enabled('import_index_button')
 #      click_button 'import_index_button'
 #    end
 #
 #  end

end
