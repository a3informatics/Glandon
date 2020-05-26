require 'rails_helper'

describe "Rank", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include NameValueHelpers
  include UiHelpers

  before :all do
    load_files(schema_files, [])
    load_cdisc_term_versions(1..62)
    load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
    load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")

    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "10")
    NameValue.create(name: "thesaurus_child_identifier", value: "999")
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

  def rank_xpath(identifier, target)
    "//table[@id='rank-table']/tbody/tr[contains(.,'#{identifier}')]/td[1]/#{target}"
  end

  def set_rank(identifier, rank)
    find(:xpath, rank_xpath(identifier, "span")).click
    input = find(:xpath, rank_xpath(identifier, "input"))
    input.set(rank)
    input.native.send_keys(:return)
  end

  def check_rank(identifier, rank)
    expect(find(:xpath, rank_xpath(identifier, "span")).text).to eq(rank)
  end

  def go_to_edit(identifier, version)
    click_navbar_code_lists
    wait_for_ajax 20
    ui_table_search("index", identifier)
    find(:xpath, "//tr[contains(.,'Sanofi')]/td/a").click
    wait_for_ajax 20
    context_menu_element("history", 5, version, :edit)
    wait_for_ajax 20
  end

  describe "Rank Code Lists, Curator user", :type => :feature do

    it "allows to enable rank on a code list", js: true do
      go_to_edit("SC124301", "1.0.0")
      context_menu_element_header_present? :enable_rank
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header_present? :edit_ranks
      ui_check_indicators(".indicators", ["ranked"])

      context_menu_element_header :edit_ranks
      ui_in_modal do
        expect(page).to have_content "Rank Code List Items (SC124301)"
        click_on "Close"
      end
    end

    it "allows to edit and save ranks on a code list", js: true do
      go_to_edit("SC105133", "1.0.0")
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header :edit_ranks
      # Edit ranks
      ui_in_modal do
        expect(page).to have_content "Rank Code List Items (SC105133)"
        # Check Help dialog
        find("#rank-help").click
        ui_in_modal do
          expect(page).to have_content "How to use Rank"
          click_on "Dismiss"
        end
        # Check ranks correct
        check_rank("SC105266", "1")
        check_rank("SC105265", "2")
        check_rank("SC105262", "5")
        set_rank("SC105266", "202")
        set_rank("SC105262", "-13")
        click_on "Save changes"
        wait_for_ajax 20
        expect(page).to have_content "Ranks saved"
        click_on "Close"
      end

      page.driver.browser.navigate.refresh
      wait_for_ajax 20

      # Check ranks saved
      context_menu_element_header :edit_ranks
      ui_in_modal do
        expect(page).to have_content "Rank Code List Items (SC105133)"
        check_rank("SC105266", "202")
        check_rank("SC105265", "2")
        check_rank("SC105262", "-13")
        click_on "Close"
      end
    end

    it "warns user when closing with unsaved progress", js: true do
      go_to_edit("SC124307", "1.0.0")
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header :edit_ranks
      ui_in_modal do
        set_rank("SC15843", "1234")
        click_on "Close"
        ui_confirmation_dialog_with_message(true, "You have unsaved changes")
      end
      expect(page).not_to have_content "Rank Code List Items (SC124307)"
    end

    it "allows to disable rank on a code list", js: true do
      go_to_edit("SC100169", "1.0.0")
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header :edit_ranks
      ui_in_modal do
        click_on "Disable rank"
        ui_confirmation_dialog_with_message(true, "All rank data of this Code List will be deleted")
      end
      expect(page).not_to have_content "Rank Code List Items (SC100169)"
      context_menu_element_header_present? :enable_rank
    end

    it "allows to add new children to ranked code list", js: true do
      go_to_edit("SC111347", "1.0.0")
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header :edit_ranks
      ui_in_modal do
        check_rank("SC111520", "1")
        click_on "Close"
      end

      click_on "New"
      wait_for_ajax 10
      context_menu_element_header :edit_ranks
      ui_in_modal do
        check_rank("SC111520", "1")
        check_rank("NC00000999C", "2")
        click_on "Close"
      end
    end

  end

  describe "Rank Extension, Curator user", :type => :feature do

    it "allows to enable rank on an extension", js: true do
      go_to_edit("C88025", "1.0.0")
      context_menu_element_header_present? :enable_rank
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header_present? :edit_ranks
      ui_check_indicators(".indicators", ["extension", "ranked"])

      context_menu_element_header :edit_ranks
      ui_in_modal do
        expect(page).to have_content "Rank Code List Items (C88025)"
        check_rank("C98794", "3")
        click_on "Close"
      end
    end

  end

  describe "Rank Subsets, Curator user", :type => :feature do

    it "allows to enable rank on a subset", js: true do
      go_to_edit("SN003001", "1.0.0")
      context_menu_element_header_present? :enable_rank
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header_present? :edit_ranks
      ui_check_indicators(".indicators", ["a subset", "ranked"])

      context_menu_element_header :edit_ranks
      ui_in_modal do
        expect(page).to have_content "Rank Code List Items (SN003001)"
        check_rank("C48660", "2")
        click_on "Close"
      end
    end

  end

end
