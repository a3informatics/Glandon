require 'rails_helper'

describe "Forms", :type => :feature do

  include DataHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include ItemsPickerHelpers
  include FormHelpers

  def sub_dir
    return "features/forms"
  end

  describe "Forms Editor", :type => :feature, js:true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..65)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_file_into_triple_store("forms/FN000150.ttl")
      load_test_file_into_triple_store("forms/FN000120.ttl")
      load_test_file_into_triple_store("forms/CRF TEST 1.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      Token.delete_all
      ua_create
    end

    after :all do
      ua_destroy
      Token.restore_timeout
      Token.delete_all
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    def edit_form(identifier)
      click_navbar_forms
      wait_for_ajax 20
      find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2 'history', identifier, :edit

      find('#main_area').scroll_to(:center)

      wait_for_ajax 30
      expect(page).to have_content 'Form Editor'
    end

    it "has correct initial state" do
      edit_form('FN000150')

      expect(page).to have_content 'Height (Pilot)'
      expect(page).to have_content 'Identifier: FN000150'
      expect(page).to have_content '0.1.0'
      check_node_count 9

      find('#graph-controls').should have_css('.btn', count: 4)
      find('#graph-controls').should have_css('input', count: 1)

      check_node('Height (Pilot)', :form)
      check_node('Completion status', :question)
      check_node('Placeholder 2', :placeholder)
    end

    it "allows to select and deselect nodes with mouse and keys" do
      edit_form('FN000150')

      find_node('Height (Pilot)').click
      check_node('Height (Pilot)', :form, true)

      find_node('Unit').click
      check_node('Unit', :question, true)
      check_node('Height (Pilot)', :form, false)

      ui_press_key :right
      check_node('Inch', :tuc_ref, true)

      ui_press_key :left
      check_node('Inch', :tuc_ref, false)
      check_node('Unit', :question, true)

      ui_press_key :up
      ui_press_key :up
      check_node('Unit', :question, false)
      check_node('Placeholder 2', :placeholder, true)
    end

    it "allows to control graph with mouse and keys" do
      edit_form('FN000150')

      # Center Graph
      nodes = page.all('g.node').count

      find_node('Height (Pilot)').drag_to find_node('Unit')
      expect( page.all('g.node').count ).to be < nodes
      click_button 'center-graph'
      check_node_count 9

      # Collapse all
      click_button 'collapse-graph'
      check_node_count 1
      check_node('Height (Pilot)', :form)

      # Expand all
      click_button 'expand-graph'
      check_node_count 9

      # Collapse all except
      find_node('Completion status').click
      click_button 'collapse-except-graph'
      check_node_count 7
      check_node('Completion status', :question, true)

      find_node('Completion status').click
      click_button 'expand-graph'
      check_node_count 9

      # Center Graph with key
      nodes = page.all('g.node').count

      find_node('Height (Pilot)').drag_to find_node('Unit')
      expect( page.all('g.node').count ).to be < nodes
      ui_press_key 'c'
      check_node_count 9

      # Collapse all
      ui_press_key 'C'
      check_node_count 1
      check_node('Height (Pilot)', :form)

      # Expand all
      ui_press_key 'E'
      check_node_count 9

      # Collapse all except
      find_node('Completion status').click
      ui_press_key 'X'
      check_node_count 7
    end

    it "shows node label and type when hovered" do
      edit_form('FN000120')

      expect(page).not_to have_css('.graph-tooltip', visible: true)
      find_node('19. Adequately plan').hover

      expect(page).to have_css('.graph-tooltip', visible: true)
      expect(page).to have_content('19. Adequately plan a light meal or snack (ingredients, cookware)')
    end

    it "allows to search and focus on nodes" do
      edit_form('FN000150')

      fill_in 'd3-search', with: 'e'
      expect( find('#d3-search-count').text ).to eq '(7)'
      check_node_count 7, 'g.node.search-match'

      # Re-render the graph and check if search persists
      click_button 'expand-graph'
      sleep 0.5

      check_node_count 7, 'g.node.search-match'

      fill_in 'd3-search', with: 'height'
      check_node_count 2, 'g.node.search-match'

      # Focuses and selects node on Enter press
      ui_press_key :enter
      check_node_count 1, 'g.node.selected.search-match'
      check_node( 'Height (Pilot)', :form, true )
      ui_press_key :enter
      check_node_count 1, 'g.node.selected.search-match'
      check_node( 'Height', :question, true )

      # Clear search
      find('#d3-clear-search').click
      check_node_count 0, 'g.node.search-match'
      expect( find('#d3-search').value ).to eq ''
      expect( find('#d3-search-count').text ).to eq '(0)'
    end

    it "allows to collapse and expand nodes with mouse and keys" do
      edit_form('FN000150')

      # Right Click collapse/expand
      check_node_count 9
      find_node('Height (Pilot)').right_click
      check_node_count 1
      find_node('Height (Pilot)').right_click
      check_node_count 9

      # Space Key press collapse/expand
      find_node('Not Set').click
      ui_press_key :space
      check_node_count 2
      ui_press_key :space
      check_node_count 9
    end

    it "shows respective Actions for different node types" do
      edit_form('CRF TEST 1')

      find_node('CRF Test Form').click
      check_actions([:edit, :add_child, :move_up])
      check_actions_not_present([:remove, :common, :restore])

      find_node('Question 1').click
      check_actions([:edit, :add_child, :move_up, :remove])
      check_actions_not_present([:common, :restore])

      fill_in 'd3-search', with: 'Common Group'
      ui_press_key :enter
      find('#d3-clear-search').click

      check_node('Common Group', :common_group, true)
      check_actions([:edit, :move_up])
      check_actions_not_present([:add_child, :remove, :common, :restore])

      ui_press_key :right
      check_actions([:restore, :move_up])
      check_actions_not_present([:add_child, :remove, :common, :edit])

      find_node( 'Systolic Blood Pressure (BC C' ).click
      ui_press_key :right
      check_actions([:move_up])
      check_actions_not_present([:add_child, :restore, :common, :remove, :edit])

      ui_press_key :down
      check_actions([:move_up, :edit, :common])
      check_actions_not_present([:add_child, :restore, :remove])
    end

    it "loads additional referenced items" do
      edit_form('FN000120')

      find_node('19. Adequately plan').click
      ui_press_key :right
      ui_press_key :right

      click_action :edit

      ui_in_modal do
        within( find('#node-editor') ) do
          expect(page).to have_content 'C48660'
          expect(page).to have_content 'NA'
          expect(page).to have_content 'Not Applicable'

          click_on 'Close'
        end
      end

      # Check loads TUC References in Common Items (was bug)
      edit_form('CRF TEST 1')

      fill_in 'd3-search', with: 'supine'
      check_node_count 1, 'g.node.search-match'
      ui_press_key :enter
      click_action :edit

      ui_in_modal do
        within( find('#node-editor') ) do
          expect(page).to have_content 'Supine Position'
          expect(page).to have_content 'C62167'

          click_on 'Close'
        end
      end

      ui_press_key :left
      ui_press_key :left
      check_node('Common Group', :common_group, true)

    end

    it "allows to Edit a node, field validation" do
      edit_form('FN000150')

      find_node('Not Set').click
      click_action :edit

      # Edit Node data
      ui_in_modal do
        within( find('#node-editor') ) do
          fill_in 'label', with: 'Height Group'
          fill_in 'completion', with: 'Test Completion Instruction'
          click_on 'Save changes'
          wait_for_ajax 10
        end
      end

      check_alert 'Node updated successfully'
      check_node('Height Group', :normal_group, true)
      click_action(:edit)

      ui_in_modal do
        within( find('#node-editor') ) do
          expect( find_field( name: 'completion' ).value ).to eq 'Test Completion Instruction'
          expect( find_field( 'label' ).value ).to eq 'Height Group'
          click_on 'Close'
        end
      end

      find_node('Unit').click
      ui_press_key :right
      click_action :edit

      # Field validation
      ui_in_modal do
        within( find('#node-editor') ) do
          fill_in 'local_label', with: ''
          click_on 'Save changes'

          expect(page).to have_content 'Field cannot be empty'

          fill_in 'local_label', with: 'ø'
          click_on 'Save changes'
          wait_for_ajax 10
          expect(page).to have_content 'contains invalid characters'

          fill_in 'local_label', with: 'New Inch'
          click_on 'Save changes'
          wait_for_ajax 10
        end
      end

      check_alert 'Node updated successfully'
      check_node('New Inch', :tuc_ref, true)

      # Editor rendering of correct inputs
      find_node('Completion status').click
      click_action :edit

      ui_in_modal do
        within( find('#node-editor') ) do
          expect( all('textarea').count ).to eq 4
          expect( all('input[type="text"]').count ).to eq 2
          expect( all('input[type="checkbox"]').count ).to eq 1
          expect( find_field( 'datatype', disabled: true ) )
          expect( find_field( 'format', disabled: true  ) )
          click_on 'Close'
        end
      end

      ui_press_key :down
      ui_press_key :down
      ui_press_key 'e'

      ui_in_modal do
        within( find('#node-editor') ) do
          expect( find_field( 'datatype', disabled: false ) )
          expect( find_field( 'datatype' ).value ).to eq 'float'
          expect( find_field( 'format', disabled: false ) )
          expect( find_field( 'format' ).value ).to eq '5.1'
          expect(page).to have_unchecked_field 'optional'

          find_field( 'optional' ).find(:xpath, '..').click

          fill_in 'label', with: 'Height Q'
          fill_in 'question_text', with: 'Height Question Text'

          select 'integer', from: 'datatype'
          expect( find_field( 'format' ).value ).to eq '3'

          select 'date', from: 'datatype'
          expect( find_field( 'format', disabled: true ) )
          expect( find_field( 'format', disabled: true ).value ).to eq ''

          click_on 'Save changes'
          wait_for_ajax 10
        end
      end

      check_alert 'Node updated successfully'
      check_node('Height Q', :question, true)
      ui_press_key 'e'

      ui_in_modal do
        within( find('#node-editor') ) do
          expect( find_field( 'label' ).value ).to eq 'Height Q'
          expect( find_field( 'question_text' ).value ).to eq 'Height Question Text'
          expect(page).to have_checked_field 'optional'

          click_on 'Close'
        end
      end

    end

    it "allows to Add a child to a node" do
      edit_form('FN000150')

      nodes = node_count

      find_node('Height (Pilot)').click
      click_action :add_child

      # Add Normal Group
      expect( all('#d3 .node-actions a.option').count ).to eq 1
      find(:xpath, '//div[@id="d3"]//a[@id="normal_group"]').click

      wait_for_ajax 10

      check_alert 'Added successfully.'
      ui_press_key 'c' # Center graph
      expect( node_count ).to eq( nodes + 1 )

      click_action :add_child

      # Add Mapping
      expect( all('#d3 .node-actions a.option').count ).to eq 7
      find(:xpath, '//div[@id="d3"]//a[@id="mapping"]').click

      wait_for_ajax 10

      check_alert 'Added successfully.'
      ui_press_key 'c' # Center graph
      expect( node_count ).to eq( nodes + 2 )

      # Add Common Group
      ui_press_key :left
      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="common_group"]').click

      wait_for_ajax 10
      ui_press_key 'e'

      ui_in_modal do
        fill_in 'label', with: 'Common Group 1'
        click_on 'Save changes'
      end

      # Prevents adding duplicate common group
      ui_press_key :left
      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="common_group"]').click

      wait_for_ajax 10

      check_alert 'Normal group already contains a Common Group'
    end

    it "allows to Add a child to a node through Items Picker" do
      edit_form('FN000150')

      # Add BCs to a Group
      find_node('Height (Pilot)').click
      ui_press_key :right

      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="bc_group"]').click

      ip_pick_managed_items( :bci, [
        { identifier: 'WEIGHT', version: '1' }
      ], 'node-add-child' )

      check_alert 'Added successfully.'

      # Check BC added correctly
      find_node('Weight').click
      check_node( 'Weight', :bc, true )
      ui_press_key :right
      check_node( '--ORRES', :bc_property, true )
      ui_press_key :up
      check_node( '--DTC', :bc_property, true )
      ui_press_key :down
      ui_press_key :down
      check_node( '--ORRESU', :bc_property, true )
      ui_press_key :right
      check_node( 'Kilogram', :tuc_ref, true )
      ui_press_key :down
      check_node( 'Pound', :tuc_ref, true )

      nodes = node_count

      # Add TUCs to a Question
      fill_in 'd3-search', with: 'Completion status'
      ui_press_key :enter
      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="tuc_reference"]').click

      ip_pick_unmanaged_items( :unmanaged_concept, [
        { parent: 'C100130', version: '62', identifier: 'C25189' },
        { parent: 'C100130', version: '62', identifier: 'C25174' },
        { parent: 'C100130', version: '62', identifier: 'C25204' }
      ], 'node-add-child' )

      check_alert 'Added successfully.'

      # Check TUCs added correctly
      ui_press_key :right

      expect( node_count ).to eq( nodes + 3 )

      check_node('Mother', :tuc_ref, true)
      check_node('Father', :tuc_ref)
      check_node('Sibling', :tuc_ref)
    end

    it "allows to move node up and down" do
      edit_form('CRF TEST 1')

      fill_in 'd3-search', with: 'Question 3'
      ui_press_key :enter

      # Move Question
      click_action :move_down

      check_alert 'Cannot move Node down'

      click_action :move_up
      wait_for_ajax 10
      check_alert 'Moved successfully'

      ui_press_key :up
      ui_press_key :down
      check_node('Question 3', :question, true)

      ui_press_key(:up, :shift) # Key shortcut
      wait_for_ajax 10
      check_alert 'Moved successfully'

      ui_press_key(:up, :shift) # Key shortcut
      check_alert 'Cannot move Node up'
      check_node('Question 3', :question, true)

      # Move Group
      find_node('Q Repeating Group').click

      ui_press_key(:down, :shift) # Key shortcut
      check_alert 'Cannot move Node down'

      click_action :move_up
      wait_for_ajax 10
      check_alert 'Moved successfully'

      ui_press_key :down
      check_node('Q Group', :normal_group, true)
      ui_press_key :up
      check_node('Q Repeating Group', :normal_group, true)

      ui_press_key(:down, :shift)
      wait_for_ajax 10
      check_alert 'Moved successfully'

      click_action :move_down
      check_alert 'Cannot move Node down'

      # Prevents moving Common Group
      fill_in 'd3-search', with: 'common'
      ui_press_key :enter

      click_action :move_down
      check_alert 'This Node cannot be moved'

      ui_press_key :down
      click_action :move_up
      wait_for_ajax 10
      check_alert 'Attempting to move up past the first node'

      # Move TUC Ref
      ui_press_key :up
      ui_press_key :right
      ui_press_key :down
      ui_press_key :right

      click_action :move_up
      wait_for_ajax 10
      check_alert 'Moved successfully'

      click_action :move_up
      wait_for_ajax 10
      check_alert 'Cannot move Node up'

      ui_press_key(:down, :shift)
      wait_for_ajax 10
      check_alert 'Moved successfully'
    end

    it "allows to remove a node and children" do
      edit_form('FN000150')

      fill_in 'd3-search', with: 'Mother'
      ui_press_key :enter

      nodes = node_count

      # Delete TUC Ref
      click_action :remove
      ui_confirmation_dialog(true)
      wait_for_ajax 10

      check_alert 'Node removed successfully'
      nodes -= 1
      expect( node_count ).to eq( nodes )
      check_node('Completion status', :question, true) # Check parent selected after deletion

      # Delete Question with 3 TUC Ref children
      ui_press_key :delete
      ui_confirmation_dialog(true)
      wait_for_ajax 10

      check_alert 'Node removed successfully'
      nodes -= 4
      expect( node_count ).to eq( nodes )
      check_node('Height Group', :normal_group, true)

      # Delete question without children
      find_node('Height Q').click
      click_action :remove
      ui_confirmation_dialog(true)
      wait_for_ajax 10

      check_alert 'Node removed successfully'
      nodes -= 1
      expect( node_count ).to eq( nodes )

      # Delete BC
      find_node('Weight').click
      ui_press_key :delete
      ui_confirmation_dialog(true)
      wait_for_ajax 10

      check_alert 'Node removed successfully'
      nodes -= 6
      expect( node_count ).to eq( nodes )

      # Removes Normal Group with children
      click_action :remove
      ui_confirmation_dialog(true)
      wait_for_ajax 10

      check_alert 'Node removed successfully'
      nodes -= 5
      expect( node_count ).to eq( nodes )

      # Refresh
      page.driver.browser.navigate.refresh
      wait_for_ajax 20

      check_node_count 4
      check_node_not_exists 'Placeholder 2'
      check_node_not_exists 'Height Group'
    end

    it "allows to make a node common, move references, and restore" do
      # Create a new Form
      click_navbar_forms
      click_on 'New Form'

      ui_in_modal do
        fill_in 'label', with: 'Test Form Label'
        fill_in 'identifier', with: 'TSTFORM'
        click_on 'Submit'
      end
      wait_for_ajax 10

      context_menu_element_v2('history', '0.1.0', :edit)
      wait_for_ajax 10

      expect(page).to have_content 'Form Editor'

      # Add a Group and BCs
      find_node('Test Form').click
      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="normal_group"]').click
      wait_for_ajax 10

      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="bc_group"]').click

      ip_pick_managed_items( :bci, [
        { identifier: 'WEIGHT', version: '1' },
        { identifier: 'HEIGHT', version: '1' },
        { identifier: 'BMI', version: '1' }
      ], 'node-add-child' )

      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="common_group"]').click
      wait_for_ajax 10
      ui_press_key 'e'

      ui_in_modal do
        fill_in 'label', with: 'Common Group'
        click_on 'Save changes'
        wait_for_ajax 10
      end

      find_node('Common Group').click # Deselect
      find_node('Weight').click

      # Make common
      ui_press_key :right
      ui_press_key :down
      click_action :common
      wait_for_ajax 20
      check_alert 'Node updated successfully'

      page.driver.browser.navigate.refresh
      wait_for_ajax 20

      check_node_count 22
      check_node_count( 1, 'g.node.disabled' ) # Common nodes have the disabled css class

      find_node('Weight').click
      click_button 'collapse-except-graph' # Collapse nodes except selected
      sleep 0.5

      check_node_count 9

      click_button 'expand-graph' # Expand nodes again
      sleep 0.5

      find_node('Common Group').click
      ui_press_key :right
      ui_press_key :right
      ui_press_key :down

      check_node('Pound', :tuc_ref, true)

      # Move common item reference
      click_action :move_up
      wait_for_ajax 10
      check_alert 'Moved successfully'
      ui_press_key :left
      ui_press_key :right
      check_node('Pound', :tuc_ref, true)
      click_action :move_down
      wait_for_ajax 10
      check_alert 'Moved successfully'

      ui_press_key :left

      click_button 'collapse-except-graph' # Collapse nodes except selected
      sleep 0.5

      check_node_count 9

      click_button 'expand-graph' # Expand nodes again
      sleep 0.5

      # Make common
      find_node('Height').click
      ui_press_key :right
      ui_press_key :up

      click_action :common
      wait_for_ajax 20
      check_alert 'Node updated successfully'

      check_node_count 23
      check_node_count( 3, 'g.node.disabled' ) # Common nodes have the disabled css class
      find_node('Common Group').click
      click_button 'collapse-except-graph' # Collapse nodes except selected
      sleep 0.5
      check_node_count 10

      # Restore
      page.driver.browser.navigate.refresh
      wait_for_ajax 20

      find_node('Common Group').click
      ui_press_key :right
      click_action :restore
      wait_for_ajax 20

      check_node_count 22
      check_node_count( 2, 'g.node.disabled' ) # Common nodes have the disabled css class

      find_node('Weight').click
      ui_press_key :right
      ui_press_key :down
      ui_press_key :right
      ui_press_key :down
      check_node('Pound', :tuc_ref, true)

      find_node('Common Group').click
      ui_press_key :right
      click_action :restore
      wait_for_ajax 20

      check_node_count 21
      check_node_not_exists 'g.node.disabled'
      find_node('Common Group').click
      click_button 'collapse-except-graph' # Collapse nodes except selected
      check_node_count 6
    end

    it "allows to add a bc and makes properties common automatically" do
      edit_form('TSTFORM')

      find_node('Weight').click
      ui_press_key :right
      ui_press_key :up
      click_action :common
      wait_for_ajax 20

      check_node_count( 2, 'g.node.disabled' ) # Common nodes have the disabled css class

      click_button 'center-graph' # Collapse nodes except selected

      find_node('Not set').click
      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="bc_group"]').click

      ip_pick_managed_items( :bci, [
        { identifier: 'SYSBP', version: '1' },
      ], 'node-add-child' )

      check_node_count( 3, 'g.node.disabled' ) # Common nodes have the disabled css class
    end

    it "allows to remove a bc and its common properties" do
      edit_form('TSTFORM')

      find_node('Weight').click
      click_action :remove
      ui_confirmation_dialog true
      wait_for_ajax 10

      check_node_count( 2, 'g.node.disabled' ) # Common nodes have the disabled css class

      find_node('Height').click
      click_action :remove
      ui_confirmation_dialog true
      wait_for_ajax 10

      find_node('BMI').click
      click_action :remove
      ui_confirmation_dialog true
      wait_for_ajax 10

      find_node('Systolic Blood').click
      click_action :remove
      ui_confirmation_dialog true
      wait_for_ajax 10

      # Check new node count

    end

    it "prevents making a BC Property common when it is disabled" do
      edit_form('TSTFORM')

      find_node('Test Form').click
      ui_press_key :right

      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="bc_group"]').click

      ip_pick_managed_items( :bci, [
        { identifier: 'WEIGHT', version: '1' }
      ], 'node-add-child' )

      find_node('Weight').click
      ui_press_key :right

      check_actions([:edit, :move_up, :move_down, :common])
      click_action :edit

      ui_in_modal do
        find_field( 'enabled' ).find(:xpath, '..').click
        click_on 'Save changes'
        wait_for_ajax 10
      end

      check_alert 'Node updated successfully'
      check_actions([:edit, :move_up])
      check_actions_not_present([:remove, :common, :restore, :add_child])
    end

    it "token timers, warnings, extension and expiration" do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      edit_form('FN000120')

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

    it "token timer, expires edit lock, prevents changes" do
      Token.set_timeout(10)
      edit_form('FN000120')

      sleep 12

      # Prevents to Add a child
      find_node('Disability Assessment').click
      click_action :add_child
      find(:xpath, '//div[@id="d3"]//a[@id="normal_group"]').click
      wait_for_ajax 10

      check_alert 'The edit lock has timed out.'

      # Prevents Updating a Node
      ui_press_key :right
      click_action :edit

      ui_in_modal do
        fill_in 'label', with: 'Expired lock'
        click_on 'Save changes'
        wait_for_ajax 10
        expect(page).to have_content 'The edit lock has timed out.'

        click_on 'Close'
      end

      # Prevents Moving a Node
      click_action :move_up
      wait_for_ajax 10
      check_alert 'The edit lock has timed out.'

      # Prevents Removing a Node
      ui_press_key :right
      ui_press_key :right
      click_action :remove
      ui_confirmation_dialog true
      wait_for_ajax 10
      check_alert 'The edit lock has timed out.'

      Token.restore_timeout
    end

    it "releases edit lock on page leave" do
      edit_form('FN000150')

      expect(Token.all.count).to eq(1)
      click_link 'Return'
      wait_for_ajax 10
      expect(Token.all.count).to eq(0)
    end

    it "allows to show help dialog" do
      edit_form('FN000150')

      find('#editor-help-btn').click
      sleep 0.5
      expect(page).to have_content 'How to use Form Editor'
      click_on 'Dismiss'
    end

  end

end
