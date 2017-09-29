require 'rails_helper'

describe "ISO Concept JS", :type => :feature do
  
  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

  before :all do
    user = User.create :email => "curator@example.com", :password => "12345678" 
    user.add_role :curator
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    clear_iso_concept_object
  end

  after :all do
    user = User.where(:email => "curator@example.com").first
    user.destroy
  end

  describe "Curator User", :type => :feature do

    it "allows the metadata graph to be viewed", js: true do
      audit_count = AuditTrail.count
      ua_curator_login
      click_link 'Biomedical Concepts'
    #pause
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC A00003')]/td/a", :text => 'History').click
    #pause
      expect(page).to have_content 'History: BC A00003'
      find(:xpath, "//tr[contains(.,'BC A00003')]/td/a", :text => 'Gr+').click
      expect(page).to have_content 'Graph:'
      expect(page).to have_button('graph_focus', disabled: true)
      expect(page).to have_field('concept_type', disabled: true)
      expect(page).to have_field('concept_label', disabled: true)
      click_button 'graph_stop'
      expect(page).to have_button('graph_focus', disabled: false)
      ua_logoff
    end

    it "allows a impact page to be displayed", js: true do
    	ua_curator_login
      click_link 'CDISC Terminology'
      ui_check_page_has('History: CDISC Terminology')
      ui_table_row_link_click('42.0.0', 'Show')
      ui_check_page_has('Show: CDISC Terminology 2015-09-25')
      ui_main_search("VSTESTCD")
      ui_table_row_link_click('VSTESTCD', 'Show')
      ui_check_page_has('Show: Vital Signs Test Code C66741')
      ui_main_search("HR")
      ui_table_row_link_click('C49677', 'Impact')
      ui_check_page_has('Impact Analysis: Heart Rate')
    	wait_for_ajax(10)
      ui_check_table_row('managed_item_table', 1, ["BC C49677", "Heart Rate (BC C49677)", "1.0.0", "0.1"])
      ui_check_table_row('managed_item_table', 2, ["CDISC Terminology", "CDISC Terminology 2015-09-25", "42.0.0", "2015-09-25"])
    #pause
      ui_check_table_row('thesaurus_concept_table', 1, ["C66741", "C49677", "HR", "Heart Rate", "Heart Rate"])
      click_button 'close'
      ui_check_page_has('Show: Vital Signs Test Code C66741')
      ui_main_search("HR")
      ui_table_row_link_click('C49677', 'Impact')
      ui_check_page_has('Impact Analysis: Heart Rate')
      ui_table_row_link_click('BC C49677', 'Show')
      ui_check_page_has("Show: Heart Rate (BC C49677)")
      ua_logoff
    end

    it "allows a impact graph to be clicked"

  end

end