require 'rails_helper'

describe "Custom Properties", type: :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper

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
