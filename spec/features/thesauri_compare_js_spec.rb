require 'rails_helper'

describe "Thesauri Compare", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include UiHelpers
  include NameValueHelpers

  describe "Compare Terminology", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl",
                      "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "10")
      NameValue.create(name: "thesaurus_child_identifier", value: "999")
      Thesaurus.create({:identifier => "TST", :label => "Test Label"})
      Token.delete_all
      ua_create
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

    it "allows to compare two cdisc terminologies", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax 30
      context_menu_element("history", 5, "2010-04-08 Release", :compare)
      sleep 1
      expect(page).to have_content "Select Terminology"
      wait_for_ajax 20
      find(:xpath, "//*[@id='index']/tbody/tr[contains(.,'Controlled Terminology')]").click
      wait_for_ajax 30
      find(:xpath, "//*[@id='im-select-modal']//table[@id='history']/tbody/tr[contains(.,'2009-07-06 Release')]").click
      expect(page.find("#number-selected").text).to eq "CT v17.0.0"
      click_button "Submit and proceed"
      wait_for_ajax 30
      expect(page).to have_content "Compare Terminologies"
      expect(page).to have_content "Changes between CT v20.0.0 and CT v17.0.0"
      expect(page).to have_xpath("//div[@id='created_div']/a", count: 0)
      expect(page).to have_xpath("//div[@id='updated_div']/a", count: 18)
      expect(page).to have_xpath("//div[@id='deleted_div']/a", count: 25)
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item R']", count: 2)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item E']", count: 4)
      ui_dashboard_alpha_filter(:updated, "R")
      expect(page.find(".item.R .text", match: :first).text).to eq("Relation to Reference Period")
      ui_dashboard_alpha_filter(:deleted, "U")
      expect(page.find(".item.U .text", match: :first).text).to eq("Unit for the Duration of Treatment Interruption")
    end

    it "allows to compare a sponsor and a cdisc terminology", js:true do
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'TST')]/td").click
      wait_for_ajax 10
      context_menu_element("history", 5, "0.1.0", :edit)
      wait_for_ajax 10
      page.find('.card-with-tabs .show-more-btn').click
      sleep 0.2
      ui_dashboard_single_slider '2010-04-08'
      click_button 'Submit selected version'
      wait_for_ajax 50
      ui_check_table_info("table-cdisc-cls", 1, 10, 81)
      page.find("#table-cdisc-cls-bulk-select").click
      wait_for_ajax 30
      find(:xpath, '//*[@id="table-cdisc-cls"]/tbody/tr[contains(.,"C87162")]').click
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-cdisc-cls"]/tbody/tr[contains(.,"C85495")]').click
      wait_for_ajax 10
      click_navbar_cdisc_terminology
      wait_for_ajax 10
      context_menu_element("history", 5, "2010-04-08 Release", :compare)
      sleep 1
      expect(page).to have_content "Select Terminology"
      wait_for_ajax 20
      find(:xpath, "//*[@id='index']/tbody/tr[contains(.,'TST')]").click
      wait_for_ajax 30
      find(:xpath, "//*[@id='im-select-modal']//table[@id='history']/tbody/tr[contains(.,'0.1.0')]").click
      expect(page.find("#number-selected").text).to eq "TST v0.1.0"
      click_button "Submit and proceed"
      wait_for_ajax 10
      expect(page).to have_content "Compare Terminologies"
      expect(page).to have_content "Changes between CT v20.0.0 and TST v0.1.0"
      expect(page).to have_xpath("//div[@id='created_div']/a", count: 0)
      expect(page).to have_xpath("//div[@id='updated_div']/a", count: 0)
      expect(page).to have_xpath("//div[@id='deleted_div']/a", count: 2)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item C']", count: 1)
      expect(page.find("#deleted_div .item .text", match: :first).text).to eq("Common Terminology Criteria for Adverse Events V4.0")
    end

    it "allows to compare two sponsor terminologies", js: true do
      click_navbar_code_lists
      identifier = ui_new_code_list
      context_menu_element('history', 4, identifier, :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      expect(page).to have_content "Update to current"
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'TST')]/td").click
      wait_for_ajax 10
      context_menu_element("history", 5, "0.1.0", :edit)
      wait_for_ajax 10
      page.find('.card-with-tabs .show-more-btn').click
      sleep 0.2
      ui_dashboard_single_slider '2010-04-08'
      click_button 'Submit selected version'
      wait_for_ajax 50
      ui_check_table_info("table-cdisc-cls", 1, 10, 81)
      page.find("#table-cdisc-cls-bulk-select").click
      wait_for_ajax 30
      ui_click_tab "Sponsor CLs"
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-sponsor-cls"]/tbody/tr[contains(.,"'+identifier+'")]').click
      wait_for_ajax 10
      click_navbar_code_lists
      ui_table_search("index", identifier)
      find(:xpath, "//tr[contains(.,'"+identifier+"')]/td/a").click
      wait_for_ajax 10
      context_menu_element("history", 5, "0.1.0", :edit)
      page.find("#tnp_new_button").click
      wait_for_ajax 10
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'TST')]/td").click
      wait_for_ajax 10
      context_menu_element("history", 5, "0.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      expect(page).to have_content "Update to current"
      click_link "Return"
      wait_for_ajax 10
      context_menu_element("history", 5, "0.1.0", :edit)
      wait_for_ajax 30
      find(:xpath, '//*[@id="table-cdisc-cls"]/tbody/tr[contains(.,"C87162")]').click
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-cdisc-cls"]/tbody/tr[contains(.,"C85495")]').click
      wait_for_ajax 10
      ui_click_tab "Sponsor CLs"
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-sponsor-cls"]/tbody/tr[contains(.,"'+identifier+'")]').click
      wait_for_ajax 10
      find(:xpath, '//*[@id="table-sponsor-cls"]/tbody/tr[contains(.,"'+identifier+'")]').click
      wait_for_ajax 10
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'TST')]/td").click
      wait_for_ajax 10
      context_menu_element("history", 5, "0.1.0", :compare)
      sleep 1
      expect(page).to have_content "Select Terminology"
      wait_for_ajax 20
      find(:xpath, "//*[@id='index']/tbody/tr[contains(.,'TST')]").click
      wait_for_ajax 30
      find(:xpath, "//*[@id='im-select-modal']//table[@id='history']/tbody/tr[contains(.,'0.2.0')]").click
      expect(page.find("#number-selected").text).to eq "TST v0.2.0"
      click_button "Submit and proceed"
      wait_for_ajax 10
      expect(page).to have_content "Compare Terminologies"
      expect(page).to have_content "Changes between TST v0.1.0 and TST v0.2.0"
      expect(page).to have_xpath("//div[@id='created_div']/a", count: 0)
      expect(page).to have_xpath("//div[@id='updated_div']/a", count: 1)
      expect(page).to have_xpath("//div[@id='deleted_div']/a", count: 2)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item C']", count: 1)
      expect(page.find("#deleted_div .item .text", match: :first).text).to eq("Common Terminology Criteria for Adverse Events V4.0")
      expect(page.find("#updated_div .item .text", match: :first).text).to eq("Not Set")
      find(:xpath, '//*[@id="updated_div"]/a').click
      wait_for_ajax 10
      expect(page).to have_content "Differences Summary"
      expect(page).to have_content identifier
    end

    it "allows to export a csv report"

    it "compare two same terminologies, error", js: true do
      click_navbar_cdisc_terminology
      wait_for_ajax 30
      context_menu_element("history", 5, "2010-04-08 Release", :compare)
      sleep 1
      expect(page).to have_content "Select Terminology"
      wait_for_ajax 20
      find(:xpath, "//*[@id='index']/tbody/tr[contains(.,'Controlled Terminology')]").click
      wait_for_ajax 30
      find(:xpath, "//*[@id='im-select-modal']//table[@id='history']/tbody/tr[contains(.,'2010-04-08 Release')]").click
      click_button "Submit and proceed"
      wait_for_ajax 10
      expect(page).to have_content "You cannot compare a Terminology with itself"
    end

  end

  describe "Compare Terminology, Community Reader", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl",
                      "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      ua_create
    end

    before :each do
      ua_community_reader_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

    it "does not give option to compare Terminologies in History Panel", js:true do
      click_browse_every_version
      wait_for_ajax 30
      Capybara.ignore_hidden_elements = false
      expect(page).to_not have_link("Compare")
      Capybara.ignore_hidden_elements = true
    end

  end

end
