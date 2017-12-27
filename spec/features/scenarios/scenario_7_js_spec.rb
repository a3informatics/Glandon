require 'rails_helper'

describe "Scenario 7 - Mixed Form", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include UserAccountHelpers
  include AuditTrailHelpers
  include ScenarioHelpers
  
  def sub_dir
    return "features/scenarios"
  end

  describe "Curator User", :type => :feature do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_schema_file_into_triple_store("BusinessDomain.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V38.ttl")
      load_test_file_into_triple_store("CT_V39.ttl")
      load_test_file_into_triple_store("CT_V40.ttl")
      load_test_file_into_triple_store("CT_V41.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_temp_file_into_triple_store("ACME_QS_TERM_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100392_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100393_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100394_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100395_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100396_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100397_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_QS_Domain_DFT.ttl")
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      Token.destroy_all
      AuditTrail.destroy_all
      clear_downloads
    end

    after :all do
      ua_destroy
    end
    
    before :each do
      set_screen_size(1500, 900)
      ua_curator_login
    end

    def to_standard(item)
      click_navbar_bc
      expect_page 'Index: Biomedical Concepts'
      ui_main_show_all
      click_main_table_link "BC #{item}", 'History'
      expect_page 'History:'
      click_main_table_link "BC #{item}", 'Status'
      expect_page 'Status:'
      click_button 'state_submit'     
      click_button 'state_submit'     
      click_button 'state_submit'     
      click_button 'state_submit'     
      click_link "Close"
      expect_page 'History:'
    end

    def add_question(key, question_label, question_text, mapping, completion_instructions, notes)
      ui_click_node_key(key)
      click_button 'groupAddQuestion'
      fill_in 'questionLabel', with: question_label
      fill_in 'questionText', with: question_text
      check 'questionOptional'  
      fill_in 'questionMapping', with: mapping
      choose 'form_datatype_s'
      fill_in 'questionCompletion', with: completion_instructions
      fill_in 'questionNote', with: notes
      ui_click_node_key(key)
      wait_for_ajax
    end

    def domain_clone(domain_code, label)
      click_navbar_ig_domain
      click_main_table_link "SDTM Implementation Guide 2013-11-26", 'Show'
      expect(page).to have_content 'Show: SDTM Implementation Guide 2013-11-26 SDTM IG (V3.2.0, 3, Standard)'
      secondary_search domain_code
      click_secondary_table_link "SDTM IG #{domain_code}", 'Show'
      expect(page).to have_content 'Show:'
      click_link 'Clone'
      expect(page).to have_content 'Cloning:'
      ui_check_input('sdtm_user_domain_prefix', domain_code)
      fill_in 'sdtm_user_domain_label', with: label
      click_button 'Clone'   
      expect(page).to have_content 'SDTM Sponsor Domain was successfully created.'
    end

    def domain_add_bc(domain_code, identifier, uri)
      click_navbar_sponsor_domain
      click_main_table_link "#{domain_code} Domain", 'History'
      click_main_table_link "0.1.0", 'Show'
      click_link 'BC+'
      expect(page).to have_content 'Add Biomedical Concepts'
      main_search identifier
      find(:css, "#sdtm_user_domain_bcs_[value='#{uri}']").set(true)
      click_button 'Add'
    end

    it "allows Forms to be created", scenario: true, js: true do
      form_create("MIXED", "start", "Mixed Form")
      
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "BC Group"
      fill_in 'groupCompletion', with: "Fill with Groups"
      ui_click_node_name("Mixed Form")

      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Q Group"
      fill_in 'groupCompletion', with: "Fill with Questions"
      
      ui_click_node_name("BC Group")
      click_button 'groupAddCommon'
      fill_in 'commonLabel', with: "Common"

      key1 = ui_get_key_by_path('["Mixed Form", "BC Group"]') 
      
      ui_click_node_key(key1)
      click_button 'groupAddLabelText'
      fill_in 'labelTextLabel', with: "General Instructions"
      fill_in 'labelTextText', with: "You need to fill this in!"

      ui_click_node_key(key1)
      form_bc_search("C25208")
      form_bc_click
      click_button 'groupAddBc'
      wait_for_ajax(10)
    
      ui_click_node_key(key1)
      form_bc_search("C100392")
      form_bc_click
      click_button 'groupAddBc'
      wait_for_ajax(10)

      ui_click_node_key(key1)
      form_bc_search("C49677")
      form_bc_click
      click_button 'groupAddBc'
      wait_for_ajax(10)

      key2 = ui_get_key_by_path('["Mixed Form", "BC Group", "EQ-5D-3L Mobility", "Date Time (--DTC)"]') 
      ui_click_node_key(key2)
      click_button "itemCommon"
    
      key3 = ui_get_key_by_path('["Mixed Form", "Q Group"]') 
      
      add_question(key3, "AE Question", "What is the event?", "AETERM", "Completion for *the* question", "Notes for **the** question")
      add_question(key3, "CM Question", "What is medication?", "CMTERM", "Completion for *the* question", "Notes for **the** question")
      add_question(key3, "MH Question", "What is the history?", "MHTERM", "Completion for *the* question", "Notes for **the** question")

      click_button "save"
      wait_for_ajax

      domain_clone("EG", "Electrocardiogram")
      domain_clone("VS", "Vital Signs")

      domain_add_bc("EG", "C49677", "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677") # Heart Rate
      domain_add_bc("VS", "C25206", "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25206") # Temperature
      domain_add_bc("VS", "C25208", "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25208") # Weight
      
      # View the form
      click_navbar_form
      expect(page).to have_content 'Index: Forms' 
      click_main_table_link "MIXED", 'History'
      expect(page).to have_content 'History:'
      click_main_table_link "0.1.0", 'View'
      expect(page).to have_content 'View:'
      wait_for_ajax
      
      # aCRF
      click_link 'aCRF'
      expect(page).to have_content 'Annotated CRF:'
    #pause  
      click_link 'Close'
      expect(page).to have_content 'View:'
      wait_for_ajax

    #csv = AuditTrail.to_csv
    #write_text_file_2(csv, sub_dir, "scenario_7_audit_trail.csv")
      check_audit_trail("scenario_7_audit_trail.csv")

      click_navbar_form
      expect(page).to have_content 'Index: Forms'
      click_main_table_link 'MIXED', 'History'
      expect(page).to have_content 'History: MIXED'
      click_main_table_link '0.1.0', 'Show'
      expect(page).to have_content 'Show: Mixed Form'
      click_link 'Export Turtle'
      wait_for_specific_download("ACME_MIXED.ttl")
      rename_file("ACME_MIXED.ttl", "ACME_MIXED_DFT.ttl")
      copy_file_to_db("ACME_MIXED_DFT.ttl")

    end

  end

end