require 'rails_helper'

describe "Scenario 4 - BC Form", :type => :feature do

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
      load_test_temp_file_into_triple_store("ACME_BC_C100392_DFT.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100393_DFT.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100394_DFT.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100395_DFT.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100396_DFT.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100397_DFT.ttl")
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

    INSTRUCTION_TEXT = "By placing a tick in one box in each group below, please indicate which " + 
      "statements best describe your own health state today."
    VAS_TEXT = "To help people say how good or bad a health state is, we have drawn a scale (rather like a thermometer) " +
      "on which the best state you can imagine is marked 100 and the worst state you can imagine is marked 0. \n\n" +
      "We would like you to indicate on this scale how good or bad your own health is today, in your opinion. " +
      " Please do this by drawing a line from the box below to whichever point on the scale indicates how good or " + 
      " bad your health state is today."

    it "allows Forms to be created", scenario: true, js: true do
      set_screen_size(1500, 900)
      
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'

      to_standard("C100392")
      to_standard("C100393")
      to_standard("C100394")
      to_standard("C100395")
      to_standard("C100396")
      to_standard("C100397")

      form_create("EQ5D3L", "start", "EQ-5D-3L")
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      fill_in 'groupCompletion', with: "Fill in everything."
      ui_click_node_name("EQ-5D-3L")
      ui_click_node_name("Group 1")
      click_button 'groupAddCommon'
      expect(page).to have_content 'Common Group Details'
      fill_in 'commonLabel', with: "Common"

      key1 = ui_get_key_by_path('["EQ-5D-3L", "Group 1"]') 
      
      ui_click_node_key(key1)
      click_button 'groupAddLabelText'
      fill_in 'labelTextLabel', with: "General Instructions"
      fill_in 'labelTextText', with: INSTRUCTION_TEXT 

      ui_click_node_key(key1)
      form_bc_search("C100392")
      form_bc_click
      click_button 'groupAddBc'
      wait_for_ajax(10)
    
      ui_click_node_key(key1)
      form_bc_search("C100393")
      form_bc_click
      click_button 'groupAddBc'
      wait_for_ajax(10)

      ui_click_node_key(key1)
      form_bc_search("C100394")
      form_bc_click
      click_button 'groupAddBc'
      wait_for_ajax(10)

      ui_click_node_key(key1)
      form_bc_search("C100395")
      form_bc_click
      click_button 'groupAddBc'
      wait_for_ajax(10)

      ui_click_node_key(key1)
      form_bc_search("C100396")
      form_bc_click
      click_button 'groupAddBc'
      wait_for_ajax(10)

      ui_click_node_key(key1)
      click_button 'groupAddLabelText'
      fill_in 'labelTextLabel', with: "VAS Instructions"
      fill_in 'labelTextText', with: VAS_TEXT 

      ui_click_node_key(key1)
      form_bc_search("C100397")
      form_bc_click
      click_button 'groupAddBc'
      wait_for_ajax(10)

      key2 = ui_get_key_by_path('["EQ-5D-3L", "Group 1", "EQ-5D-3L Mobility", "Date Time (--DTC)"]') 
      ui_click_node_key(key2)
      click_button "itemCommon"
      #ui_click_node_key(key1)
      #wait_for_ajax

      click_button "save"
      wait_for_ajax

      csv = AuditTrail.to_csv
    #write_text_file_2(csv, sub_dir, "scenario_4_audit_trail.csv")
      check_audit_trail("scenario_4_audit_trail.csv")

      click_navbar_form
      click_main_table_link 'EQ5D3L', 'History'

      click_main_table_link '0.1.0', 'Show'
      wait_for_ajax
      click_link 'Export Turtle'
      wait_for_specific_download("ACME_EQ5D3L.ttl")
      rename_file("ACME_EQ5D3L.ttl", "ACME_EQ5D3L_DFT.ttl")
      copy_file_to_db("ACME_EQ5D3L_DFT.ttl")

      bc_export_ttl("C100392", "STD")
      bc_export_ttl("C100393", "STD")
      bc_export_ttl("C100394", "STD")
      bc_export_ttl("C100395", "STD")
      bc_export_ttl("C100396", "STD")
      bc_export_ttl("C100397", "STD")

    end

  end

end