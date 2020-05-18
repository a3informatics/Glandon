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
      ui_check_table_row_indicators("index", 1, 5, ["extension"])
      ui_check_table_row_indicators("index", 2, 5, ["a subset"])
      ui_check_table_row_indicators("index", 3, 5, ["27 versions"])
    end

    it "Thesaurus Show, children table", js:true do
      click_navbar_terminology
      wait_for_ajax 20
      find(:xpath, "//tr[contains(.,'AIRPORTS')]").click
      wait_for_ajax 10
      context_menu_element("history", 1, "0.1.0", :show)
      wait_for_ajax 10
      ui_check_table_row_indicators("children_table", 1, 8, ["3 change instructions"])
      ui_check_table_row_indicators("children_table", 1, 8, ["0 change notes"])
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
      ui_check_table_row_indicators("children_table", 1, 7, ["1 change instruction"])
      ui_check_indicators(".indicators", ["subsetted", "extended"])
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
      ui_check_indicators(".indicators", ["1 change instruction"])
      ci.delete
    end

  end

  def ci_prepare
    item = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079_C99158"))
    ci = Annotation::ChangeInstruction.create
    ci.add_references({previous: [item.id]})
    ci
  end


end
