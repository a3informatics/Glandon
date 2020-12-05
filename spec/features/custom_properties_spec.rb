require 'rails_helper'

describe "Custom Properties", type: :feature  do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include EditorHelpers
  include NameValueHelpers
  include ItemsPickerHelpers

  after :all do
    Token.destroy_all
    ua_destroy
    set_transactional_tests true
  end

  after :each do
    ua_logoff
  end

  describe "Show Custom Properties, Curator user", type: :feature, js:true do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
      load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
      load_cdisc_term_versions(1..45)
      ua_create
      Token.destroy_all
      nv_destroy
      nv_create(parent: '10', child: '999')

      set_transactional_tests false
    end

    before :each do
      ua_curator_login
    end

    it "allows to load, show and hide Custom Properties in a Code List" do
      click_navbar_code_lists
      wait_for_ajax 20

      ui_table_search('index', 'C100130')
      find(:xpath, "//tr[contains(.,'Sanofi')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2('history', '1.0.0', :show)
      wait_for_ajax 20

      expect(page).to have_button 'Show Custom Properties'
      ui_check_table_info('children', 1, 10, 55)
      check_table_headers('children', cl_standard_columns)

      # Show CPs
      show_custom_props

      # Check CP Columns
      check_table_headers('children', cl_sponsor_cps_columns)
      ui_table_search('children', 'C96658')
      # Check standard and CP data
      check_cell_content('children', 1, 1, 'C96658')
      check_cell_content('children', 1, 2, 'SISTER, BIOLOGICAL MATERNAL HALF')
      check_cell_content('children', 1, 6, 'SDTM')
      check_cell_content('children', 1, 7, 'Biological Maternal Half Sister') # CRF Display Value
      check_cell_content('children', 1, 8, false)  # Adam stage
      check_cell_content('children', 1, 9, true) # DC stage
      check_cell_content('children', 1, 10, true) # SDTM stage

      # Hide CPs
      hide_custom_props
      check_table_headers('children', cl_standard_columns)

      # Show CPs again without server load
      show_custom_props
      expect(page).to have_button 'Hide Custom Properties'

      # Check CP Columns
      check_table_headers('children', cl_sponsor_cps_columns)
      check_cell_content('children', 1, 7, 'Biological Maternal Half Sister') # CRF Display Value
    end

  end


  describe "Edit Custom Properties, Curator user", type: :feature, js:true do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
      load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
      load_data_file_into_triple_store("sponsor_one/ct/CT_V3-0.ttl")
      load_data_file_into_triple_store("sponsor_one/ct/CT_V3-1.ttl")
      load_cdisc_term_versions(1..65)
      ua_create
      Token.destroy_all
      nv_destroy
      nv_create(parent: '10', child: '999')

      set_transactional_tests false
    end

    before :each do
      ua_curator_login
    end

    ### Code List

    it "allows to display Custom Properties, CL Editor" do
      new_codelist_and_edit
      click_on 'New item'
      wait_for_ajax 10

      show_custom_props
      # Check CP Columns
      check_table_headers('editor', cl_sponsor_cps_columns)
      hide_custom_props
      check_table_headers('editor', cl_standard_columns)
    end

    it "allows to edit Custom Properties, CL Editor" do
      new_codelist_and_edit
      click_on 'New item'
      wait_for_ajax 10 

      show_custom_props

      # Check default values are set 
      check_cell_content('editor', 1, 7, '') 
      check_cell_content('editor', 1, 8, false)
      check_cell_content('editor', 1, 9, false)
      check_cell_content('editor', 1, 10, false)
      check_cell_content('editor', 1, 11, false)

      # Inline editing of CPs, text
      ui_editor_select_by_location(1, 7)
      ui_editor_fill_inline("crf_display_value", "Some CRF value\n")
      check_cell_content('editor', 1, 7, 'Some CRF value')
      ui_press_key :return 
      ui_editor_fill_inline("crf_display_value", "Changed CRF\t")
      check_cell_content('editor', 1, 7, 'Changed CRF')

      # Inline editing of CPs, text, input validation
      ui_editor_select_by_content('Changed CRF')
      ui_editor_fill_inline("crf_display_value", "æø\n")
      ui_editor_check_error('crf_display_value', 'contains invalid characters')
      ui_press_key :escape

      # Inline editing of CPs, booleans
      ui_editor_select_by_location(1, 8)
      ui_press_key :arrow_right
      ui_press_key :return
      wait_for_ajax 10
      check_cell_content('editor', 1, 8, true)

      ui_press_key :tab
      ui_press_key :return
      ui_press_key :arrow_left
      ui_press_key :return
      wait_for_ajax 10
      check_cell_content('editor', 1, 9, true)
    end


    it "allows to add and edit Referenced Items with Custom Properties, CL Editor" do
      new_codelist_and_edit

      click_on 'Add items'
      ip_pick_unmanaged_items(:unmanaged_concept, [
        { parent: 'C100130', owner: 'Sanofi', version: '2.0.0', identifier: 'C96587' }
      ], 'add-children')
      wait_for_ajax 20 

      show_custom_props
      check_cell_content('editor', 1, 7, 'Biological Uncle') 
      check_cell_content('editor', 1, 8, false)
      check_cell_content('editor', 1, 9, true)
      check_cell_content('editor', 1, 10, false) # ed_use is a missing value in source CL - check it set to default (false)
      check_cell_content('editor', 1, 11, true)

      # Edit Referenced CPs 
      ui_editor_select_by_location(1, 7)
      ui_editor_fill_inline("crf_display_value", "Some CRF value\n")
      check_cell_content('editor', 1, 7, 'Some CRF value')

      # Todo: Check referenced items normal fields cannot be edited 
    end

    it "Editing a Standard Sanofi extension sets up CPs incorrectly - extra property on 5 items, CL Extension Editor" do
      click_navbar_code_lists
      wait_for_ajax 20

      ui_table_search('index', 'C100130')
      find(:xpath, "//tr[contains(.,'Sanofi')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2('history', '3.0.0', :edit)
      wait_for_ajax 20

      # If error still there, this step will cause Datatables error, will pass otherwise  
      show_custom_props
      ui_check_table_info 'editor', 1, 10, 69 
    end

    it "Extending a CDISC Code List, CP default values bug, should be a model/controller test not feature" do 
      # Extend CDISC CL
      click_navbar_code_lists
      wait_for_ajax 20

      ui_table_search('index', 'C99079')
      find(:xpath, "//tr[contains(.,'CDISC')]/td/a").click
      wait_for_ajax 10

      context_menu_element_v2('history', '62', :show)
      wait_for_ajax 10
      context_menu_element_header(:extend)

      ui_in_modal do 
        click_on 'Do not select'
      end 
      wait_for_ajax 10

      # Check default values picked up from other sponsor Code Lists
      show_custom_props
      check_cell_content('editor', 2, 7, 'Run-In') 
      check_cell_content('editor', 2, 8, false)
      check_cell_content('editor', 2, 9, true)
      check_cell_content('editor', 2, 10, false) 
      check_cell_content('editor', 2, 11, true)

      # Delete Extension 
      click_link 'Sanofi, C99079E'
      wait_for_ajax 10 
      context_menu_element_v2('history', '0.1.0', :delete)
      ui_confirmation_dialog true 
      wait_for_ajax 10 

      # Re-extend CDISC CL 
      click_navbar_code_lists
      wait_for_ajax 20

      ui_table_search('index', 'C99079')
      find(:xpath, "//tr[contains(.,'CDISC')]/td/a").click
      wait_for_ajax 10

      context_menu_element_v2('history', '62', :show)
      wait_for_ajax 10
      context_menu_element_header(:extend)

      ui_in_modal do 
        click_on 'Do not select'
      end 
      wait_for_ajax 10

      # Check default values picked up from other sponsor Code Lists
      show_custom_props
      check_cell_content('editor', 2, 7, 'Run-In') 
      check_cell_content('editor', 2, 8, false)
      check_cell_content('editor', 2, 9, true)
      check_cell_content('editor', 2, 10, false) 
      check_cell_content('editor', 2, 11, true)
    end 

    it "Attempting to extend SN003055 freezes server" do
      click_navbar_code_lists
      wait_for_ajax 20
      ui_table_search('index', 'SN003055')
      find(:xpath, "//tr[contains(.,'Sanofi')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2('history', '2019-08-08', :show)
      wait_for_ajax 10
      context_menu_element_header(:extend)
      ui_in_modal do 
        click_on 'Do not select'
      end 
      wait_for_ajax 10 # Will time out as server freezes
      expect(page).to have_content "Extension Editor"
    end

    ### Code List Extension

    # it "allows to edit Custom Properties, CL Extension editor" do
    #   click_navbar_code_lists
    #   wait_for_ajax 20

    #   ui_table_search('index', 'C99079')
    #   find(:xpath, "//tr[contains(.,'Sanofi')]/td/a").click
    #   wait_for_ajax 10
    #   context_menu_element_v2('history', '1.0.0', :edit)
    #   wait_for_ajax 20
    #   #

    #   # click_on 'New item'
    # end

    # ### Code List Subset

    # it "allows to edit Custom Properties, CL Subset editor" do
    #   click_navbar_code_lists
    #   wait_for_ajax 20

    #   ui_table_search('index', 'SN003093')
    #   find(:xpath, "//tr[contains(.,'SN003093')]/td/a").click
    #   wait_for_ajax 10
    #   context_menu_element_v2('history', '1.0.0', :edit)
    #   wait_for_ajax 20
    #   #pause

    # end

  end

  describe "Limits access to Custom Properties", type: :feature, js:true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..45)
      ua_create
    end

    it "does not show the CP button without CP data, Curator User" do
      ua_curator_login

      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search('index', 'C100130')
      find(:xpath, "//tr[contains(.,'C100130')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2('history', 1, :show)
      wait_for_ajax 20

      expect(page).not_to have_button 'Show Custom Properties'
      expect(page).not_to have_selector '.custom-props-btn'
    end

    it "prevents any access to CPs, Community User" do
      ua_community_reader_login

      # No data in system
      click_show_latest_version
      wait_for_ajax 10
      expect(page).not_to have_button 'Show Custom Properties'
      expect(page).not_to have_selector '.custom-props-btn'

      # Data loaded in system
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
      ui_refresh_page
      wait_for_ajax 10

      expect(page).not_to have_button 'Show Custom Properties'
      expect(page).not_to have_selector '.custom-props-btn'
    end

  end

  # Helpers

  def check_table_headers(table, headers)
    theaders = all(:xpath, "//div[@id='#{ table }_wrapper']//thead/tr/td", visible: false)

    theaders.each do |th|
      expect(headers).to include(th.text)
    end
  end

  def check_cell_content(table, row, col, data)
    cell = find(:xpath, "//table[@id='#{ table }']//tbody/tr[#{ row }]/td[#{ col }]", visible: false)

    if data.is_a? String
      expect(cell).to have_content data
    else
      expect(cell).to have_selector(data ? ".icon-sel-filled" : ".icon-times-circle")
    end
  end

  def new_codelist_and_edit
    click_navbar_code_lists
    identifier = ui_new_code_list
    context_menu_element_v2('history', identifier, :edit)
    wait_for_ajax 10
    identifier 
  end
  
  def cl_standard_columns
    ['Identifier', 'Submission Value', 'Preferred Term', 'Synonyms', 'Definition', 'Tags']
  end 

  def cl_sponsor_cps_columns
    cl_standard_columns + ['CRF Display Value', 'ED Use', 'ADaM Stage', 'SDTM Stage', 'DC Stage']
  end

  def show_custom_props 
    click_on 'Show Custom Properties'
    wait_for_ajax 10 
  end

  def hide_custom_props
    click_on 'Hide Custom Properties'
  end

end
