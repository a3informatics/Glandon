require 'rails_helper'

describe "SDTM Sponsor Domains Editor", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include EditorHelpers

  describe "Edit SDTM Sponsor Domain, Incomplete", :type => :feature, js:true do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      Token.restore_timeout
      Token.delete_all
      ua_create
    end

    after :all do
      ua_destroy
      Token.restore_timeout
      Token.delete_all
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows access to edit page, initial state" do
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'

      ui_check_table_info 'editor', 1, 10, 41

      ui_check_table_cell 'editor', 1, 1, '1'
      ui_check_table_cell_icon 'editor', 1, 2, 'sel-filled'
      ui_check_table_cell 'editor', 1, 3, 'STUDYID'
    end

    it "allows to refresh data in table" do
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'

      ui_check_table_info 'editor', 1, 10, 41
      click_on 'Refresh'
      wait_for_ajax 10 
      ui_check_table_info 'editor', 1, 10, 41
    end

    it "allows to add and remove sponsor variables" do
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'
      
      ui_check_table_info 'editor', 1, 10, 41

      # Add new 
      click_on 'New Variable'
      wait_for_ajax 10 
      ui_check_table_cell 'editor', 2, 1, '42'
      ui_check_table_cell 'editor', 2, 3, 'AEXXX42'

      click_on 'New Variable'
      wait_for_ajax 10 
      ui_check_table_cell 'editor', 3, 1, '43'
      ui_check_table_cell 'editor', 3, 3, 'AEXXX43'
      ui_check_table_info 'editor', 41, 43, 43 # Went to last page 

      # Remove
      remove_variable 'AEXXX42'
      ui_check_table_info 'editor', 1, 10, 42
      ui_table_search 'editor', 'AEXXX42'
      expect(page).to have_content 'No matching records found'

      remove_variable 'AEXXX43'
      ui_check_table_info 'editor', 1, 10, 41
      ui_table_search 'editor', 'AEXXX43'
      expect(page).to have_content 'No matching records found'
    end

    it "prevents editing and removing standard variables, except for 'Used' property" do
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'
      
      # Check remove button disabled 
      standard_var_row = find(:xpath, "//tr[contains(.,'STUDYID')]")
      expect( standard_var_row ).to have_css 'span.remove.disabled'

      # Check inline editing disabled 
      ui_editor_select_by_content 'DOMAIN'
      ui_editor_check_disabled 'name'
      ui_editor_select_by_location 4, 3
      ui_editor_check_disabled 'name'
      ui_editor_select_by_location 3, 5
      ui_editor_check_disabled 'typed_as'

      # Check 'used' editing allowed 
      ui_check_table_cell_icon 'editor', 1, 2, 'sel-filled'
      ui_editor_select_by_location 1, 2
      ui_press_key :arrow_right 
      ui_press_key :return 
      wait_for_ajax 10 
      ui_check_table_cell_icon 'editor', 1, 2, 'times-circle'
    end

    it "allows to inline edit sponsor variables, field validation" do
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'
      
      # Add new 
      click_on 'New Variable'
      wait_for_ajax 10  
      # Goes to last table page 

      # Boolean
      ui_editor_select_by_location 2, 2
      ui_press_key :arrow_right 
      ui_press_key :return 
      wait_for_ajax 10 
      ui_check_table_cell_icon 'editor', 2, 2, 'times-circle'

      # Text
      ui_editor_select_by_location 2, 4
      ui_editor_fill_inline 'label', "New Variable Label\n"
      ui_editor_check_value 2, 4, "New Variable Label"

      # Select
      ui_editor_check_value 2, 5, 'Character'
      ui_editor_select_by_location 2, 5
      select 'Numeric', from: 'DTE_Field_typed_as'
      ui_press_key :return 
      wait_for_ajax 10 
      ui_editor_check_value 2, 5, 'Numeric'

      ui_editor_check_value 2, 7, 'None'
      ui_editor_select_by_location 2, 7
      select 'Synonym', from: 'DTE_Field_classified_as'
      ui_press_key :return 
      wait_for_ajax 10 
      ui_editor_check_value 2, 7, 'Synonym'

      # Text validation 
      ui_editor_select_by_location 2, 6
      ui_editor_fill_inline 'format', "Special Chars æå\n"
      wait_for_ajax 10 
      ui_editor_check_error 'format', 'contains invalid characters'
      ui_editor_fill_inline 'format', "XY\n"
      wait_for_ajax 10 
      ui_editor_check_value 2, 6, "XY"
    end

    it "allows to view editor help dialog" do
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'
      
      find('#editor-help').click

      ui_in_modal do
        expect(page).to have_content 'How to use SDTM Sponsor Domain Editor'
        click_on 'Dismiss'
      end
    end

    it "token timers, warnings, extension and expiration" do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'

      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2

      expect( find('#imh_header')[:class] ).to include 'warning'

      find( '#timeout' ).click
      wait_for_ajax 10

      expect( find('#imh_header')[:class] ).not_to include 'warning'

      sleep Token.get_timeout - (@user_c.edit_lock_warning.to_i / 2) + 2

      expect( find('#imh_header')[:class] ).to include 'danger'

      sleep 28

      expect( find('#timeout')[:class] ).to include 'disabled'
      expect( find('#imh_header')[:class] ).not_to include 'danger'

      Token.restore_timeout
    end

    it "token timer, expires edit lock, prevents changes" do
      Token.set_timeout(2)
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'

      sleep 3

      # Prevents changes
      click_on 'New Variable'
      wait_for_ajax 10 
      expect(page).to have_content 'The edit lock has timed out.'
      
      Token.restore_timeout
    end

    it "releases edit lock on page leave" do
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'

      expect(Token.all.count).to eq(1)
      click_link 'Return'
      wait_for_ajax 10
      expect(Token.all.count).to eq(0)
    end

  end

  def edit_sdtm_sd(identifier, version)
    click_navbar_sdtm_sponsor_domains
    wait_for_ajax 10
    find(:xpath, "//tr[contains(.,'#{ identifier }')]/td/a").click
    wait_for_ajax 10
    context_menu_element_v2('history', version, :edit)
    wait_for_ajax 10
    expect(page).to have_content 'SDTM Sponsor Domain Editor'
  end

  def remove_variable(identifier)
    ui_table_search 'editor', identifier
    find(:xpath, "//tr[contains(.,'#{ identifier }')]/td[10]/span").click
    ui_confirmation_dialog true
    wait_for_ajax 10
    ui_table_search 'editor', ''
  end

end
