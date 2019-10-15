require 'rails_helper'

describe "CDISC Term", :type => :feature do

  include DataHelpers
  include PublicFileHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include CdiscCtHelpers

  def sub_dir
    return "features/cdisc_term"
  end

  def wait_for_ajax_v_long
    wait_for_ajax(120)
  end

  describe "CDISC Terminology. Curator Login", :type => :feature do

    before :all do
      ua_create
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl",
                      "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
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

    after :each do
      ua_logoff
    end

    #CL history
    it "allows the CDISC Terminology History page to be viewed (REQ-MDR-CT-031, REQ-MDR-MIT-015)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
    end

    #CDISC history
    it "allows for several versions of CDISC Terminology (REQ-MDR-CT-010)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      expect(page).to have_content '2015-12-18 Release'
      expect(page).to have_content '2015-09-25 Release'
      expect(page).to have_content '2015-06-26 Release'
    end

    #CDISC Th show
    it "allows a CDISC Terminology version to be viewed (REQ-MDR-CT-031)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-06-26 Release", :show)
      expect(page).to have_content '2015-06-26 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      ui_child_search("967")
      expect(page).to have_content 'C96780'
      expect(page).to have_content 'C96779'
      click_link 'Return'
      expect(page).to have_content 'History'
    end

    #CDISC Th show
    it "shows version 1 (GLAN-652) (REQ-MDR-CT-031)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(10)
      ui_table_search("history", "2007-03-06")
      context_menu_element("history", 5, "2007-03-06 Release", :show)
      expect(page).to have_content '2007-03-06 Release'
      ui_check_table_info("children_table", 1, 10, 32)
      click_link 'Return'
      expect(page).to have_content 'History'
    end

    #CDISC CL show
    it "allows the entries in a CDISC Terminology code list can be viewed (REQ-MDR-CT-070)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2014-10-06 Release", :show)
      expect(page).to have_content '2014-10-06 Release'
      ui_check_table_info("children_table", 1, 10, 446)
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
      expect(page).to have_content 'History'
     end

    #CDISC CL check table columns
    it "Checks CDISC CL table columns (REQ-MDR-CT-???)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2014-10-06 Release", :show)
      expect(page).to have_content '2014-10-06 Release'
      ui_check_table_info("children_table", 1, 10, 446)
      ui_child_search("10013")
      ui_check_table_info("children_table", 1, 10, 10)
      expect(page).to have_content 'EQ-5D-3L TESTCD'
      expect(page).to have_content 'C100135'
      expect(page).to have_content 'CDISC Questionnaire HAMD 17 Test Name Terminology'
      find(:xpath, "//tr[contains(.,'C100136')]/td/a", :text => 'Show').click
      expect(page).to have_content 'EQ-5D-3L TESTCD'
      expect(page).to have_content 'EQ-5D-3L TESTCD'
      ui_check_table_head("children_table", 1, "Identifier")
      ui_check_table_head("children_table", 2, "Submission Value")
      ui_check_table_head("children_table", 3, "Preferred Term")
      ui_check_table_head("children_table", 4, "Synonym(s)")
      ui_check_table_head("children_table", 5, "Definition")
      expect(page).to have_xpath("//*[@id='children_table']/thead/tr/th", count: 6)
    end

    #CDISC CLI show
    it "allows the details of an entry in a CDISC Terminology code list can be viewed (REQ-MDR-CT-070)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-12-18 Release", :show)
      expect(page).to have_content '2015-12-18 Release'
      ui_check_table_info("children_table", 1, 10, 561)
      ui_child_search("route")
      ui_check_table_info("children_table", 1, 3, 3)
      expect(page).to have_content 'C66729'
      expect(page).to have_content 'CMROUTE'
      expect(page).to have_content 'CDISC CDASH Exposure Route of Administration Terminology'
      find(:xpath, "//tr[contains(.,'C66729')]/td/a", :text => 'Show').click
      wait_for_ajax(7)
      ui_check_table_info("children_table", 1, 10, 123)
      expect(page).to have_content 'Route'
      expect(page).to have_content 'C94636'
      expect(page).to have_content 'ORAL GAVAGE'
      expect(page).to have_content 'Dietary Route of Administration'
      ui_child_search("oral")
      wait_for_ajax(7)
      ui_check_table_info("children_table", 1, 5, 5)
      find(:xpath, "//tr[contains(.,'C38288')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Oral Route of Administration'
      click_link 'Return'
      click_link 'Return'
      click_link 'Return'
      expect(page).to have_content 'History'
    end

    it "history allows the status page to be viewed (REQ-MDR-CT-NONE). Currently failing, Add bug?", js:true do
       click_navbar_cdisc_terminology
       expect(page).to have_content 'History'
       find(:xpath, "//tr[contains(.,'2015-09-25 Release')]/td/a", :text => 'Status').click
       expect(page).to have_content 'Status: CDISC Terminology 2015-09-25 CDISC Terminology (V42.0.0, 42, Standard)'
       click_link 'Return'
       expect(page).to have_content 'History'
     end

    it "history allows the change page to be viewed (REQ-MDR-CT-040)", js:true do
       click_navbar_cdisc_terminology
       expect(page).to have_content 'History'
       click_link 'View Changes'
       expect(page).to have_content 'Changes'
    end

    it "history allows the code list changes to be viewed (REQ-MDR-CT-040)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      click_link 'View Changes'
      expect(page).to have_content 'Changes'
      input = find(:xpath, '//*[@id="changes_filter"]/label/input')
      input.set("TDI")
      ui_check_table_info("changes", 1, 2, 2)
      expect(page).to have_content 'C106656'
      expect(page).to have_content 'C106657'
      click_link 'Return'
      expect(page).to have_content 'History'
    end

    it "allows the code list item changes to be viewed (REQ-MDR-CT-040)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      click_link 'View Changes'
      expect(page).to have_content 'Changes'
      input = find(:xpath, '//*[@id="changes_filter"]/label/input')
      input.set("TDI")
      expect(page).to have_content 'C106656'
      find(:xpath, "//tr[contains(.,'C106656')]/td/a", :text => 'Changes').click
      expect(page).to have_content 'Differences'
      ui_check_table_info("differences_table", 1, 3, 3)
      expect(page).to have_content 'Changes'
      ui_check_table_info("changes", 1, 3, 3)
      find(:xpath, "//tr[contains(.,'C106704')]/td/a", :text => 'Changes').click
      expect(page).to have_content 'Differences'
      ui_check_table_info("differences_table", 1, 1, 1)
      click_link 'Return'
      expect(page).to have_content 'Changes'
      click_link 'Return'
      expect(page).to have_content 'Changes'
    end

    it "allows changes to be viewed (REQ-MDR-CT-040) - test no longer required"

    it "allows changes report to be produced (REQ-GENERIC-E-010)"

    it "allows the submission value with changes to be viewed (REQ-MDR-CT-050)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      click_link 'View Submission value changes'
      wait_for_ajax_v_long
      expect(page).to have_content 'Submission'
      ui_check_table_info("changes", 1, 10, 68)
      ui_check_table_cell("changes", 1, 1, "C100391")
      ui_check_table_cell("changes", 1, 2, "Corrected QT Interval")
      ui_check_table_cell("changes", 1, 3, "QTc Correction Method Unspecified")
      ui_check_table_cell_no_change_right("changes", 1, 4)
      ui_check_table_cell_no_change_right("changes", 1, 5)
      ui_check_table_cell_edit("changes", 1, 6)
      ui_check_table_cell_no_change_right("changes", 1, 7)
    end

    it "allows the submission value changes to be viewed (REQ-MDR-CT-050)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      click_link 'View Submission value changes'
      expect(page).to have_content 'Submission'
      input = find(:xpath, '//*[@id="changes_filter"]/label/input')
      #input.set("C67152_C98768")
      input.set("C100425")
      wait_for_ajax_v_long
      find(:xpath, "//tr[contains(.,'HDL Cholesterol to LDL Cholesterol Ratio Measurement')]/td/a", :text => 'Changes').click
      expect(page).to have_content 'Differences'
    end

    it "allows submission to be viewed (REQ-MDR-CT-050) - test no longer required"

    it "allows submission report to be produced (REQ-GENERIC-E-010)"

  end

  describe "CDISC Terminology. Community Reader Login ", :type => :feature do

    before :all do
      ua_create
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl",
                      "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(CdiscCtHelpers.version_range)
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
      ua_comm_reader_login
    end

    after :each do
      ua_logoff
    end

    it "edit, delete, document control disabled" #, js:true do

    it "allows the changes summary to be viewed, changes summary", js: true do
      ui_dashboard_slider("2017-12-22", "2018-03-30")
      click_link 'Display'
      find(:xpath, "//div[@id='updated_div']/a", :text => "DTHDX (C116107)").click
      expect(page).to have_content("Differences Summary")
      expect(page).to have_css("table#differences_table tr", :count=>3)
      expect(page).to have_xpath("//*[@id='differences_table']/tbody/tr[2]/td[5]/div", :text => "SDTM Death Diagnosis Test Name")
      expect(page).to have_xpath("//*[@id='differences_table']/tbody/tr[2]/td[5]/div", :text => "SDTM Death Diagnosis and Details Test Name")
      expect(page).to have_xpath("//*[@id='differences_table']/tbody/tr[2]/td[5]/div", :class => "diff")
    end

    it "allows the changes summary to be viewed, differences summary", js: true do
      ui_dashboard_slider("2017-12-22", "2018-03-30")
      click_link 'Display'
      find(:xpath, "//div[@id='updated_div']/a", :text => "INTMODEL (C99076)").click
      expect(page).to have_content("Changes Summary")
      expect(page).to have_css("table#changes th", :text=>"2017-12-22")
      expect(page).to have_css("table#changes th", :text=>"2018-03-30")
      expect(page).to have_xpath("//*[@id='changes']/tbody/tr[1]/td[5]/span", :class => "icon-plus-circle text-secondary-clr text-xnormal ttip")
      expect(page).to have_xpath("//*[@id='changes']/tbody/tr[4]/td[5]/span", :class => "icon-edit-circle text-link text-xnormal ttip")
    end

    it "allows the changes summary to be viewed, and have a link to history of all changes", js: true do
      ui_dashboard_slider("2017-12-22", "2018-03-30")
      click_link 'Display'
      find(:xpath, "//div[@id='updated_div']/a", :text => "LOC (C74456)").click
      expect(page).to have_content("Changes Summary")
      expect(page).to have_content("Differences Summary")
      expect(page).to have_xpath("//*[@id='history']")
      find(:xpath, "//*[@id='history']", :text => 'History of all changes').click
      expect(page).to have_content("Differences")
      expect(page).to have_content("Changes")
      click_link 'Return'
      expect(page).to have_content("Differences Summary")
      expect(page).to have_content("Changes Summary")
    end

    it "allows the changes summary to be viewed, and see code list items changes", js: true do
      ui_dashboard_slider("2017-03-31", "2017-06-30")
      click_link 'Display'
      find(:xpath, "//div[@id='updated_div']/a", :text => "BSTESTCD (C124300)").click
      expect(page).to have_content("Changes Summary")
      expect(page).to have_content("Differences Summary")
      find(:xpath, "//*[@id='changes']/tbody/tr[3]/td[6]", :text => 'Changes').click
      expect(page).to have_content("Differences")
      click_link 'Return'
      expect(page).to have_content("Differences Summary")
      expect(page).to have_content("Changes Summary")
    end

    it "allows for code list to be exported as CSV (REQ-GENERIC-E-010)", js: true do
      clear_downloads
      click_browse_every_version
      wait_for_ajax(30)
      context_menu_element("history", 5, "2018-12-21 Release", :show)
      wait_for_ajax(5)
      find(:xpath, "//tr[contains(.,'C99079')]/td/a", :text => 'Show').click
      wait_for_ajax(5)
      expect(page).to have_content 'EPOCH'
      click_link 'Export CSV'
      file = download_content
    #Xwrite_text_file_2(file, sub_dir, "export_csv_expected.csv")
      expected = read_text_file_2(sub_dir, "export_csv_expected.csv")
    end

    it "allows for changes across versions to be dowloaded as PDF (REQ-GENERIC-E-010)", js: true do
      clear_downloads
      click_see_changes_all_versions
      wait_for_ajax(30)
      new_window = window_opened_by { click_link 'PDF Report' }
      within_window new_window do
        sleep 10
        pdfdoc = find(:xpath, '/HTML/BODY[1]/EMBED[1]')
        expect(pdfdoc['src']).to include("changes_report.pdf")
        expect(pdfdoc['src']).to include("thesauri")
        page.execute_script "window.close();"
      end
      expect(page).to have_content 'Changes across versions'
    end

    it "allows for changes in code list to be dowloaded as PDF (REQ-GENERIC-E-010)", js: true do
      clear_downloads
      click_see_changes_all_versions
      wait_for_ajax(30)
      find(:xpath, "//tr[contains(.,'C100129')]/td/a", :text => 'Changes').click
      new_window = window_opened_by { click_link 'PDF Report' }
      within_window new_window do
        sleep 10
        pdfdoc = find(:xpath, '/HTML/BODY[1]/EMBED[1]')
        expect(pdfdoc['src']).to include("changes_report.pdf")
        expect(pdfdoc['src']).to include("thesauri/managed_concepts")
        page.execute_script "window.close();"
      end
      expect(page).to have_content 'C100129'
    end

    it "allows for submission value changes to be dowloaded as PDF (REQ-GENERIC-E-010)", js: true do
      clear_downloads
      click_submission_value_changes
      wait_for_ajax(30)
      new_window = window_opened_by { click_link 'PDF Report' }
      within_window new_window do
        sleep 10
        pdfdoc = find(:xpath, '/HTML/BODY[1]/EMBED[1]')
        expect(pdfdoc['src']).to include("submission_report.pdf")
        page.execute_script "window.close();"
      end
      expect(page).to have_content 'Submission value changes'
    end

    it "checks for deleted changes", js: true do
      clear_downloads
      click_see_changes_all_versions
      wait_for_ajax(10)
      ui_table_search("changes", 'TANN02TN')
      find(:xpath, "//tr[contains(.,'TANN02TN')]/td/a", :text => 'Changes').click
      wait_for_ajax(5)
      expect(page).to have_content 'TANN02TN'
      ui_check_table_cell("differences_table", 1, 1, "2015-12-18")

      ui_check_table_cell("differences_table", 1, 2, "C124661")
      ui_check_table_cell("differences_table", 1, 3, "TANNER SCALE BOY TEST")
      ui_check_table_cell("differences_table", 2, 1, "2016-03-25")
      ui_check_table_cell_no_change_down("differences_table", 2, 2)
      ui_check_table_cell("differences_table", 3, 1, "2019-03-29")
      ui_check_table_cell_delete("differences_table", 3, 2)

      ui_check_table_cell("changes", 1, 1, "C124716")
      ui_check_table_cell("changes", 1, 2, "Tanner Scale-Boy - Genitalia Stages")
      ui_check_table_cell("changes", 1, 3, "TANN02-Genitalia Stages")
      ui_check_table_cell_no_change_right("changes", 1, 4)
      ui_check_table_cell_delete("changes", 1, 5)
      ui_check_table_cell("changes", 1, 6, "Changes")
    end

  end

end
