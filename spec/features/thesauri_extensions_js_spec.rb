require 'rails_helper'

describe "Thesauri Extensions", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include NameValueHelpers
  include ItemsPickerHelpers
  include EditorHelpers
  include TagHelpers

  describe "The Content Admin User can", type: :feature, js: true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..46)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      ua_create
      nv_destroy
      nv_create({ parent: "10", child: "999" })
      Thesaurus.create({ identifier: "TEST", label: "Test Label" })
      Token.delete_all
      Token.restore_timeout
      set_transactional_tests false
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
      Token.delete_all
      Token.restore_timeout
      set_transactional_tests true
    end

    it "shows code list extensible flag (REQ-MDR-CT-080)" do
      show_cdisc "2015-06-26 Release"

      ui_check_table_info("children", 1, 10, 504)
      ui_child_search("C99079")
      ui_check_table_cell_extensible('children', 1, 5, true)
      ui_child_search("C99078")
      ui_check_table_cell_extensible('children', 1, 5, false)
    end

    it "extend button present if a code list is extensible (REQ-MDR-EXT-010)" do
      show_cdisc "2015-03-27 Release"

      ui_check_table_info("children", 1, 10, 504)
      ui_child_search("C96783")
      ui_check_table_cell_extensible('children', 1, 5, true)

      find(:xpath, "//tr[contains(.,'C96783')]/td/a", :text => 'Show').click
      wait_for_ajax 10
      expect( context_menu_element_header_present?(:extend) ).to eq true
    end

    it "extend button not present if code list is not extensible (REQ-MDR-EXT-040)" do
      expect(Thesaurus::ManagedConcept).to receive(:can_extend_unextensible?).and_return false

      show_cdisc "2014-12-19 Release"

      ui_check_table_info("children", 1, 10, 477)
      ui_child_search("C78737")
      ui_check_table_cell_extensible('children', 1, 5, false)

      find(:xpath, "//tr[contains(.,'C78737')]/td/a", :text => 'Show').click
      wait_for_ajax 10
      expect(context_menu_element_header_present?(:extend)).to eq false
    end

    it "extend button present if code list is not extensible but can_extend_unextensible? is enabled (REQ-MDR-EXT-040)" do
      expect(Thesaurus::ManagedConcept).to receive(:can_extend_unextensible?).and_return true

      show_cdisc "2014-12-19 Release"

      ui_check_table_info("children", 1, 10, 477)
      ui_child_search("C78737")
      ui_check_table_cell_extensible('children', 1, 5, false)
      find(:xpath, "//tr[contains(.,'C78737')]/td/a", :text => 'Show').click
      wait_for_ajax 10
      expect(context_menu_element_header_present?(:extend)).to eq true
    end

    it "allows to create an Extension, Terminology container (REQ-MDR-EXT-010)" do
      show_cdisc "2014-10-06 Release"

      ui_child_search("C66770")
      find(:xpath, "//tr[contains(.,'C66770')]/td/a", :text => 'Show').click
      wait_for_ajax 10
      context_menu_element_header(:extend)

      ip_pick_managed_items(:thesauri, [ { identifier: 'TEST', version: '1' } ], 'thesaurus')

      wait_for_ajax 10
      expect(page).to have_content "Extension Editor"
      expect(page).to have_content "C66770E"

      # Check Extension was added to Thesaurus
      click_navbar_terminology
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'TEST')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2('history', 'TEST', :show)
      wait_for_ajax 10
      ui_check_table_info('children', 1, 1, 1)
      ui_check_table_cell('children', 1, 1, 'C66770E')
    end

    it "allows to show an Extension, Extending links (REQ-MDR-EXT-010)" do
      show_cdisc "2014-10-06 Release"

      ui_child_search("C66770")
      find(:xpath, "//tr[contains(.,'C66770')]/td/a", :text => 'Show').click
      wait_for_ajax 10

      context_menu_element_header(:extension)
      wait_for_ajax 10
      expect(page).to have_content 'C66770E'
      expect(context_menu_element_header_present?(:extending)).to eq true
      context_menu_element_header(:extending)
      wait_for_ajax 10
      expect(page).to have_content 'C66770'
      expect(context_menu_element_header_present?(:extension)).to eq true
    end

    it "allows to create an Extension, no Terminology container" do
      show_cdisc "2014-10-06 Release"

      ui_child_search('C89967')
      find(:xpath, "//tr[contains(.,'C89967')]/td/a", :text => 'Show').click
      wait_for_ajax 10
      context_menu_element_header(:extend)

      ui_in_modal do
        click_on 'Do not select'
      end
      wait_for_ajax 10
      expect(page).to have_content "Extension Editor"
      expect(page).to have_content "C89967E"
    end

    it "allows to create an Extension, Terminology container, non-extensible Code List" do
      expect(Thesaurus::ManagedConcept).to receive(:can_extend_unextensible?).and_return true

      show_cdisc "2014-12-19 Release"

      ui_child_search("C78737")
      find(:xpath, "//tr[contains(.,'C78737')]/td/a", :text => 'Show').click
      wait_for_ajax 10
      context_menu_element_header(:extend)

      ui_confirmation_dialog true
      ip_pick_managed_items(:thesauri, [ { identifier: 'TEST', version: '1' } ], 'thesaurus')

      expect(page).to have_content "Extension Editor"
      expect(page).to have_content "C78737E"
    end

    it "allows to create an Extension, no Terminology container, non-extensible Code List" do
      expect(Thesaurus::ManagedConcept).to receive(:can_extend_unextensible?).and_return true

      show_cdisc "2014-12-19 Release"

      ui_child_search("C99077")
      find(:xpath, "//tr[contains(.,'C99077')]/td/a", :text => 'Show').click
      wait_for_ajax 10
      context_menu_element_header(:extend)

      ui_confirmation_dialog true
      ui_in_modal do
        click_on 'Do not select'
      end
      wait_for_ajax 10
      expect(page).to have_content "Extension Editor"
      expect(page).to have_content "C99077E"
    end

    it "allows to add one or more existing Code List Items to Extension (REQ-MDR-EXT-010)" do
      edit_extension "C66770E"

      ui_check_table_info('editor', 1, 10, 15)
      # Add
      click_on 'Add items'
      ip_pick_unmanaged_items(:unmanaged_concept, [
        { parent: 'C100129', version: '16', identifier: 'C102111' }
      ], 'add-children')
      wait_for_ajax 10
      # Check added
      ui_check_table_info('editor', 1, 10, 16)
      ui_table_search('editor', 'C102111')
      ui_check_table_cell('editor', 1, 2, 'AIMS')
      ui_check_table_button_class('editor', 1, 8, 'remove')
      ui_table_search('editor', '') # Clear search
      # Add
      click_on 'Add items'
      ip_pick_unmanaged_items(:unmanaged_concept, [
        { parent: 'C66786', version: '16', identifier: 'C16496' },
        { parent: 'C66786', version: '16', identifier: 'C16636' },
        { parent: 'C66786', version: '16', identifier: 'C16773' }
      ], 'add-children')
      wait_for_ajax 10
      # Check added
      ui_check_table_info('editor', 1, 10, 19)
      ui_table_search('editor', 'C16636')
      ui_check_table_cell('editor', 1, 3, 'Germany')
    end

    it "allows to remove referenced items from Extension, prevents removing native items" do
      edit_extension "C66770E"

      ui_check_table_info('editor', 1, 10, 19)

      remove_from_extension('C49674', success = false, error = 'This item cannot be removed as it is native to the extension')
      ui_check_table_info('editor', 1, 10, 19)

      remove_from_extension('C16636')
      ui_check_table_info('editor', 1, 10, 18)
    end

    it "allows to create and remove a new child item in Extension" do
      edit_extension "C66770E"

      ui_check_table_info('editor', 1, 10, 18)
      find('#new-item-button').click
      wait_for_ajax 10

      ui_check_table_info('editor', 1, 10, 19)
      ui_check_table_cell('editor', 1, 1, 'NC00000999C')
      remove_from_extension('NC00000999C')
      ui_check_table_info('editor', 1, 10, 18)
    end

    it "allows to create and remove new children from Synonyms in Extension" do
      edit_extension "C66770E"

      ui_check_table_info('editor', 1, 10, 18)
      ui_table_search('editor', 'C16773')
      find('#nifs-button').click
      find(:xpath, "//tr[contains(.,'C16773')]").click

      ui_confirmation_dialog_with_message true, '2 new item(s) will be created'
      wait_for_ajax 20

      ui_check_table_info('editor', 1, 10, 20)
      ui_check_table_cell('editor', 1, 2, 'KOREA, DEMOCRATIC PEOPLE\'S REPUBLIC OF')
      ui_check_table_cell('editor', 2, 2, 'NORTH KOREA')

      remove_from_extension('NC00001000C')
      ui_check_table_info('editor', 1, 10, 19)
    end

    it "allows to inline edit a child item in Extension" do
      extend_cdisc '2015-12-18', 'C96785'

      find('#new-item-button').click
      wait_for_ajax 10

      ui_editor_select_by_location 1, 2
      ui_editor_fill_inline "notation", "Updated Notation\n"
      ui_editor_check_value 1, 2, "Updated Notation"

      ui_press_key :arrow_right
      ui_press_key :enter

      ui_editor_fill_inline "preferred_term", "Updated PT\t"
      ui_editor_check_value 1, 3, "Updated PT"

      ui_press_key :enter

      ui_editor_fill_inline "synonym", "Updated Synonym\n"
      ui_editor_check_value 1, 4, "Updated Synonym"

      # Field validation
      ui_editor_select_by_location 1, 5
      ui_editor_fill_inline "definition", "I want special chærøcters\n"
      ui_editor_check_error "definition", "contains invalid characters"
    end

    it "prevents inline editing of native and referenced items in an Extension" do
      edit_extension "C96785E"

      ui_editor_select_by_content "TREATMENT FAILURE"
      ui_editor_check_disabled "notation"

      ui_editor_select_by_location 4, 5
      ui_editor_check_disabled "definition"

      # Add referenced
      click_on 'Add items'
      ip_pick_unmanaged_items(:unmanaged_concept, [
        { parent: 'C100129', version: '16', identifier: 'C102111' }
      ], 'add-children')
      wait_for_ajax 10

      ui_table_search('editor', 'C102111')
      ui_editor_select_by_content 'Abnormal Involuntary Movement Scale Questionnaire'
      ui_editor_check_disabled "preferred_term"

      ui_press_key :tab
      ui_press_key :enter
      ui_editor_check_disabled "synonym"
    end

    it "allows to edit tags of a child item in Extension" do
      edit_extension "C96785E"

      edit_tags_cell = find(:xpath, "//tr[contains(.,'Updated Notation')]/td[6]")
      w = window_opened_by { edit_tags_cell.click }
      within_window w do
        wait_for_ajax 10
        expect(page).to have_content "Edit Item Tags"
        attach_tag('SDTM')
        wait_for_ajax 10
      end

      click_on "Refresh"
      wait_for_ajax 10

      ui_check_table_cell "editor", 1, 6, "SDTM"
    end

    it "allows the user to edit properties of an extension" do
      extend_cdisc '2015-12-18', 'C99074'

      expect(context_menu_element_header_present?(:edit_properties)).to eq true
      context_menu_element_header(:edit_properties)

      ui_in_modal do
        # Field validation
        fill_in 'notation', with: ''
        click_on 'Save changes'
        expect(page).to have_content 'Field cannot be empty', count: 1
        # Field validation
        fill_in 'notation', with: 'æøå'
        click_on 'Save changes'
        expect(page).to have_content 'Notation contains invalid characters'

        fill_in 'notation', with: 'TEST EXT'
        fill_in 'definition', with: 'A definition of a test extension'
        click_on 'Save changes'
      end
      wait_for_ajax 10

      within( find('#imh_header') ) do
        expect(page).to have_content 'TEST EXT'
        expect(page).to have_content 'A definition of a test extension'
      end
    end

    it "allows to access Edit Tags from Extension Editor" do
      extend_cdisc '2015-12-18', 'C89960'

      expect(context_menu_element_header_present?(:edit_tags)).to eq true
      w = window_opened_by { context_menu_element_header(:edit_tags) }
      within_window w do
        wait_for_ajax(10)
        expect(page).to have_content "C89960E"
        expect(page).to have_content "Edit Item Tags"
      end
      w.close
    end

    it "edit timeout warnings and extend" do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)

      edit_extension 'C66770E'

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

    it "prevents edits when edit lock expires" do
      Token.set_timeout(3)

      edit_extension 'C66770E'
      sleep 5
      find('#new-item-button').click
      wait_for_ajax 10
      expect(page).to have_content 'The edit lock has timed out'
      remove_from_extension('NC00001001C')
      expect(page).to have_content 'The edit lock has timed out'
    end

    it "can refresh page while editing in a locked state, creates new version" do
      edit_extension 'C96785E'

      click_on 'Return'
      wait_for_ajax 10

      context_menu_element_v2("history", "C96785E", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Return"
      wait_for_ajax 10

      ui_check_table_info("history", 1, 1, 1)
      context_menu_element_v2("history", "C96785E", :edit)
      wait_for_ajax 20
      ui_refresh_page true

      page.go_back
      wait_for_ajax 10
      ui_check_table_info("history", 1, 3, 3)
    end

  end

  # Helpers

  def edit_extension(identifier)
    click_navbar_code_lists
    wait_for_ajax 20

    ui_table_search("index", identifier)
    ui_check_table_row_indicators("index", 1, 5, ["extension"], new_style: true)
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
    wait_for_ajax 10

    context_menu_element_v2("history", identifier, :edit)
    wait_for_ajax 20
    expect(page).to have_content "Extension Editor"
  end

  def show_cdisc(version)
    click_navbar_cdisc_terminology
    wait_for_ajax 10
    context_menu_element_v2("history", version, :show)
    wait_for_ajax 10
  end

  def extend_cdisc(version, identifier)
    show_cdisc version
    ui_child_search identifier
    find(:xpath, "//tr[contains(.,'#{ identifier }')]/td/a", text: 'Show').click
    wait_for_ajax 10

    context_menu_element_header(:extend)
    ui_in_modal do
      click_on 'Do not select'
    end
    wait_for_ajax 10
    expect(page).to have_content 'Extension Editor'
  end

  def remove_from_extension(identifier, success = true, error = '')
    ui_table_search('editor', identifier)
    within( find(:xpath, "//tr[contains(.,'#{identifier}')]") ) do
      find('.remove').click
    end
    ui_confirmation_dialog true if success
    wait_for_ajax 10
    expect(page).to have_content error if !success
    ui_table_search('editor', '')
  end

end
