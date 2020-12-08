require 'rails_helper'

describe "Rank", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include NameValueHelpers
  include UiHelpers
  include ItemsPickerHelpers

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

  # Returns xpath to a rank input field in the table
  def rank_xpath(identifier, target)
    "//table[@id='rank-table']/tbody/tr[contains(.,'#{identifier}')]/td[1]/#{target}"
  end

  # Sets a rank value to a CLI by identifier (rank modal has to be open)
  def set_rank(identifier, rank)
    find(:xpath, rank_xpath(identifier, "span")).click
    input = find(:xpath, rank_xpath(identifier, "input"))
    input.set(rank)
    input.native.send_keys(:return)
  end

  # Checks a rank value by CLI identifier (rank modal has to be open)
  def check_rank(identifier, rank)
    expect(find(:xpath, rank_xpath(identifier, "span")).text).to eq(rank)
  end

  # Navigates to an edit page of a code list identifier and version
  def go_to_edit(identifier, version)
    click_navbar_code_lists
    wait_for_ajax 30
    ui_table_search("index", identifier)
    find(:xpath, "//tr[contains(.,'Sanofi')]/td/a").click
    wait_for_ajax 20
    context_menu_element_v2("history", version, :edit)
    wait_for_ajax 20
  end

  # Removes a rank from CL by URI and removes the CL version itself
  def clear_rank(uri)
    tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: uri))
    rank = Thesaurus::Rank.find(tc.is_ranked_links)
    rank.remove_all
    tc.delete_or_unlink
  end

  describe "Rank Code Lists, Curator user", :type => :feature do

    it "allows to enable rank on a code list", js: true do
      go_to_edit("SC105133", "1.0.0")
      context_menu_element_header_present? :enable_rank
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header_present? :edit_ranks
      ui_check_indicators("#header-indicators .indicators-wrap", ["ranked"])

      context_menu_element_header :edit_ranks
      ui_in_modal do
        expect(page).to have_content "Rank Code List Items (SC105133)"
        click_on "Close"
      end

      clear_rank "http://www.sanofi.com/SC105133/V2#SC105133"
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

      clear_rank "http://www.sanofi.com/SC105133/V2#SC105133"
    end

    it "warns user when closing with unsaved progress", js: true do
      go_to_edit("SC105133", "1.0.0")
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header :edit_ranks
      ui_in_modal do
        set_rank("SC105266", "1234")
        click_on "Close"
        ui_confirmation_dialog_with_message(true, "You have unsaved changes")
      end
      expect(page).not_to have_content "Rank Code List Items (SC105133)"

      clear_rank "http://www.sanofi.com/SC105133/V2#SC105133"
    end

    it "allows to add new children to an already ranked code list", js: true do
      go_to_edit("SC105133", "1.0.0")
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header :edit_ranks
      ui_in_modal do
        check_rank("SC105266", "1")
        click_on "Close"
      end

      click_on "New"
      wait_for_ajax 10
      context_menu_element_header :edit_ranks
      ui_in_modal do
        check_rank("SC105266", "1")
        check_rank("NC00000999C", "7")
        click_on "Close"
      end

      clear_rank "http://www.sanofi.com/SC105133/V2#SC105133"
    end

    it "allows to Auto-rank a code list", js: true do
      go_to_edit("SC105133", "1.0.0")
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header :edit_ranks
      ui_in_modal do
        find(:xpath, "//div[@id='rank-table_wrapper']//th[contains(.,'Preferred Term')]").click
        click_on "Auto-Rank by order"
        sleep 1
        click_on "Save changes"
        wait_for_ajax 20
        expect(page).to have_content "Ranks saved"
        click_on "Close"
      end

      page.driver.browser.navigate.refresh
      wait_for_ajax 20

      context_menu_element_header :edit_ranks
      ui_in_modal do
        check_rank("SC105262", "1")
        check_rank("SC105265", "2")
        check_rank("SC105264", "3")
        check_rank("SC105263", "4")
        check_rank("SC105261", "5")
        check_rank("SC105266", "6")
        click_on "Close"
      end

      clear_rank "http://www.sanofi.com/SC105133/V2#SC105133"
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

    it "allows to create a new CL version with persistent ranks", js: true do
      go_to_edit("SC105133", "1.0.0")
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header :edit_ranks
      ui_in_modal do
        check_rank("SC105265", "2")
        click_on "Close"
      end
      click_on "Return"
      wait_for_ajax 10
      context_menu_element("history", 5, "1.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Return"
      wait_for_ajax 10
      context_menu_element("history", 5, "1.1.0", :edit)
      context_menu_element_header_present? :edit_ranks
      context_menu_element_header :edit_ranks
      ui_in_modal do
        check_rank("SC105265", "2")
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
      ui_check_indicators("#header-indicators .indicators-wrap", ["extension", "ranked"])

      context_menu_element_header :edit_ranks
      ui_in_modal do
        expect(page).to have_content "Rank Code List Items (C88025)"
        check_rank("C98794", "3")
        click_on "Close"
      end

      clear_rank "http://www.sanofi.com/C88025/V2#C88025"
    end

    it "allows to add items to an already ranked extension", js: true do
      go_to_edit("C88025", "1.0.0")
      context_menu_element_header :enable_rank
      wait_for_ajax 10

      click_link 'Add items'

      ip_pick_unmanaged_items(:unmanaged_concept, [
        { parent: "C99074", owner: "cdisc", version: "9", identifier: "C98798" },
        { parent: "C99074", owner: "cdisc", version: "9", identifier: "C94393" }
      ], 'add-children')
      wait_for_ajax 10

      context_menu_element_header :edit_ranks
      ui_in_modal do
        expect(page).to have_content "Rank Code List Items (C88025)"
        check_rank("C94393", "325")
        check_rank("C98798", "324")
        click_on "Close"
      end

      clear_rank "http://www.sanofi.com/C88025/V2#C88025"
    end

  end

  describe "Rank Subsets, Curator user", :type => :feature do

    it "allows to enable rank on a subset", js: true do
      go_to_edit("SN003001", "1.0.0")
      context_menu_element_header_present? :enable_rank
      context_menu_element_header :enable_rank
      wait_for_ajax 10
      context_menu_element_header_present? :edit_ranks
      ui_check_indicators("#header-indicators .indicators-wrap", ["a subset", "ranked"])

      context_menu_element_header :edit_ranks
      ui_in_modal do
        expect(page).to have_content "Rank Code List Items (SN003001)"
        check_rank("C48660", "2")
        click_on "Close"
      end

      clear_rank "http://www.sanofi.com/SN003001/V2#SN003001"
    end

    it "allows to add items to an already ranked subset", js: true do
      go_to_edit("SN003001", "1.0.0")
      context_menu_element_header :enable_rank
      wait_for_ajax 10

      find(:xpath, "//tr[contains(.,'C49501')]").click
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'C17998')]").click
      wait_for_ajax 10

      context_menu_element_header :edit_ranks
      ui_in_modal do
        expect(page).to have_content "Rank Code List Items (SN003001)"
        check_rank("C49501", "3")
        check_rank("C17998", "4")
        click_on "Close"
      end

      clear_rank "http://www.sanofi.com/SN003001/V2#SN003001"
    end

  end

end
