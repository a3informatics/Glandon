require 'rails_helper'

describe "SDTM Sponsor Domains", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include ItemsPickerHelpers

  after :all do
    ua_destroy
  end

  before :each do
    ua_curator_login
  end

  after :each do
    ua_logoff
  end

  describe "Basic Operations, curator", :type => :feature, js:true do

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
      ua_create
    end

    it "allows access to index page (REQ-MDR-MIT-015)" do
      click_navbar_sdtm_sponsor_domains
      wait_for_ajax 10
      expect(page).to have_content 'Index: SDTM Sponsor Domains'
      ui_check_table_info("index", 1, 1, 1)
      ui_check_table_cell("index", 1, 2, "AAA")
      ui_check_table_cell("index", 1, 3, "SDTM Sponsor Domain")
    end

    it "allows the history page to be viewed" do
      click_navbar_sdtm_sponsor_domains
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM Sponsor Domain')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'AAA\''
      ui_check_table_cell("history", 1, 1, "0.1.0")
      ui_check_table_cell("history", 1, 5, "SDTM Sponsor Domain")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)" do
      click_navbar_sdtm_sponsor_domains
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM Sponsor Domain')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'AAA\''
      context_menu_element_v2('history', "SDTM Sponsor Domain", :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: SDTM Sponsor Domain'
      ui_check_table_info("show", 1, 10, 41)
      ui_check_table_row("show", 1, [ "1", "STUDYID", "Study Identifier", "Character", "", "", "", "Identifier", "Unique identifier for a study.", "Required"])
      ui_table_search("show", "AELOC")
      ui_check_table_cell("show", 1, 2, "AELOC")
      ui_check_table_cell("show", 1, 3, "Location of Event")
      ui_check_table_cell("show", 1, 6, "(LOC)")
      ui_check_table_cell("show", 1, 7, "LOC C74456 v1.0.0")
    end

  end

  describe "Create, delete actions", :type => :feature, js:true do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..13)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      ua_create
    end

    it "allows to create a new SDTM SD from IG Domain" do
      ui_create_sdtm_sd('XY', 'SDTM Test', 'Test Label', based_on = { type: :sdtm_ig_domain, identifier: 'SDTM IG MH', version: '2008-11-12' })
      expect(page).to have_content 'Test Label'

      # Check 'Show' works (was bug)
      context_menu_element_v2('history', 1, :show)
      wait_for_ajax 10 
      ui_check_table_info('show', 1, 10, 24)
    end

    it "allows to create a new SDTM SD from Class" do
      ui_create_sdtm_sd('YX', 'SDTM Test 2', 'Test Label 2', based_on = { type: :sdtm_class, identifier: 'SDTM MODEL SE', version: '2008-11-12' })
      expect(page).to have_content 'Test Label 2'
    end

    it "allows to create a new SDTM SD, clear fields, field validation" do
      click_navbar_sdtm_sponsor_domains
      wait_for_ajax 10
      
      click_on 'New SDTM Sponsor Domain'
      ui_in_modal do
        click_on 'Submit'

        # Empty fields validation
        expect(page).to have_content('Field cannot be empty', count: 4)

        fill_in 'identifier', with: 'SDTM Test'
        fill_in 'label', with: 'Test Label'

        click_on 'Submit'

        expect(page).to have_content('Field cannot be empty', count: 2)

        click_on 'Clear fields'

        expect(find_field('identifier').value).to eq('')
        expect(find_field('label').value).to eq('')

        # Special characters validation
        fill_in 'prefix', with: 'XX'
        fill_in 'identifier', with: 'SDTM Tææst'
        fill_in 'label', with: 'Test Label'
        find('#new-item-base').click
        ip_pick_managed_items(:sdtm_class, [ { identifier: 'SDTM MODEL SE', version: '2008-11-12' } ], 'new-sdtm-sd')

        click_on 'Submit'
        wait_for_ajax 10

        expect(page).to have_content('contains invalid characters', count: 1)

        # Duplicate identifier validation
        fill_in 'identifier', with: 'SDTM Test'

        click_on 'Submit'
        wait_for_ajax 10

        expect(page).to have_content 'already exists in the database'
        click_on 'Close'
      end
      
    end

    it "allows to delete a SDTM" do
      # Create a new SDTM to delete
      ui_create_sdtm_sd('YY', 'DELETE SDTM', 'SDTM Label', based_on = { type: :sdtm_ig_domain, identifier: 'SDTM IG MH', version: '2008-11-12' })
      sdtm_count = SdtmSponsorDomain.all.count

      context_menu_element_v2('history', 1, :delete)
      ui_confirmation_dialog true
      wait_for_ajax 10

      expect(page).to have_content "No versions found"
      expect( SdtmSponsorDomain.all.count ).to eq sdtm_count - 1
    end

  end 

end
