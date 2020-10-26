require 'rails_helper'

describe "Biomedical Concept Instances Editor", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include EditorHelpers
  include ItemsPickerHelpers

  def sub_dir
    return "features/biomedical_concepts"
  end

  def go_to_edit(identifier)
    click_navbar_bc
    wait_for_ajax 20
    ui_table_search('index', identifier)
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
    wait_for_ajax 10
    context_menu_element_v2 'history', identifier, :edit
    wait_for_ajax 10
    expect(page).to have_content 'Biomedical Concept Editor'
  end

  def click_bc(name, action)
    card = page.find('.biomedical-concept', text: name)
    within(card) do
      case action
        when :edit
          card.click
        when :token
          find('.token-timeout').click
        when :remove
          find('.remove-bc').click
      end
    end

    wait_for_ajax 20
  end

  describe "Edit BC", :type => :feature, js:true do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      ua_create
      Token.delete_all
    end

    after :all do
      ua_destroy
      Token.restore_timeout
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows access to edit page, initial state" do
      go_to_edit 'HEIGHT'

      expect(page).to have_content 'Incomplete'
      expect(page).to have_content '0.1.0'

      expect(page).to have_selector '.biomedical-concept.selected', count: 1
      expect(page).to have_selector '.biomedical-concept.selected .token-timeout', count: 1
      expect(page).to have_selector '.biomedical-concept.selected .remove-bc.disabled', count: 1
      ui_check_table_info 'editor', 1, 10, 12
      ui_check_table_cell 'editor', 6, 5, 'Unit'
      ui_check_table_cell 'editor', 7, 5, 'Height'
      ui_check_table_cell 'editor', 1, 8, 'HEIGHT C25347 (VSTESTCD C66741 v61.0.0)'
      ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
      ui_check_table_cell_icon 'editor', 3, 1, 'times-circle'
    end

    it "allows to edit a single BC, inline fields, field errors display" do
      go_to_edit 'HEIGHT'

      # Inline text
      ui_editor_select_by_content 'Result'
      ui_editor_fill_inline "question_text", "Test Result\n"
      ui_editor_check_value 7, 4, 'Test Result'

      # Truefalse field
      ui_press_key :arrow_left
      ui_editor_check_focus(7, 2)
      ui_check_table_cell_icon 'editor', 6, 2, 'sel-filled'
      ui_check_table_cell_icon 'editor', 7, 2, 'sel-filled'

      ui_press_key :enter
      ui_press_key :arrow_right
      ui_press_key :enter
      wait_for_ajax 10

      ui_check_table_cell_icon 'editor', 6, 2, 'times-circle'
      ui_check_table_cell_icon 'editor', 7, 2, 'times-circle'

      ui_press_key :arrow_down
      ui_press_key :arrow_right
      ui_press_key :arrow_right
      ui_press_key :arrow_right

      # Field error check
      ui_press_key :enter
      ui_editor_fill_inline 'format', "x\n"
      ui_editor_check_error 'format', 'contains invalid characters'
      ui_press_key :escape

      # Inline Text
      ui_press_key :enter
      ui_editor_fill_inline 'format', "123\n"
      ui_editor_check_value 8, 7, '123'

    end

    it "allows to edit a single BC, terminology selection" do
      go_to_edit 'HEIGHT'

      ui_editor_select_by_location 7, 8

      # Add Terminology References
      ui_in_modal do
        ip_check_tabs [:unmanaged_concept], 'bc-term-ref'
        ip_pick_unmanaged_items :unmanaged_concept, [
          { parent: 'C100130', version: '62', identifier: 'C96587' },
          { parent: 'C100130', version: '62', identifier: 'C96586' }
        ], 'bc-term-ref', false
        ip_check_selected_info '2', 'bc-term-ref'
        ip_submit 'bc-term-ref'
      end

      ui_editor_check_value 7, 8, 'UNCLE, BIOLOGICAL C96587 (RELSUB C100130 v62.0.0) SISTER, BIOLOGICAL C96586 (RELSUB C100130 v62.0.0)'

      # Remove Multiple Terminology References
      ui_press_key :arrow_up
      ui_press_key :enter

      ui_in_modal do
        ip_remove_from_selection [ 'C48500', 'C71253' ], 'bc-term-ref'
        ip_check_selected_info '2', 'bc-term-ref'
        ip_submit 'bc-term-ref'
      end

      ui_editor_check_value 6, 8, 'm C41139 (UNIT C71620 v62.0.0) cm C49668 (VSRESU C66770 v59.0.0)'

      # Remove All Terminology References

      ui_press_key :enter
      ui_in_modal do
        ip_clear_selection 'bc-term-ref'
        ip_check_selected_info '0', 'bc-term-ref'
        ip_submit 'bc-term-ref'
      end

      ui_editor_check_value 6, 8, ''

    end

    it "allows adding BCs to Editor, prevents duplicates" do
      go_to_edit 'HEIGHT'

      expect(page).to have_selector '.biomedical-concept', count: 1
      ui_check_table_info 'editor', 1, 10, 12

      # Add BC
      find('#add-bc-edit-button').click

      ui_in_modal do
        ip_check_tabs [:bci], 'add-bc-edit'
        ip_pick_managed_items :bci, [ { identifier: 'WEIGHT', version: '1' } ], 'add-bc-edit', false
        ip_check_selected_info 'Weight WEIGHT v0.1.0', 'add-bc-edit'
        ip_submit 'add-bc-edit'
      end

      expect(page).to have_selector '.biomedical-concept', count: 2
      expect(page).to have_selector '.biomedical-concept .token-timeout', count: 2
      expect(page).to have_selector '.biomedical-concept .remove-bc.disabled', count: 1
      expect(page).to have_selector '.biomedical-concept .remove-bc', count: 2

      click_bc 'WEIGHT', :edit
      ui_check_table_info 'editor', 1, 10, 12
      ui_editor_check_value 1, 8, 'WEIGHT C25208 (VSTESTCD C66741 v61.0.0)'

      # Add BC
      find('#add-bc-edit-button').click

      ui_in_modal do
        ip_pick_managed_items :bci, [ { identifier: 'SYSBP', version: '1' } ], 'add-bc-edit'
      end

      expect(page).to have_selector '.biomedical-concept', count: 3
      expect(page).to have_selector '.biomedical-concept .remove-bc', count: 3

      click_bc 'SYSBP', :edit
      ui_check_table_info 'editor', 1, 10, 12

      # Prevent duplicate BC
      find('#add-bc-edit-button').click
      ip_pick_managed_items :bci, [ { identifier: 'SYSBP', version: '1' } ], 'add-bc-edit'
      expect(page).to have_content 'This BC has already been added.'

      expect(page).to have_selector '.biomedical-concept', count: 3
    end

    it "allows to create a BC, gets added to Editor" do
      go_to_edit 'HEIGHT'

      # Create new BC
      find('#new-bc-button').click

      ui_in_modal do
        fill_in 'identifier', with: 'BC Edit Test'
        fill_in 'label', with: 'BC Label'
        find('#new-item-template').click
        ip_pick_managed_items(:bct, [ { identifier: 'BASIC OBS', version: '1' } ], 'new-bc')

        click_on 'Submit'
      end

      wait_for_ajax 10

      # Check added to page
      expect(page).to have_selector '.biomedical-concept', count: 2
      expect(page).to have_content 'BC Edit Test'

      click_bc 'BC Edit Test', :edit

      # Sort
      find(:xpath, "//th[contains(.,'Alias')]").click

      ui_check_table_info 'editor', 1, 10, 13
      ui_editor_check_value 2, 6, 'DATETIME'
    end

    it "allows to edit multiple BCs, inline fields" do
      go_to_edit 'HEIGHT'

      # Add another BC
      find('#add-bc-edit-button').click

      ui_in_modal do
        ip_pick_managed_items :bci, [ { identifier: 'DIABP', version: '1' } ], 'add-bc-edit'
      end

      click_bc 'DIABP', :edit

      ui_check_table_info 'editor', 1, 10, 12

      # Inline text
      ui_editor_select_by_content 'Body Position', true
      ui_editor_fill_inline "question_text", "Patient Body Position\n"
      ui_editor_check_value 5, 4, 'Patient Body Position'

      # Truefalse field
      ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'

      ui_editor_select_by_location 1, 1
      ui_press_key :arrow_right
      ui_press_key :enter
      wait_for_ajax 10

      ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'

      click_bc 'HEIGHT', :edit

      ui_editor_select_by_location 1, 5
      ui_editor_fill_inline "prompt_text", "Custom Prompt Text\t"
      wait_for_ajax 10
      ui_editor_check_value 1, 5, 'Custom Prompt Text'

      ui_editor_check_focus 1, 7
      ui_press_key :enter
      ui_editor_fill_inline "format", "0\n"
      wait_for_ajax 10
      ui_editor_check_value 1, 7, '0'

    end

    it "allows to edit multiple BCs, terminology selection" do
      go_to_edit 'HEIGHT'

      # Add another BC
      find('#add-bc-edit-button').click

      ui_in_modal do
        ip_pick_managed_items :bci, [ { identifier: 'DIABP', version: '1' } ], 'add-bc-edit'
      end

      click_bc 'DIABP', :edit

      # Add Term Reference
      ui_editor_select_by_content 'ARM C32141', true

      ui_in_modal do
          ip_pick_unmanaged_items :unmanaged_concept, [
            { parent: 'C74456', version: '62', identifier: 'C32974' }
          ], 'bc-term-ref'
      end

      ui_editor_check_value 9, 8, 'ARM C32141 (LOC C74456 v62.0.0)'
      ui_editor_check_value 9, 8, 'LEG C32974 (LOC C74456 v62.0.0)'

      # Remove Term Reference

      ui_press_key :enter

      ui_in_modal do
        ip_remove_from_selection ['C32141'], 'bc-term-ref'
        ip_submit 'bc-term-ref'
      end

      ui_editor_check_value 9, 8, 'LEG C32974 (LOC C74456 v62.0.0)'

      click_bc 'HEIGHT', :edit

    end

    it "allows removing BCs from Editor, releases lock" do
      go_to_edit 'WEIGHT'
      tokens_count = Token.all.count

      # Add another BC
      find('#add-bc-edit-button').click

      ui_in_modal do
        ip_pick_managed_items :bci, [ { identifier: 'SYSBP', version: '1' } ], 'add-bc-edit'
      end

      # Add another BC
      find('#add-bc-edit-button').click

      ui_in_modal do
        ip_pick_managed_items :bci, [ { identifier: 'HEIGHT', version: '1' } ], 'add-bc-edit'
      end

      expect(Token.all.count).to eq(tokens_count + 2)
      expect(page).to have_selector '.biomedical-concept', count: 3
      expect(page).to have_selector '.biomedical-concept .remove-bc', count: 3

      click_bc 'SYSBP', :remove
      wait_for_ajax 10

      expect(Token.all.count).to eq(tokens_count + 1)

      click_bc 'HEIGHT', :remove
      wait_for_ajax 10

      expect(Token.all.count).to eq(tokens_count)
      expect(page).to have_selector '.biomedical-concept .remove-bc.disabled', count: 1
    end

    it "allows to Show terminology references in new window" do
      go_to_edit 'HR'

      expect(page).to have_selector 'a.bg-label.highlightable', visible:true, count: 10

      w = window_opened_by { find(:xpath, '//a[contains(.,"ARM C32141")]').click }
      within_window w do
        wait_for_ajax 10
        expect(page).to have_content 'Preferred term: Arm'
        expect(page).to have_content 'The portion of the upper extremity between the shoulder and the elbow.'
      end
      w.close

      w = window_opened_by { find(:xpath, '//a[contains(.,"mmHg C49670")]').click }
      within_window w do
        wait_for_ajax 10
        expect(page).to have_content 'Preferred term: Millimeter of Mercury'
        expect(page).to have_content 'C49670'
      end
      w.close

    end

    it "allows to reload BC Editor data" do
      go_to_edit 'HR'

      ui_check_table_info 'editor', 1, 10, 11
      click_on 'Reload'

      expect(page).to have_selector '.spinner-container', visible:true, count: 2
      wait_for_ajax 20

      ui_check_table_info 'editor', 1, 10, 11
    end

    it "allows to view BC Edit help dialog" do
      go_to_edit 'HEIGHT'

      find('#editor-help').click

      ui_in_modal do
        expect(page).to have_content 'How to use Biomedical Concept Editor'
        click_on 'Dismiss'
      end
    end

    it "token timers, warnings, extension and expiration" do
      Token.delete_all
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 5)

      go_to_edit 'HEIGHT'
      sleep 5

      # Add another BC
      find('#add-bc-edit-button').click
      ui_in_modal do
        ip_pick_managed_items :bci, [ { identifier: 'WEIGHT', version: '1' } ], 'add-bc-edit'
      end

      # Warning
      expect(find('.biomedical-concept', text: 'WEIGHT')[:class].include? 'warning').to eq(false)
      expect(find('.biomedical-concept', text: 'HEIGHT')[:class].include? 'warning').to eq(true)

      sleep 5

      expect(find('.biomedical-concept', text: 'WEIGHT')[:class].include? 'warning').to eq(true)

      # Extend Token by editing
      ui_editor_select_by_location 1, 4
      ui_editor_fill_inline 'question_text', "Extending Edit Lock\n"

      expect(find('.biomedical-concept', text: 'HEIGHT')[:class].include? 'warning').to eq(false)
      expect(find('.biomedical-concept', text: 'WEIGHT')[:class].include? 'warning').to eq(true)

      # Extend Token with button
      click_bc 'WEIGHT', :token
      wait_for_ajax 10

      expect(find('.biomedical-concept', text: 'HEIGHT')[:class].include? 'warning').to eq(false)
      expect(find('.biomedical-concept', text: 'WEIGHT')[:class].include? 'warning').to eq(false)

      # Danger
      sleep Token.get_timeout - (@user_c.edit_lock_warning.to_i / 2) + 2

      expect(find('.biomedical-concept', text: 'HEIGHT')[:class].include? 'danger').to eq(true)
      expect(find('.biomedical-concept', text: 'WEIGHT')[:class].include? 'danger').to eq(true)

      sleep 28

      # Expired
      expect(page).to have_selector '.token-timeout.disabled', count: 2
      expect(page).to have_content '00:00', count: 2

      Token.restore_timeout
    end

    it "token timer, expires edit lock, prevents changes" do
      Token.set_timeout(10)
      go_to_edit "HEIGHT"

      # Add another BC
      find('#add-bc-edit-button').click
      ui_in_modal do
        ip_pick_managed_items :bci, [ { identifier: 'WEIGHT', version: '1' } ], 'add-bc-edit'
      end

      # Load data
      click_bc 'WEIGHT', :edit

      sleep 12

      ui_editor_select_by_location 2, 4
      ui_editor_fill_inline 'question_text', "Testing Edit Lock\n"
      expect(page).to have_content 'The edit lock has timed out'

      click_bc 'HEIGHT', :edit
      sleep 0.5

      ui_editor_select_by_location 2, 4
      ui_editor_fill_inline 'question_text', "Testing Edit Lock\n"
      expect(page).to have_content 'The edit lock has timed out'

      Token.restore_timeout
    end

    it "releases edit locks on page leave" do
      Token.delete_all
      token_count = Token.all.count
      go_to_edit "HEIGHT"

      # Add BCs
      find('#add-bc-edit-button').click
      ui_in_modal do
        ip_pick_managed_items :bci, [ { identifier: 'WEIGHT', version: '1' } ], 'add-bc-edit'
      end

      find('#add-bc-edit-button').click
      ui_in_modal do
        ip_pick_managed_items :bci, [ { identifier: 'BMI', version: '1' } ], 'add-bc-edit'
      end

      expect(Token.all.count).to eq(token_count + 3)

      click_on 'Return'
      wait_for_ajax 20

      expect(Token.all.count).to eq(token_count)
    end


  end

  describe "Edit BC, Locked Status", :type => :feature, js:true do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      ua_create
      Token.delete_all
    end

    after :all do
      ua_destroy
      Token.restore_timeout
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows to edit a BC in a locked state" do
      go_to_edit 'HEIGHT'

      # Put to Recorded - locked state
      click_on 'Return'
      wait_for_ajax 20

      context_menu_element_v2('history', 'HEIGHT', :document_control)
      click_on 'Submit Status Change'
      click_on 'Submit Status Change'

      click_on 'Return'
      wait_for_ajax 20

      context_menu_element_v2('history', 'HEIGHT', :edit)
      wait_for_ajax 20

      ui_check_table_info('editor', 1, 10, 12)
      ui_editor_select_by_location 1, 4
      ui_editor_fill_inline 'question_text', "Testing locked edits\n"
      ui_check_table_info('editor', 1, 10, 12)
      ui_editor_check_value 1, 4, 'Testing locked edits'

      ui_check_table_cell_icon 'editor', 1, 2, 'times-circle'

      ui_editor_select_by_location 1, 2
      ui_press_key :arrow_left
      ui_press_key :enter
      wait_for_ajax 10

      ui_check_table_cell_icon 'editor', 1, 2, 'sel-filled'

      ui_editor_select_by_location 2, 8, true

      ui_in_modal do
          ip_pick_unmanaged_items :unmanaged_concept, [
            { parent: 'C74456', version: '62', identifier: 'C32974' }
          ], 'bc-term-ref'
      end

      ui_editor_check_value 2, 8, 'LEG C32974 (LOC C74456 v62.0.0)'

      click_on 'Return'
      wait_for_ajax 20

      ui_check_table_info('history', 1, 2, 2)
    end

  end

end
