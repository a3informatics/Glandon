require 'rails_helper'

describe "Scenario 10 - aCRF", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include UserAccountHelpers
  include AuditTrailHelpers
  include ScenarioHelpers
  include EditorHelpers
  include ItemsPickerHelpers
  include D3GraphHelpers
  include TokenHelpers

  def sub_dir
    return "features/scenarios"
  end

  describe "Curator User", :type => :feature do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      Token.destroy_all
      AuditTrail.destroy_all
      clear_downloads
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V4.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V4.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V5.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V6.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V7.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")  
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")      
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

    def add_bc_associations(bcs)
      click_on 'Add items'
      ip_pick_managed_items(:bci, bcs, 'add-items')
    end 

    def create_sponsor_domain_and_associations
      ui_create_sdtm_sd('AA', 'SDTM STD', 'Standard SDTM Test', based_on = { type: :sdtm_ig_domain, identifier: 'SDTM IG VS', version: '2013-11-26' })
      context_menu_element_v2('history', '0.1.0', :bca)
      wait_for_ajax 10
      add_bc_associations( [
        { identifier: 'BC Test', version: '1' },
      ])
      wait_for_ajax 10
    end

    def create_bc
      click_navbar_bc
      wait_for_ajax 20
      find('#new-bc-button').click
      ui_in_modal do
        fill_in 'identifier', with: 'BC Test'
        fill_in 'label', with: 'BC Label'
        find('#new-item-template').click
        ip_pick_managed_items(:bct, [ { identifier: 'BASIC OBS PQR', version: '1' } ], 'new-bc')

        click_on 'Submit'
      end
      wait_for_ajax 10
      expect(page).to have_content 'BC Test'
    end

    def go_to_edit_bc(identifier)
      click_navbar_bc
      wait_for_ajax 20
      ui_table_search('index', identifier)
      find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2 'history', identifier, :edit
      wait_for_ajax 10
      expect(page).to have_content 'Biomedical Concept Editor'
    end

    def create_form
      click_navbar_forms
      wait_for_ajax 20
      expect(page).to have_content 'Index: Forms'
      click_on 'New Form'

      ui_in_modal do
        fill_in 'identifier', with: 'FORM Test'
        fill_in 'label', with: 'Form Label'
        click_on 'Submit'
      end

      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'FORM Test\''
    end

    def edit_form(identifier)
      click_navbar_forms
      wait_for_ajax 20
      find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2 'history', 1, :edit
      wait_for_ajax 30
      expect(page).to have_content 'Form Editor'
      find('#main_area').scroll_to(:bottom)
    end

    it "allows to show aCRF", scenario: true, js: true do
      create_bc

      go_to_edit_bc("BC Test")

      ui_editor_select_by_location 7, 8, true

      # Add Terminology References
      ui_in_modal do
        ip_check_tabs [:unmanaged_concept], 'bc-term-ref'
        ip_pick_unmanaged_items :unmanaged_concept, [
          { parent: 'C100130', version: '2019-12-20', identifier: 'C96587' },
          { parent: 'C100130', version: '2019-12-20', identifier: 'C96586' }
        ], 'bc-term-ref', false
        ip_check_selected_info '2', 'bc-term-ref'
        ip_submit 'bc-term-ref'
      end

      create_form

      edit_form("FORM Test")

      nodes = node_count

      find_node('Form Label').click
      click_action :add_child

      # Add Normal Group
      expect( all('#d3 .node-actions a.option').count ).to eq 1
      find(:xpath, '//div[@id="d3"]//a[@id="normal_group"]').click

      wait_for_ajax 10

      check_alert 'Added successfully.'
      expect( node_count ).to eq( nodes + 1 )

      # Add BCs to a Normal Group
      find_node('Not set').click
      find_node('Not set').click

      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="bc_group"]').click

      ip_pick_managed_items( :bci, [
        { identifier: 'BC Test', version: '1' }
      ], 'node-add-child' )

      check_alert 'Added successfully.'
      
      create_sponsor_domain_and_associations

      click_navbar_forms
      wait_for_ajax 20
      find(:xpath, "//tr[contains(.,'FORM Test')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2 'history', 1, :acrf
      wait_for_ajax 30
      expect(page).to have_content 'aCRF View'
pause

    end

    

  end

end
