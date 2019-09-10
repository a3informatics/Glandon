require 'rails_helper'

describe "CDISC Term", :type => :feature do
  
  include DataHelpers
  include PublicFileHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

  def wait_for_ajax_v_long
    wait_for_ajax(120)
  end

  describe "CDISC Terminology", :type => :feature do
  
    before :all do
      clear_triple_store
      ua_create
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCTerm.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_cdisc_term_versions(1..46)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      delete_all_public_test_files
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    #CL history
    it "allows the CDISC Terminology History page to be viewed (REQ-MDR-CT-031)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
    end

    #CDISC history
    it "allows for several versions of CDISC Terminology (REQ-MDR-CT-010)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      expect(page).to have_content '2016-03-25 Release'
      expect(page).to have_content '2015-12-18 Release'
      expect(page).to have_content '2015-09-25 Release'
    end

    #CDISC Th show
    it "allows a CDISC Terminology version to be viewed (REQ-MDR-CT-031)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'2015-06-26 Release')]/td/a", :text => 'Show').click
      expect(page).to have_content '2015-06-26 Release'
      ui_check_table_info("children_table", 1, 10, 460)
      ui_child_search("967")
      expect(page).to have_content 'C96780'
      expect(page).to have_content 'C96779'
      click_link 'Return'
      expect(page).to have_content 'History: CDISC Terminology'
    end

    #CDISC CL show
    it "allows the entries in a CDISC Terminology code list can be viewed (REQ-MDR-CT-070)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'2014-10-06 Release')]/td/a", :text => 'Show').click
      expect(page).to have_content '2014-10-06 Release'
      ui_check_table_info("children_table", 1, 10, 409)
      ui_child_search("10013")  
      ui_check_table_info("children_table", 1, 10, 10)
      expect(page).to have_content 'EQ-5D-3L TESTCD'
      expect(page).to have_content 'C100135'
      expect(page).to have_content 'CDISC Questionnaire HAMD 17 Test Name Terminology'
      find(:xpath, "//tr[contains(.,'C100136')]/td/a", :text => 'Show').click
      expect(page).to have_content 'EQ-5D-3L TESTCD'
      ui_check_table_info("children_table", 1, 6, 6)
      expect(page).to have_content 'C100393'
      expect(page).to have_content 'C100394'
      expect(page).to have_content 'C100395'  
      click_link 'Return'
      click_link 'Return'
      expect(page).to have_content 'History: CDISC Terminology'
     end

    #CDISC CLI show
    it "allows the details of an entry in a CDISC Terminology code list can be viewed (REQ-MDR-CT-070)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'2015-12-18 Release')]/td/a", :text => 'Show').click
      expect(page).to have_content '2015-12-18 Release'
      ui_check_table_info("children_table", 1, 10, 503)
      ui_child_search("route")
      ui_check_table_info("children_table", 1, 3, 3)
      expect(page).to have_content 'C66729'
      expect(page).to have_content 'CMROUTE'
      expect(page).to have_content 'CDISC CDASH Exposure Route of Administration Terminology'
      find(:xpath, "//tr[contains(.,'C66729')]/td/a", :text => 'Show').click
      ui_check_table_info("children_table", 1, 10, 123)
      expect(page).to have_content 'Show: Route of Administration C66729 (V41.0.0, 41, Standard)'
      expect(page).to have_content 'C94636'
      expect(page).to have_content 'ORAL GAVAGE'
      expect(page).to have_content 'Dietary Route of Administration'
      ui_child_search("oral")
      ui_check_table_info("children_table", 1, 5, 5)
      find(:xpath, "//tr[contains(.,'C38288')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Oral Route of Administration'
      click_link 'Return'
      click_link 'Return'
      click_link 'Return'
      expect(page).to have_content 'History: CDISC Terminology'
    end

     #CDISC CL extensible
    it "displays if a CDISC code list is extensible or not (REQ-MDR-CT-080)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'2015-06-26 Release')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Controlled Terminology CT (V43.0.0, 43, Standard)'
      ui_check_table_info("children_table", 1, 10, 460)
      expect(page).to have_content 'Extensible'
      ui_child_search("C99079")
      ui_check_table_cell('children_table', 1, 5, 'true')
      ui_child_search("C99078")
      ui_check_table_cell('children_table', 1, 5, 'false')
    end

    # currently not working
    it "history allows the status page to be viewed (REQ-MDR-CT-NONE)", js:true do
       click_navbar_cdisc_terminology
       expect(page).to have_content 'History: CDISC Terminology'
       find(:xpath, "//tr[contains(.,'2015-09-25 Release')]/td/a", :text => 'Status').click
       expect(page).to have_content 'Status: CDISC Terminology 2015-09-25 CDISC Terminology (V42.0.0, 42, Standard)'
       click_link 'Return'
       expect(page).to have_content 'History: CDISC Terminology'
     end

    it "history allows the change page to be viewed (REQ-MDR-CT-040)", js:true do
       click_navbar_cdisc_terminology
       expect(page).to have_content 'History: CDISC Terminology'
       click_link 'Changes'
       expect(page).to have_content 'Changes: CDISC Terminology'
    end

    it "history allows the code list changes to be viewed (REQ-MDR-CT-040)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      click_link 'Changes'
      expect(page).to have_content 'Changes: CDISC Terminology'
      input = find(:xpath, '//*[@id="changes_filter"]/label/input')
      input.set("TDI")
      ui_check_table_info("changes", 1, 2, 2)
      expect(page).to have_content 'C49650'
      expect(page).to have_content 'C66787'
      click_link 'Return'
      expect(page).to have_content 'History: CDISC Terminology'
    end

    it "allows the code list item changes to be viewed (REQ-MDR-CT-040)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      click_link 'Changes'
      expect(page).to have_content 'Changes: CDISC Terminology'
      input = find(:xpath, '//*[@id="changes_filter"]/label/input')
      input.set("TDI")
      expect(page).to have_content 'C49650'
      expect(page).to have_content 'C66787'
      find(:xpath, "//tr[contains(.,'C66787')]/td/a", :text => 'Changes').click
      expect(page).to have_content 'Differences: C66787, Diagnosis Group'
      ui_check_table_info("differences_table", 1, 3, 3)
      expect(page).to have_content 'Changes: C66787, Diagnosis Group'
      ui_check_table_info("changes", 1, 1, 1)
      find(:xpath, "//tr[contains(.,'C49651')]/td/a", :text => 'Changes').click
      expect(page).to have_content 'Differences: C49651, Healthy Subject'
      ui_check_table_info("differences_table", 1, 3, 3)
    end

    it "allows changes to be viewed (REQ-MDR-CT-040) - test no longer required" 

    it "allows changes report to be produced (REQ-MDR-CT-NONE)"

    it "allows the submission value with changes to be viewed (REQ-MDR-CT-050)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      click_link 'Submission'
      wait_for_ajax_v_long
      expect(page).to have_content 'Submission: CDISC Terminology'
      ui_check_table_info("changes", 1, 9, 9)
    end

    it "allows the submission value changes to be viewed (REQ-MDR-CT-050)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      click_link 'Submission'
      expect(page).to have_content 'Submission: CDISC Terminology'
      input = find(:xpath, '//*[@id="changes_filter"]/label/input')
      input.set("C67152_C20587")
      # currently not working
      find(:xpath, "//tr[contains(.,'Age Group')]/td/a", :text => 'Changes').click
      expect(page).to have_content 'Changes: C20587, Age Group'
    end

    it "allows submission to be viewed (REQ-MDR-CT-050) - test no longer required" 

    it "allows submission report to be produced (REQ-MDR-CT-NONE)"

  end

end