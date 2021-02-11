require 'rails_helper'
require 'thesauri/managed_concepts_controller'

describe "Upgrade Code Lists", type: :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include NameValueHelpers
  include ThesaurusManagedConceptFactory

  describe "Code Lists Upgrade from CDISC CT update", type: :feature, js: true do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..58)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("thesaurus_sponsor1_upgrade.ttl")
      nv_destroy 
      nv_create({parent: '10', child: '999'})
      ua_create
      set_transactional_tests false
    end
  
    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
      set_transactional_tests true
    end

    it "allows to upgrade code lists based on CDISC changes" do
      find(:xpath, "//tr[contains(.,'SPONSORUPGRADE')]/td/a").click
      wait_for_ajax 10
      context_menu_element('history', 4, 'SPONSORUPGRADE', :edit)
      wait_for_ajax 20
      context_menu_element_header(:upgrade_cls)
      expect(page).to have_content 'Upgrade Code Lists SPONSORUPGRADE v0.1.0'
      expect(page).to have_content 'Baseline CDISC CT: 2017-09-29 Release. New version: 2018-12-21 Release.'
      wait_for_ajax 20
      click_row_contains("changes-cdisc-table", "Epoch")
      wait_for_ajax 30
      expect(page).to have_content 'Upgrade affected items'
      expect(page).to have_content 'EPOCH (NP000123P)'
      expect(page).to have_content 'EPOCH (C99079)'
      ui_click_tab "Change Details"
      expect(page).to have_content "CDISC SDTM Epoch Terminology"
      ui_check_table_info("changes", 1, 2, 2)
      find(:xpath, "//*[@id='changes']/tbody/tr[contains(.,'Long-term')]/td/a").click
      wait_for_ajax 10
      expect(page).to have_content("Differences")
      ui_check_table_info("differences_table", 1, 4, 4)
      page.go_back
      wait_for_ajax 20
      click_row_contains("changes-cdisc-table", "Epoch")
      wait_for_ajax 30
      find(:xpath, "//tr[contains(.,'Extension')]/td/button").click
      wait_for_ajax 10
      expect(page).to have_content "Item was successfully upgraded"
      expect(find(:xpath, "//tr[contains(.,'Extension')]/td/button").text).to eq("Cannot upgrade")
      find(:xpath, "//tr[contains(.,'Subset')]/td/button").click
      wait_for_ajax 10
      expect(page).to_not have_content "Error"
      expect(find(:xpath, "//tr[contains(.,'Subset')]/td/button").text).to eq("Cannot upgrade")
    end

  end

  # Interdependent tests - only run as a collection 
  describe "Sponsor Code Lists Upgrade", type: :feature, js: true do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..5)
      load_data_file_into_triple_store("mdr_identification.ttl")
      nv_destroy 
      nv_create({parent: '10', child: '999'})
      Token.delete_all
      ua_create
      prep_data
      set_transactional_tests false
    end
  
    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      Token.delete_all
      ua_destroy
      set_transactional_tests true
    end

    def prep_data 
      @source_cl = create_managed_concept('Source CL')
      @subset = @source_cl.create_subset
      @extension = @source_cl.create_extension
      @extension.label = "Extension CL"
      @extension.save
      @subset2 = @extension.create_subset
      IsoManagedV2.fast_forward_state([@source_cl.uri])
    end 
        
    it "allows to upgrade a subset" do
      go_to_cl "Source CL", '0.1.0' # Create new source version 
    
      # Upgrade Subset
      go_to_cl @subset.has_identifier.identifier, '0.1.0'
      expect(context_menu_element_header_present?(:upgrade)).to eq(true)

      context_menu_element_header :upgrade 
      ui_confirmation_dialog true 
      wait_for_ajax 10 

      # Check first version not subsetted anymore
      go_to_cl "Source CL", '0.1.0', action: :show 
      context_menu_element_header :subsets 
      ui_in_modal do
        ui_check_table_info('subsets-index-table', 0, 0, 0)
        click_on 'Close'
      end

      # Check new version now subsetted
      go_to_cl "Source CL", '0.2.0', action: :show 
      context_menu_element_header :subsets 
      ui_in_modal do
        ui_check_table_info('subsets-index-table', 1, 1, 1)
        ui_check_table_cell('subsets-index-table', 1, 1, @subset.has_identifier.identifier)
        click_on 'Close'
      end
    end

    it "allows to upgrade an extension" do
      # Upgrade Extension
      go_to_cl @extension.has_identifier.identifier, '0.1.0'
      expect(context_menu_element_header_present?(:upgrade)).to eq(true)

      context_menu_element_header :upgrade 
      ui_confirmation_dialog true 
      wait_for_ajax 10 

      # Check first version not subsetted anymore
      go_to_cl "Source CL", '0.1.0', action: :show 
      expect(context_menu_element_header_present?(:extension)).to eq(false)

      # Check new version now subsetted
      go_to_cl "Source CL", '0.2.0', action: :show 
      expect(context_menu_element_header_present?(:extension)).to eq(true)

      context_menu_element_header(:extension)
      wait_for_ajax 10
      expect(page).to have_content @extension.has_identifier.identifier 
    end

    it "allows to upgrade a subset of an extension" do
      # Move extension into Std and edit to create a new ver 
      IsoManagedV2.fast_forward_state([@extension.uri])
      go_to_cl @extension.has_identifier.identifier, '0.1.0'

      # Upgrade Subset of Extension 
      go_to_cl @subset2.has_identifier.identifier, '0.1.0'
      expect(context_menu_element_header_present?(:upgrade)).to eq(true)

      context_menu_element_header :upgrade 
      ui_confirmation_dialog true 
      wait_for_ajax 10 

      # Check first version not subsetted anymore
      go_to_cl @extension.has_identifier.identifier, '0.1.0', action: :show 
      context_menu_element_header :subsets 
      ui_in_modal do
        ui_check_table_info('subsets-index-table', 0, 0, 0)
        click_on 'Close'
      end

      # Check new version now subsetted
      go_to_cl @extension.has_identifier.identifier, '0.2.0', action: :show 
      context_menu_element_header :subsets 
      ui_in_modal do
        ui_check_table_info('subsets-index-table', 1, 1, 1)
        ui_check_table_cell('subsets-index-table', 1, 1, @subset.has_identifier.identifier)
        click_on 'Close'
      end
    end

    it "does not show upgrade button if source is not owned" do
      # Data 
      cdisc_codelist = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: 'http://www.cdisc.org/C66790/V2#C66790').to_id)
      cdisc_subset = cdisc_codelist.create_subset 

      go_to_cl cdisc_subset.has_identifier.identifier, '0.1.0'
      expect(context_menu_element_header_present?(:upgrade)).to eq(false)
    end

  end

  # Helpers
  def click_row_contains(table, text)
    find(:xpath, "//*[@id='#{table}']/tbody/tr[contains(.,'#{text}')]").click
  end

  def go_to_cl(identifier, version, action: :edit)
    click_navbar_code_lists
    wait_for_ajax 10 
    ui_table_search('index', identifier)
    find(:xpath, "//tr[contains(.,'#{ identifier }')]/td/a").click
    wait_for_ajax 10
    context_menu_element_v2("history", version, action)
    wait_for_ajax 10
  end

end
