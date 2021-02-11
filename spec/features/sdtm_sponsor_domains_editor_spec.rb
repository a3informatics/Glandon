require 'rails_helper'

describe "SDTM Sponsor Domains Editor", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include EditorHelpers
  include TokenHelpers
  include ItemsPickerHelpers
  include IsoManagedHelpers

  describe "Edit SDTM Sponsor Domain, Draft State", :type => :feature, js:true do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..8)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_cdisc_term_versions(1..8)
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
      ui_check_table_cell 'editor', 2, 3, 'AEXXX042'

      click_on 'New Variable'
      wait_for_ajax 10 
      ui_check_table_cell 'editor', 3, 1, '43'
      ui_check_table_cell 'editor', 3, 3, 'AEXXX043'
      ui_check_table_info 'editor', 41, 43, 43 # Went to last page 

      # Remove
      remove_variable 'AEXXX042'
      ui_check_table_info 'editor', 1, 10, 42
      ui_table_search 'editor', 'AEXXX042'
      expect(page).to have_content 'No matching records found'

      remove_variable 'AEXXX043'
      ui_check_table_info 'editor', 1, 10, 41
      ui_table_search 'editor', 'AEXXX043'
      expect(page).to have_content 'No matching records found'
    end

    it "prevents editing and removing standard variables, except for some properties" do
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

      # Check Terminology selection disabled 
      ui_editor_select_by_location 1, 8
      ui_editor_check_disabled 'ct_reference'
      ui_editor_check_value 1, 8, 'Not Editable'

      # Check 'used' editing allowed 
      ui_check_table_cell_icon 'editor', 1, 2, 'sel-filled'
      ui_editor_select_by_location 1, 2
      ui_editor_change_bool
      ui_check_table_cell_icon 'editor', 1, 2, 'times-circle'

      # Check 'comment' editing allowed 
      ui_editor_select_by_location 1, 12
      ui_editor_fill_inline 'comment', "Some comment on Standard variable\t"
      ui_editor_check_value 1, 12, "Some comment on Standard variable"

      # Check 'method' editing allowed 
      ui_press_key :arrow_right
      ui_press_key :enter 
      ui_editor_fill_inline 'method', "Some method on Standard variable\n"
      ui_editor_check_value 1, 14, "Some method on Standard variable"

      # Check show Item Reference link
      ui_table_search('editor', 'AEOUT')
      w = window_opened_by { find(:xpath, '//a[contains(.,"OUT C66768")]').click }
      within_window w do
        wait_for_ajax 10
        expect(page).to have_content 'Synonym(s): Outcome of Event'
      end
      w.close
    end

    it "allows to inline edit sponsor variables, field validation" do
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'
      
      # Add new 
      click_on 'New Variable'
      wait_for_ajax 10  
      # Goes to last table page 

      # Boolean
      ui_editor_select_by_location 2, 2
      ui_editor_change_bool
      ui_check_table_cell_icon 'editor', 2, 2, 'times-circle'

      # Label (text)
      ui_editor_select_by_location 2, 4
      ui_editor_fill_inline 'label', "New Variable Label\n"
      ui_editor_check_value 2, 4, "New Variable Label"

      # Select
      ui_editor_check_value 2, 5, 'Character'
      ui_editor_select_by_location 2, 5
      ui_editor_select_option 'typed_as', 'Numeric'
      ui_editor_check_value 2, 5, 'Numeric'

      ui_editor_check_value 2, 9, 'None'
      ui_editor_select_by_location 2, 9
      ui_editor_select_option 'classified_as', 'Synonym'
      ui_editor_check_value 2, 9, 'Synonym'

      # Format (text & validation) 
      ui_editor_select_by_location 2, 6
      ui_editor_fill_inline 'format', "Special Chars æå\n"
      ui_editor_check_error 'format', 'contains invalid characters'
      ui_editor_fill_inline 'format', "XY\n"
      sleep 2 # needs to chill for some reason fails otherwise no idea why
      ui_editor_check_value 2, 6, "XY"

      # Notes (text)
      ui_editor_select_by_location 2, 11
      ui_editor_fill_inline 'notes', "Some additional notes to the sponsor variable\n"
      ui_editor_check_value 2, 11, "Some additional notes to the sponsor variable"
    end

    it "allows to add, edit and remove Terminology reference" do
      edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'
      
      # Add new 
      click_on 'New Variable'
      wait_for_ajax 10  
      # Goes to last table page 

      # Add CT Reference
      ui_editor_select_by_location 3, 8
      ip_pick_managed_items(:managed_concept, [{ identifier: 'C25464', version: '1' }], 'sdtm-term-ref' )
      
      ui_editor_check_value 3, 8, "COUNTRY C25464 v1.0.0"
      
      # Check show Item Reference link 
      w = window_opened_by { find(:xpath, '//a[contains(.,"COUNTRY C25464")]').click }
      within_window w do
        wait_for_ajax 10
        expect(page).to have_content 'Preferred term: Country'
      end
      w.close

      # Has to force screen resize in order to continue, god knows why
      find('#sidebar-arrow').click 
      sleep 1 

      # Change CT Reference
      ui_editor_select_by_location 3, 8, offset_y: 30
      ip_pick_managed_items(:managed_concept, [{ identifier: 'C71620', version: '1' }], 'sdtm-term-ref' )

      ui_editor_check_value 3, 8, "UNIT C71620 v1.0.0"

      # Remove CT Reference
      ui_editor_select_by_location 3, 8, offset_y: 30

      ui_in_modal do 
        ip_clear_selection('sdtm-term-ref')
        ip_submit('sdtm-term-ref')
      end 
      ui_editor_check_value 3, 8, ""
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

      token_ui_check(@user_c) do
        edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'
      end 

    end

    it "token timer, expires edit lock, prevents changes" do

      go_to_edit = proc { edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0' }
      do_an_edit = proc do 
        click_on 'New Variable'
        wait_for_ajax 10 
      end 

      token_expired_check(go_to_edit, do_an_edit)
 
    end

    it "releases edit lock on page leave" do

      token_clear_check do 
        edit_sdtm_sd 'SDTM Sponsor Domain', '0.1.0'
      end

    end

  end


  describe "Edit SDTM Sponsor Domain, Standard", :type => :feature, js:true do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..8)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_cdisc_term_versions(1..15)
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

    it "allows to add, edit and remove variables in SDTM Editor" do
      prep_std_sdtm
      edit_sdtm_sd 'SDTM STD', '0.1.0'

      ui_check_table_info 'editor', 1, 10, 42

      # Boolean on Standard Var
      ui_editor_select_by_location 1, 2
      ui_editor_change_bool
      ui_check_table_cell_icon 'editor', 1, 2, 'times-circle'

      ui_table_search 'editor', 'AAXXX042'

      # Text on Sponsor Var
      ui_editor_select_by_location 1, 3
      ui_editor_fill_inline 'name', "AAXXX111\n"
      ui_editor_check_value 1, 3, "AAXXX111"

      # Select on Sponsor Var 
      ui_editor_select_by_location 1, 9
      ui_editor_select_option 'classified_as', 'Variable Qualifier'
      ui_editor_check_value 1, 9, 'Variable'

      ui_table_search 'editor', ''

      # Add Sponsor Var
      click_on 'New Variable'
      wait_for_ajax 10  

      ui_check_table_info 'editor', 41, 43, 43

      # Add CT Reference
      ui_editor_select_by_location 2, 8
      ip_pick_managed_items(:managed_concept, [{ identifier: 'C25464', version: '1' }], 'sdtm-term-ref' )
      ui_editor_check_value 2, 8, "COUNTRY C25464 v1.0.0"

      # Remove Sponsor Vars
      remove_variable 'AAXXX043'
      ui_check_table_info 'editor', 1, 10, 42
      remove_variable 'AAXXX111'
      ui_check_table_info 'editor', 1, 10, 41

      # Check 
      click_on 'Return'
      wait_for_ajax 10
      ui_check_table_info 'history', 1, 2, 2
      context_menu_element_v2 'history', 1, :show 
      wait_for_ajax 10
      ui_check_table_info 'show', 1, 10, 41
    end

    def prep_std_sdtm 
      # Create
      ui_create_sdtm_sd('AA', 'SDTM STD', 'Standard SDTM Test', based_on = { type: :sdtm_ig_domain, identifier: 'SDTM IG AE', version: '2008-11-12' })
      context_menu_element_v2('history', '0.1.0', :edit)
      wait_for_ajax 10 

      # Add new var
      click_on 'New Variable'
      wait_for_ajax 10  

      click_on 'Return'
      wait_for_ajax 10 

      # Make Std
      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax 10
      dc_forward_to('Standard')
      click_on 'Return'
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
    find(:xpath, "//tr[contains(.,'#{ identifier }')]/td[15]/span").click
    ui_confirmation_dialog true
    wait_for_ajax 10
    ui_table_search 'editor', ''
  end

end
