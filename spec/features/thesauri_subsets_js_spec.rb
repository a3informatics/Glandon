require 'rails_helper'

describe "Thesauri Subsets", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include NameValueHelpers
  include ItemsPickerHelpers

  def sub_dir
    return "features/thesaurus/subset"
  end

  def show_item(term_version, identifier)
    click_navbar_cdisc_terminology
    wait_for_ajax 20
    context_menu_element_v2("history", term_version, :show)
    wait_for_ajax 20
    expect(page).to have_content term_version
    ui_child_search(identifier)
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Show').click
    wait_for_ajax 20
  end

  def add_or_remove_items(identifiers)
    find('#tab-source').click

    identifiers.each do |identifier|
      find(:xpath, "//tr[contains(.,'#{identifier}')]").click
      wait_for_ajax 10
    end
  end

  describe "Subsets Draft State", type: :feature, js:true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)

      Token.delete_all
      nv_destroy
      nv_create({parent: '10', child: '999'})
      Thesaurus.create({identifier: 'SUBSETS', label: 'Subsets Theasurus'})
      ua_create

      set_transactional_tests false
    end

    after :all do
      ua_destroy
      set_transactional_tests true
    end

    before :each do
      Token.restore_timeout
      ua_content_admin_login
    end

    after :each do
      Token.delete_all
      ua_logoff
    end

    it "allows to create a Subset, include in Thesaurus" do
      audit_count = AuditTrail.count

      show_item '2010-03-05 Release', 'C85495'
      expect(page).to have_content("MSRESCAT")
      context_menu_element_header(:subsets)

      ui_in_modal do
        expect(page).to have_content("No subsets found.")
        click_on "+ New Subset"
      end

      ip_pick_managed_items( :thesauri, [{ identifier: 'SUBSETS', version: '1' }], 'thesaurus')
      wait_for_ajax 10

      expect(page).to have_content "Subset Editor"
      expect(page).to have_content "Source Code List (C85495)"
      expect(page).to have_content "Ordered Subset"

      expect(AuditTrail.count).to eq audit_count + 1

      click_on "Return"
      wait_for_ajax 10
      ui_check_table_info("history", 1, 1, 1)

      click_on "Return"
      wait_for_ajax 10
      expect(page).to have_content("Index: Code Lists")
    end

    it "allows to create a Subset, no Thesaurus" do
      audit_count = AuditTrail.count

      show_item '2010-03-05 Release', 'C85495'

      expect(page).to have_content("MSRESCAT")
      context_menu_element_header(:subsets)

      ui_in_modal do
        click_on "+ New Subset"
      end

      ui_in_modal do
        click_on 'Do not select'
      end

      wait_for_ajax 10
      expect(page).to have_content "Subset Editor"
      expect(AuditTrail.count).to eq audit_count + 1
    end

    it "allows to list Subsets of an Item" do
      show_item '2010-03-05 Release', 'C85495'
      expect(page).to have_content("MSRESCAT")
      context_menu_element_header(:subsets)
      ui_in_modal do
        ui_check_table_info 'subsets-index-table', 1, 2, 2
        ui_check_table_cell("subsets-index-table", 1, 1, "NP000010P")
        ui_check_table_cell("subsets-index-table", 2, 1, "NP000011P")
        click_on "Close"
      end
    end

    it "allows to access the Subset Editor from history panel" do
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 10

      expect(page).to have_content("NP000010P")
      expect(page).to have_content("Preferred term: Not Set")
      expect(page).to have_content("Subset Editor")
    end

    # Moving items must be a manual test as it was not manageable to simulate drag and drop
    it "allows to edit a Subset: add and remove items" do
      show_item '2010-03-05 Release', 'C85494'
      context_menu_element_header(:subsets)

      ui_in_modal do
        click_on "+ New Subset"
      end

      ui_in_modal do
        click_on 'Do not select'
      end
      wait_for_ajax 10

      # Check Source children
      ui_check_table_info 'source-table', 1, 10, 208

      # Check Subset children
      find('#tab-subset').click
      ui_check_table_info 'subset-table', 0, 0, 0

      # Add
      add_or_remove_items ['C85813', 'C85811']

      # Check added
      find('#tab-subset').click

      ui_check_table_info 'subset-table', 1, 2, 2
      ui_check_table_cell "subset-table", 1, 1, "1"
      ui_check_table_cell "subset-table", 1, 4, "Second Times Picomole per Milliliter"
      ui_check_table_cell "subset-table", 2, 1, "2"
      ui_check_table_cell "subset-table", 2, 3, "s*nmol/mL"

      # Remove
      add_or_remove_items ['C85813']

      # Check removed
      find('#tab-subset').click
      ui_check_table_info 'subset-table', 1, 1, 1
      ui_check_table_cell "subset-table", 1, 1, "1"
      ui_check_table_cell "subset-table", 1, 3, "s*nmol/mL"

      # Remove
      add_or_remove_items ['C85811']

      # Check removed
      find('#tab-subset').click
      ui_check_table_info 'subset-table', 0, 0, 0

      # Select all
      find('#tab-source').click
      click_on 'Select All'
      wait_for_ajax 20

      find('#tab-subset').click
      ui_check_table_info 'subset-table', 1, 10, 208

      # Deselect all
      find('#tab-source').click
      click_on 'Deselect All'
      wait_for_ajax 20

      find('#tab-subset').click
      ui_check_table_info 'subset-table', 0, 0, 0

    end

    it "edits properties of a subset MC in edit subset" do
      audit_count = AuditTrail.count

      show_item '2010-03-05 Release', 'C81225'
      context_menu_element_header(:subsets)

      ui_in_modal do
        click_on '+ New Subset'
      end

      ip_pick_managed_items( :thesauri, [{ identifier: 'SUBSETS', version: '1' }], 'thesaurus')
      wait_for_ajax 10

      expect(page).to have_content "Subset Editor"
      expect(page).to have_content "Preferred term: Not Set"
      context_menu_element_header(:edit_properties)

      ui_in_modal do
        fill_in "preferred_term", with: "Term 1"
        click_on "Save changes"
      end

      wait_for_ajax 10
      expect(page).to have_content "Preferred term: Term 1"
      expect(AuditTrail.count).to eq audit_count + 2
    end

    it "allows to acces Edit Tags page from Subset Editor" do
      show_item '2010-03-05 Release', 'C81226'
      context_menu_element_header(:subsets)

      ui_in_modal do
        click_on '+ New Subset'
      end

      ui_in_modal do
        click_on 'Do not select'
      end

      w = window_opened_by { context_menu_element_header(:edit_tags) }
      within_window w do
        wait_for_ajax(10)
        expect(page).to have_content "Edit Item Tags"
      end
      w.close
    end

    it "edit timeout warnings and extend" do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)

      show_item '2010-03-05 Release', 'C85495'
      context_menu_element_header(:subsets)

      ui_in_modal do
        context_menu_element_v2('subsets-index-table', 'NP000010P', :edit)
      end
      wait_for_ajax 10

      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2

      expect( find('#imh_header')[:class] ).to include 'warning'

      find( '#timeout' ).click
      wait_for_ajax 10

      expect( find('#imh_header')[:class] ).not_to include 'warning'

      sleep Token.get_timeout - (@user_c.edit_lock_warning.to_i / 2) + 2

      expect( find('#imh_header')[:class] ).to include 'danger'

      sleep 28

      expect( find('#timeout')[:class] ).to include 'disabled'
      expect( find('#imh_header')[:class] ).not_to include 'danger'

      Token.restore_timeout
    end

    it "prevents add, remove and move item in subset, when token expires" do
      Token.set_timeout3

      show_item '2010-03-05 Release', 'C85495'
      context_menu_element_header(:subsets)

      ui_in_modal do
        context_menu_element_v2('subsets-index-table', 'NP000010P', :edit)
      end
      wait_for_ajax 10

      sleep 5

      add_or_remove_items ['C17998']

      expect(page).to have_content "The edit lock has timed out."
    end

    it "clears token when leaving page" do
      show_item '2010-03-05 Release', 'C85495'
      context_menu_element_header(:subsets)

      ui_in_modal do
        context_menu_element_v2('subsets-index-table', 'NP000010P', :edit)
      end
      wait_for_ajax 10

      expect(Token.all.count).to eq(1)
      click_on 'Return'
      wait_for_ajax 10
      expect(Token.all.count).to eq(0)
    end

    it "can refresh page while editing in a locked state, creates new version" do
      show_item '2010-03-05 Release', 'C85491'
      context_menu_element_header(:subsets)

      ui_in_modal do
        expect(page).to have_content("No subsets found.")
        click_on '+ New Subset'
      end

      ui_in_modal do
        click_on 'Do not select'
      end

      click_on 'Return'
      wait_for_ajax 10
      ui_check_table_info("history", 1, 1, 1)

      context_menu_element_v2("history", "0.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_link "Return"
      wait_for_ajax 10

      context_menu_element_v2("history", "0.1.0", :edit)
      expect(page).to have_content("Subset Editor")

      ui_refresh_page
      expect(page).to have_content("Subset Editor")

      click_on 'Return'
      wait_for_ajax 20
      ui_check_table_info("history", 1, 3, 3)
    end

  end

  describe "Subsets, Released State", type: :feature, js: true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_subsets_1.ttl", "thesaurus_subsets_3.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      load_local_file_into_triple_store(sub_dir, "subsets_input_4.ttl")
      Token.delete_all
      nv_destroy
      nv_create({parent: "10", child: "999"})
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      Token.restore_timeout
      ua_content_admin_login
    end

    after :each do
      ua_logoff
      Token.delete_all
    end

    it "allows to edit a Subset: add and remove items" do
      show_item '2010-03-05 Release', 'C85494'
      context_menu_element_header(:subsets)

      ui_in_modal do
        click_on "+ New Subset"
      end

      ui_in_modal do
        click_on 'Do not select'
      end
      wait_for_ajax 10

      # Check Source children
      ui_check_table_info 'source-table', 1, 10, 208

      # Check Subset children
      find('#tab-subset').click
      ui_check_table_info 'subset-table', 0, 0, 0

      # Add
      add_or_remove_items ['C85813', 'C85811']

      # Check added
      find('#tab-subset').click

      ui_check_table_info 'subset-table', 1, 2, 2
      ui_check_table_cell "subset-table", 1, 1, "1"
      ui_check_table_cell "subset-table", 1, 4, "Second Times Picomole per Milliliter"
      ui_check_table_cell "subset-table", 2, 1, "2"
      ui_check_table_cell "subset-table", 2, 3, "s*nmol/mL"

      # Remove
      add_or_remove_items ['C85813']

      # Check removed
      find('#tab-subset').click
      ui_check_table_info 'subset-table', 1, 1, 1
      ui_check_table_cell "subset-table", 1, 1, "1"
      ui_check_table_cell "subset-table", 1, 3, "s*nmol/mL"

      # Remove
      add_or_remove_items ['C85811']

      # Check removed
      find('#tab-subset').click
      ui_check_table_info 'subset-table', 0, 0, 0

      # Select all
      find('#tab-source').click
      click_on 'Select All'
      wait_for_ajax 20

      find('#tab-subset').click
      ui_check_table_info 'subset-table', 1, 10, 208

      # Deselect all
      find('#tab-source').click
      click_on 'Deselect All'
      wait_for_ajax 20

      find('#tab-subset').click
      ui_check_table_info 'subset-table', 0, 0, 0

    end

    it "prevents add, remove and move item in subset, when token expires" do
      Token.set_timeout(10)

      show_item '2010-03-05 Release', 'C85494'
      context_menu_element_header(:subsets)

      ui_in_modal do
        context_menu_element_v2('subsets-index-table', 'PKUNIT', :edit)
      end
      wait_for_ajax 10

      sleep 12

      add_or_remove_items ['C85811']

      expect(page).to have_content "The edit lock has timed out."
    end

  end

  describe "Subsets, Community Reader", type: :feature, js: true do

    before :all do
      ua_create
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_subsets_1.ttl", "thesaurus_subsets_3.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      Token.restore_timeout
    end

    after :all do
      ua_destroy
    end

    it "Allows to see Subsets but does not allow creating" do
      ua_community_reader_login

      click_browse_every_version
      wait_for_ajax 20

      expect(page).to have_content 'Item History'
      context_menu_element_v2("history", "2009-10-06 Release", :show)
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'C78738')]/td/a", :text => 'Show').click
      wait_for_ajax 10

      expect(page).to have_content 'C78738'
      context_menu_element_header :subsets

      ui_in_modal do
        expect(page).to have_content 'No subsets found.'
        expect(page).not_to have_button '+ New Subset'
        click_on 'Close'
      end

      ua_logoff
    end

  end

end
