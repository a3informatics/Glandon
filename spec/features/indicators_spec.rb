require 'rails_helper'

describe "Indicators", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  def sub_dir
    return "features/"
  end

  describe "Indicators", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "change_instructions_test.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..58)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("thesaurus_sponsor1_upgrade.ttl")
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
      ua_create
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

    it "Code Lists Index", js:true do
      click_navbar_code_lists
      wait_for_ajax 20
      ui_check_table_row_indicators("index", 1, 5, ["extension"], new_style: true)
      ui_check_table_row_indicators("index", 2, 5, ["a subset"], new_style: true)
      ui_check_table_row_indicators("index", 3, 5, ["27 versions"], new_style: true)
    end

    it "Thesaurus Show, children table", js:true do
      click_navbar_terminology
      wait_for_ajax 20
      find(:xpath, "//tr[contains(.,'AIRPORTS')]/td/a").click
      wait_for_ajax 10
      context_menu_element("history", 1, "0.1.0", :show)
      wait_for_ajax 10
      ui_check_table_row_indicators("children", 1, 8, ["3 change instructions"], new_style: true)
      ui_check_table_row_indicators("children", 1, 8, ["0 change notes"], new_style: true)
    end

    it "Code List Show (header, children table)", js:true do
      ci = ci_prepare
      click_navbar_code_lists
      wait_for_ajax 20
      ui_table_search("index", "cdisc Epoch")
      find(:xpath, "//tr[contains(.,'Epoch')]/td/a").click
      wait_for_ajax 10
      context_menu_element("history", 1, "52.0.0", :show)
      wait_for_ajax 10
      ui_check_table_row_indicators("children", 1, 7, ["1 change instruction"], new_style: true)
      ui_check_indicators("#header-indicators .indicators-wrap", ["subsetted", "extended"])
      ci.delete
    end

    it "Code List Item show (header)", js:true do
      ci = ci_prepare
      click_navbar_code_lists
      wait_for_ajax 20
      ui_table_search("index", "cdisc Epoch")
      find(:xpath, "//tr[contains(.,'Epoch')]/td/a").click
      wait_for_ajax 10
      context_menu_element("history", 1, "52.0.0", :show)
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'C99158')]/td/a").click
      wait_for_ajax 10
      ui_check_indicators("#header-indicators .indicators-wrap", ["1 change instruction"])
      ci.delete
    end

    it "Current Version", js:true do
      # Prepare
      ct = Thesaurus.create({identifier: "TST", label: "Test Terminology"})
      ct.make_current
      ct.save
      # Check Indicator
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'TST')]/td/a").click
      wait_for_ajax 10
      ui_check_table_row_indicators("history", 1, 8, ["Current version"], new_style: true)
    end

    it "Rank", js:true do
      # Prepare Rank
      click_navbar_code_lists
      wait_for_ajax 20
      ui_table_search("index", "A00001")
      find(:xpath, "//tr[contains(.,'A00001')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "A00001", :edit)
      wait_for_ajax 10
      context_menu_element_header(:enable_rank)
      wait_for_ajax 10
      # Check Indicators
        # Terminology Show
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'AIRPORTS')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :show)
      wait_for_ajax 10
      ui_check_table_row_indicators("children", 1, 8, ["3 change instructions", "ranked"], new_style: true)

        # Code Lists Index
      click_navbar_code_lists
      wait_for_ajax 20
      ui_table_search("index", "A00001")
      ui_check_table_row_indicators("index", 1, 5, ["3 change instructions", "ranked"], new_style: true)

    end

  end

  def ci_prepare
    item = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079_C99158"))
    ci = Annotation::ChangeInstruction.create
    ci.add_references({previous: [item.id]})
    ci
  end


end
