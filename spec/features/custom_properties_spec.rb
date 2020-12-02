require 'rails_helper'

describe "Custom Properties", type: :feature  do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include EditorHelpers
  include NameValueHelpers

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
      nv_destroy
      nv_create(parent: '10', child: '999')
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
      check_table_headers('children', ['Identifier', 'Submission Value', 'Preferred Term', 'Synonyms', 'Definition', 'Tags'])

      # Show CPs
      click_on 'Show Custom Properties'
      wait_for_ajax 20

      # Check CP Columns
      check_table_headers('children', [
        'Identifier', 'Submission Value', 'Preferred Term',
        'Synonyms', 'Definition', 'Tags',
        'CRF Display Value', 'ED Use', 'ADaM Stage', 'SDTM Stage', 'DC Stage'
      ])
      expect(page).to have_button 'Hide Custom Properties'

      ui_table_search('children', 'C96658')

      # Check CP data
      check_cell_content('children', 1, 1, 'C96658')
      check_cell_content('children', 1, 2, 'SISTER, BIOLOGICAL MATERNAL HALF')
      check_cell_content('children', 1, 6, 'SDTM')
      check_cell_content('children', 1, 7, 'Biological Maternal Half Sister') # CRF Display Value
      check_cell_content('children', 1, 8, false)  # Adam stage
      check_cell_content('children', 1, 9, true) # DC stage
      check_cell_content('children', 1, 10, false)  # ED use
      check_cell_content('children', 1, 11, true) # SDTM stage

      # Hide CPs
      click_on 'Hide Custom Properties'
      check_table_headers('children', ['Identifier', 'Submission Value', 'Preferred Term', 'Synonyms', 'Definition', 'Tags'])
      click_on 'Show Custom Properties'

      # Show CPs again without server load
      expect(page).to have_button 'Hide Custom Properties'

      # Check CP Columns
      check_table_headers('children', [
        'Identifier', 'Submission Value', 'Preferred Term',
        'Synonyms', 'Definition', 'Tags',
        'CRF Display Value', 'ED Use', 'ADaM Stage', 'SDTM Stage', 'DC Stage'
      ])
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
      load_cdisc_term_versions(1..45)
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

    # Code List
    it "allows to edit Custom Properties in Code List editor" do
      click_navbar_code_lists
      identifier = ui_new_code_list
      context_menu_element_v2('history', identifier, :edit)
      wait_for_ajax 10

      click_on 'New item'
      wait_for_ajax 10 
      click_on 'Show Custom Properties'
      wait_for_ajax 10 
      ui_editor_select_by_location 1, 7
      ui_editor_fill_inline "crf_display_value", "Some CRF value\n"

      ui_editor_check_value 1, 7, 'Some CRF value'

      # Test input validation 
    end

    # Code List Extension
    it "allows to edit Custom Properties in Code List Extension editor" do
      click_navbar_code_lists
      wait_for_ajax 20

      ui_table_search('index', 'C99079')
      find(:xpath, "//tr[contains(.,'Sanofi')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2('history', '1.0.0', :edit)
      wait_for_ajax 20
      #

      # click_on 'New item'
    end

    # Code List Subset
    it "allows to edit Custom Properties in Code List Subset editor" do
      click_navbar_code_lists
      wait_for_ajax 20

      ui_table_search('index', 'SN003093')
      find(:xpath, "//tr[contains(.,'SN003093')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2('history', '1.0.0', :edit)
      wait_for_ajax 20
      #pause

    end

  end

  describe "Limits access to Custom Properties", type: :feature, js:true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..45)
      ua_create
    end

    after :all do
      ua_destroy
    end

    after :each do
      ua_logoff
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
      puts th.text
      expect(headers).to include(th.text)
    end
  end

  def check_cell_content(table, row, col, data, icon = false)
    cell = find(:xpath, "//table[@id='#{ table }']//tbody/tr[#{ row }]/td[ #{ col }]", visible: false)

    if data.is_a? String
      expect(cell).to have_content data
    else
      expect(cell).to have_selector(data ? ".icon-sel-filled" : ".icon-times-circle")
    end
  end

end
