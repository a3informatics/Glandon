##################### When statements #####################

When('I update Synonyms to {string}') do |string|
  ui_editor_select_by_location(1,4)
   ui_editor_fill_inline "synonym", "#{string}\n"
   wait_for_ajax(20)
end

When('I delete Synonym {string}') do |string|
  ui_editor_select_by_location(1,4)
  ui_editor_fill_inline "synonym", " \n"
  wait_for_ajax(20)
end
When('I update Preferred Term to {string}') do |string|
  ui_editor_select_by_location(1,3)
   ui_editor_fill_inline 'preferred_term', "#{string}\n"
   wait_for_ajax(20)
end

When('I delete Preferred Term {string}') do |string|
  ui_editor_select_by_location(1,3)
  ui_editor_fill_inline 'preferred_term', " \n"
  wait_for_ajax(20)
end

When('I click {string} in context menu for the new code list') do |string|
  row = find("table#history tr", text: "Not Set")
        within(row) do
        ui_table_search("history", "Not Set")
        find(".icon-context-menu").click
        if string == 'edit'
        context_menu_element('history', 4, 'Not Set', :edit)
        end
        end
        wait_for_ajax(20)
end

When('I edit the following properties for {string}:') do |string, table|
  ui_table_search('editor',string)
pause
     table.hashes.each do |hash|
      ui_editor_select_by_location(1, 3)
      ui_editor_fill_inline 'preferred_term', "#{hash['PreferredTerm']}\n"
end
end

When('I edit the following custom properties for {string}:') do |string, table|
  ui_table_search('editor',string)
     table.hashes.each do |hash|
      ui_editor_select_by_location(1, 7)
      ui_editor_fill_inline 'crf_display_value', "#{hash['CRFDisplayValue']}\n"
      if "#{hash['ADaMStage']}" == 'true'
        ui_editor_select_by_location(1, 8)
        check_cell_content('editor', 1, 8, true)
        #ui_check_table_cell_icon 'editor',1, 1, 'sel-filled'
        end
      if "#{hash['ADaMStage']}" == 'false'
        ui_editor_select_by_location(1, 8)
          ui_press_key :enter 
          ui_press_key :arrow_right
          wait_for_ajax 10
          ui_press_key :enter
          wait_for_ajax 10
          check_cell_content('editor', 1, 8, false)
         #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
        end
      
      if "#{hash['DCStage']}" == 'true'
        ui_editor_select_by_location(1, 9)
        check_cell_content('editor', 1, 9, true) 
        #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
        end
      if "#{hash['DCStage']}" == 'false'
          ui_editor_select_by_location(1, 9)
          ui_press_key :enter 
          ui_press_key :arrow_right
          wait_for_ajax 10
          ui_press_key :enter
          wait_for_ajax 10
          check_cell_content('editor', 1, 9, false)
          #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
        end

      if "#{hash['SDTMStage']}" == 'true' 
        ui_editor_select_by_location(1, 10)
        check_cell_content('editor', 1, 10, true)
        #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
        end
      if "#{hash['SDTMStage']}" == 'false'
          ui_editor_select_by_location(1, 10)
          ui_press_key :enter 
          ui_press_key :arrow_right
          wait_for_ajax 10
          ui_press_key :enter
          wait_for_ajax 10
          check_cell_content('editor', 1, 10, false)
          #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
        end
    end
end


Then('I fill in the following value for the new item') do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  pending # Write code here that turns the phrase above into concrete actions
end

