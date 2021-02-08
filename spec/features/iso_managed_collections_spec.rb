require 'rails_helper'

describe "ISO Managed Collections", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include ItemsPickerHelpers
  include TokenHelpers

  after :all do
    ua_destroy
  end

  before :each do
    ua_curator_login
  end

  after :each do
    ua_logoff
  end

  describe "Managed Collection, curator", :type => :feature, js:true do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      ua_create
    end

    # Tests for generic Managed Collections features here
    # it "" 

  end

  describe "Managed Collections - SDTM - BC Associations, curator", :type => :feature, js:true do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      # load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      ua_create
    end

    it "allows to access BC Associations from SDTM SD's History Panel" do
      bc_associations 'SDTM Sponsor Domain', '0.1.0'

      expect(page).to have_content('Biomedical Concept Associations')
      expect(page).to have_selector('#collection-actions .btn', count: 3)
      expect(page).to have_selector('#collection-actions .btn.disabled', count: 2)
    end

    it "allows to add and remove BC Association to and from an SDTM SD" do 
      bc_associations 'SDTM Sponsor Domain', '0.1.0'

      # Add
      add_bc_associations( [
        { identifier: 'HEIGHT', version: '1' },
        { identifier: 'WEIGHT', version: '1' },
        { identifier: 'RACE', version: '1' },
        { identifier: 'AGE', version: '1' },
        { identifier: 'BMI', version: '1' },
      ])
      
      ui_check_table_info('managed-items', 1, 5, 5)
      ui_check_table_row('managed-items', 1, ['', 'S-cubed', '0.1.0', 'AGE', 'Age'])

      # Remove selected 
      remove_bc_associations(['AGE', 'HEIGHT'])
      ui_check_table_info('managed-items', 1, 3, 3)
      
      # Remove all 
      click_on 'Remove all'
      ui_confirmation_dialog true
      wait_for_ajax 10 
      ui_check_table_info('managed-items', 0, 0, 0)
    end

    it "token timers, warnings, extension and expiration" do

      token_ui_check(@user_c) do
        bc_associations 'SDTM Sponsor Domain', '0.1.0'
      end 

    end

    it "token timer, expires edit lock, prevents changes" do

      go_to_edit = proc { bc_associations 'SDTM Sponsor Domain', '0.1.0' }
      do_an_edit = proc { add_bc_associations([{ identifier: 'AGE', version: '1' }]) } 

      token_expired_check(go_to_edit, do_an_edit)
 
    end

    it "releases edit lock on page leave" do

      token_clear_check do 
        bc_associations 'SDTM Sponsor Domain', '0.1.0'
      end

    end

    # Helpers

    def bc_associations(identifier, version)
      click_navbar_sdtm_sponsor_domains
      wait_for_ajax 10 
      find(:xpath, "//tr[contains(.,'#{ identifier }')]/td/a").click 
      wait_for_ajax 10 
      context_menu_element_v2('history', version, :bca)
      wait_for_ajax 10 
    end
  
    def add_bc_associations(bcs)
      click_on 'Add items'
      ip_pick_managed_items(:bci, bcs, 'add-items')
    end 
  
    def remove_bc_associations(bcs)
      bcs.each do |bc|
        find(:xpath, "//tr[contains(.,'#{ bc }')]").click 
      end 
      click_on 'Remove selected'
      ui_confirmation_dialog true 
      wait_for_ajax 10 
    end 

  end 

end