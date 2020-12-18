require 'rails_helper'

describe "Tags", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include TagHelpers
  include D3GraphHelpers
  include WaitForAjaxHelper
  include UserAccountHelpers
  include NameValueHelpers

  before :all do
    ua_create
    nv_destroy
    nv_create({ parent: '10', child: '999' })
  end

  after :each do
    ua_logoff
  end

  after :all do
    ua_destroy
  end

  describe "Manage Tags, Content Admin", type: :feature, js: true do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      ua_content_admin_login
    end

    it "initial state, root tag actions" do
      go_to_tags

      check_node_count 1
      find_node('Tags').click

      check_node('Tags', nil, selected: true)
      check_actions [:add_child]
      check_actions_not_present [:remove, :edit]
    end

    # Manage Tags (MDR-TAG-20, MDR-TAG-30, MDR-TAG-40, MDR-TAG-45, MDR-TAG-60, MDR-TAG-110)
    it "prevents creating tags, label and description validation (REQ-MDR-TAG-040)" do
      go_to_tags

      find_node('Tags').click

      # Field validation
      click_action :add_child
      ui_in_modal do
        within( find('#generic-editor') ) do

          # Both fields empty
          click_on 'Submit'
          expect(page).to have_text 'Field cannot be empty', count: 2

          # One field empty
          fill_in 'label', with: 'Tag1'
          click_on 'Submit'
          expect(page).to have_text 'Field cannot be empty', count: 1

          fill_in 'label', with: ''
          fill_in 'description', with: 'Test description no label'
          click_on 'Submit'
          expect(page).to have_text 'Field cannot be empty', count: 1

          # Label length
          fill_in 'label', with: 'A very very long label text that cannot be possibly used as a Tag label'
          click_on 'Submit'
          expect(page).to have_text 'String too long', count: 1
          click_on 'Close'
        end
      end
    end

    it "allows to create tags, hierarchy (REQ-MDR-TAG-020, REQ-MDR-TAG-040)" do
      go_to_tags
      create_tag('Tags', 'Tag1', 'Tag 1 level 1')
      create_tag('Tag1', 'Tag1_1', 'Tag 1 level 2')
    end

    it "allows to create tags with identical labels in different parts of the hierarchy (REQ-MDR-TAG-040)" do
      go_to_tags
      create_tag('Tags', 'Tag1', 'Tag 1 level 1')
      create_tag('Tags', 'Tag2', 'Tag 2 level 1')

      create_tag('Tag1', 'Tag1_1', 'Tag 1 level 2')
      find_node('Tag1').click #Deselect
      create_tag('Tag2', 'Tag1_1', 'Similar child tag')

      expect(page).to have_text 'Tag1_1', count: 2
    end

    it "prevents to create tags with identical labels in the same parent tag (REQ-MDR-TAG-040)" do
      go_to_tags
      create_tag('Tags', 'Tag XX', 'Some description')
      create_tag('Tags', 'Tag XX', 'Other description', success: false, error_msg: 'This tag label already exists at this level')
    end

    it "allows to display tag description and search among tags" do
      load_test_tags
      go_to_tags

      # Search
      fill_in 'd3-search', with: 'tag'
      check_node_count 27, 'g.node.search-match'

      fill_in 'd3-search', with: 'tag4'
      ui_press_key :enter
      check_node_count 3, 'g.node.search-match'
      check_node_count 1, 'g.node.search-match.selected'

      # Check tag description on hover
      find_node('TAG4-1-1').hover
      expect(page).to have_selector('.graph-tooltip', text: 'Tag number 4-1-1')
    end

    it "allows to edit a tag (REQ-MDR-TAG-110)" do
      load_test_tags
      go_to_tags

      find_node('TAG2').click

      click_action :edit

      ui_in_modal do
        within( find('#generic-editor') ) do
          fill_in 'label', with: 'TAG2_UPDATED'

          click_on 'Save changes'
        end
      end
      wait_for_ajax 10

      check_node('TAG2_UPDATED', nil, selected: true)
      click_action :edit

      ui_in_modal do
        within( find('#generic-editor') ) do
          fill_in 'description', with: 'Tag 2 updated description'

          click_on 'Save changes'
        end
      end
      wait_for_ajax 10

      find_node('TAG2_UPDATED').hover
      expect(page).to have_selector('.graph-tooltip', text: 'Tag 2 updated description')
    end

    it "prevents to delete a tag with children (REQ-MDR-TAG-045)" do
      go_to_tags

      create_tag('Tags', 'Tag1', 'Tag 1 level 1')
      create_tag('Tag1', 'Tag1_1', 'Tag 1 level 2')

      find_node('Tags').click

      delete_tag('Tag1', success: false, error_msg: 'Cannot destroy tag as it has children tags' )
    end

    it "deleted tags and child tags (REQ-MDR-TAG-045)" do
      load_test_tags
      go_to_tags

      fill_in 'd3-search', with: 'Tag4'
      ui_press_key :enter
      find('#d3-clear-search').click

      delete_tag('TAG4-1-1')
      expect(page).not_to have_content ('TAG4-1-1')

      delete_tag('TAG4-1')
      expect(page).not_to have_content ('TAG4-1')

      delete_tag('TAG4')
      expect(page).not_to have_content ('TAG4')
    end

    it "Not delete tags where children used by managed items (REQ-MDR-TAG-060)" do
      # Prepare data
      make_tagged_item_data

      go_to_tags
      delete_tag('Tag1', success: false, error: 'Cannot destroy tag')
    end

    it "allows to display Managed Items tagged with a certain tag" do
      make_tagged_item_data
      go_to_tags

      find_node('Tag1').double_click
      # No items tagged
      ui_in_modal do
        ui_check_table_info('tagged-items-table', 0, 0, 0, )
        click_on 'Close'
      end

      find_node('Tag1_1').double_click
      # Items tagged
      ui_in_modal do
        ui_check_table_row('tagged-items-table', 1, ["TEST", '1', 'Test Thesaurus'] )
        click_on 'Close'
      end

      find_node('Tag2').double_click
      # Items tagged
      ui_in_modal do
        ui_check_table_info('tagged-items-table', 1, 3, 3, )
        ui_check_table_row('tagged-items-table', 2, ["NP000011P", '1', 'Not Set'] )
        click_on 'Close'
      end

    end

    it "shortens tag label in Tag viewer if it is too many characters" do
      go_to_tags
      create_tag('Tags', 'Very long tag label', 'Description' )

      expect(page).to have_content('Very long tag ...')
    end

    it "view both managed items tagged to the parent tag and managed items tagged to child tags within the same entity when searching for the parent tag (REQ-MDR_TAG-80)"

  end

  describe "CDISC Tags, Content Admin", type: :feature, js: true do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..3)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      ua_content_admin_login
    end

    it "verifies item list table children for CDISC tags", js:true do
      go_to_tags

      find_node('SDTM').double_click

      ui_in_modal do
        ui_check_table_info('tagged-items-table', 1, 10, 71)
        expect(page).to have_xpath('//tr[contains(.,"Controlled Terminology")]', count: 3)

        ui_table_search('tagged-items-table', 'C25681')
        ui_check_table_cell('tagged-items-table', 1, 1, 'C25681')
        ui_check_table_cell('tagged-items-table', 1, 2, '1')
        ui_check_table_cell('tagged-items-table', 1, 4, '2007-03-06 Release')

        click_on 'Close'
      end

      find_node('Protocol').double_click
      ui_in_modal do
        expect(page).to have_content('No items with the selected tag were found.')
        click_on 'Close'
      end

    end

  end

  describe "Edit Concept Tags, Curator User", type: :feature, js: true do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..3)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      nv_destroy
      nv_create({ parent: '10', child: '999' })
      ua_curator_login
    end

    after :all do
      nv_destroy
    end

    def view_attach_detach_tags
      make_tagged_item_data(tag_items: false)

      yield

      attach_tag 'Tag1'
      attach_tag 'Tag2'
      attach_tag 'SDTM'
      attach_tag 'SEND'

      ui_refresh_page true
      check_tags ['Tag1', 'Tag2', 'SDTM', 'SEND']

      detach_tag 'Tag2'
      detach_tag 'Tag1'

      ui_refresh_page true
      check_tags ['SDTM', 'SEND']
    end

    it "view, attach and detach tags on a Thesaurus" do

      view_attach_detach_tags do
        click_navbar_terminology
        wait_for_ajax 10
        find(:xpath, '//tr[contains(.,"Test Thesaurus")]/td/a').click
        wait_for_ajax 20
        context_menu_element_v2('history', 'TEST', :show)
        edit_tags 'Test Thesaurus'
      end

    end

    it "view, attach and detach tags on a Code List" do

      view_attach_detach_tags do
        click_navbar_code_lists
        wait_for_ajax 20

        ui_table_search('index', 'NP000010P')
        find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
        wait_for_ajax 20
        context_menu_element_v2('history', '0.1.0', :show)
        edit_tags 'NP000010P'
      end

    end

    it "view and attach tags on a Code List Item" do

      view_attach_detach_tags do
        click_navbar_code_lists
        wait_for_ajax 20

        ui_table_search('index', 'NP000010P')
        find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
        wait_for_ajax 20
        context_menu_element_v2('history', '0.1.0', :show)
        wait_for_ajax 10
        find(:xpath, "//tr[contains(.,'NC00000999C')]/td/a").click

        edit_tags 'NC00000999C'
      end

    end

    it "view and attach tags on a Biomedical Concept" do

      view_attach_detach_tags do
        click_navbar_bc
        wait_for_ajax 20

        find(:xpath, '//tr[contains(.,"Test BC")]/td/a').click
        wait_for_ajax 20
        context_menu_element_v2('history', 'TESTBC', :show)
        edit_tags 'Test BC'

      end

    end

    it "view and attach tags on a  Form" do

      view_attach_detach_tags do
        click_navbar_forms
        wait_for_ajax 20

        find(:xpath, '//tr[contains(.,"Test Form")]/td/a').click
        wait_for_ajax 20
        context_menu_element_v2('history', 'TESTF', :show)
        edit_tags 'Test Form'

      end

    end

  end

end
