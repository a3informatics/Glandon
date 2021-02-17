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
     table.hashes.each do |hash|
      ui_editor_select_by_location(1, 3)
      ui_editor_fill_inline 'preferred_term', "#{hash['PreferredTerm']}\n"
      ui_editor_select_by_location(1, 4)
      ui_editor_fill_inline 'synonym', "#{hash['Synonyms']}\n"
      ui_press_key :tab
end
end


 def get_cell_bool_value(table, row, col)
    cell = find(:xpath, "//table[@id='#{ table }']//tbody/tr[#{ row }]/td[#{ col }]", visible: false)
    cell.has_selector? '.icon-sel-filled'
 end


When('I edit the following custom properties for {string}:') do |string, table|
  ui_table_search('editor',string)
     table.hashes.each do |hash|
      ui_editor_select_by_location(1, 7)
      ui_editor_fill_inline 'crf_display_value', "#{hash['CRFDisplayValue']}\n"
      ui_editor_select_by_location(1, 8)
      ui_editor_fill_inline 'display_order', "#{hash['DisplayOrder']}\n"
      ui_editor_select_by_location(1, 9)
      ui_editor_fill_inline 'synonym_sponsor', "#{hash['SynonymSponsor']}\n"
      
      if get_cell_bool_value('editor', 1, 10)
          if "#{hash['ADaMStage']}" == 'true'
            ui_editor_select_by_location(1, 10)
            check_cell_content('editor', 1, 10, true)
            #ui_check_table_cell_icon 'editor',1, 1, 'sel-filled'
            end
          if "#{hash['ADaMStage']}" == 'false'
            ui_editor_select_by_location(1, 10)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
              check_cell_content('editor', 1, 10, false)
             #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
          else
          if "#{hash['ADaMStage']}" == 'true'
            ui_editor_select_by_location(1, 10)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
            check_cell_content('editor', 1, 10, true)
            #ui_check_table_cell_icon 'editor',1, 1, 'sel-filled'
            end
          if "#{hash['ADaMStage']}" == 'false'
              ui_editor_select_by_location(1, 10)
              check_cell_content('editor', 1, 10, false)
             #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
        end
      
      if get_cell_bool_value('editor', 1, 11)
          if "#{hash['DCStage']}" == 'true'
            ui_editor_select_by_location(1, 11)
            check_cell_content('editor', 1, 11, true) 
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['DCStage']}" == 'false'
              ui_editor_select_by_location(1, 11)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
              check_cell_content('editor', 1, 11, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
          else
            if "#{hash['DCStage']}" == 'true'
              ui_editor_select_by_location(1, 11)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
              check_cell_content('editor', 1, 11, true) 
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['DCStage']}" == 'false'
              ui_editor_select_by_location(1, 11)
              
              check_cell_content('editor', 1, 11, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
      end

      if get_cell_bool_value('editor', 1, 12)

          if "#{hash['EDUse']}" == 'true'
            ui_editor_select_by_location(1, 12)
            check_cell_content('editor', 1, 12, true) 
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['EDUse']}" == 'false'
              ui_editor_select_by_location(1, 12)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
              check_cell_content('editor', 1, 12, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
          else
            if "#{hash['EDUse']}" == 'true'
            ui_editor_select_by_location(1, 12)
            ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
            check_cell_content('editor', 1, 12, true) 
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['EDUse']}" == 'false'
              ui_editor_select_by_location(1, 12)
              check_cell_content('editor', 1, 12, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
        end

      if get_cell_bool_value('editor', 1, 13)

          if "#{hash['SDTMStage']}" == 'true' 
            ui_editor_select_by_location(1, 13)
            check_cell_content('editor', 1, 13, true)
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['SDTMStage']}" == 'false'
              ui_editor_select_by_location(1, 13)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
              check_cell_content('editor', 1, 13, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end

      else
        if "#{hash['SDTMStage']}" == 'true' 
            ui_editor_select_by_location(1, 13)
            ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
            check_cell_content('editor', 1, 13, true)
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['SDTMStage']}" == 'false'
              ui_editor_select_by_location(1, 13)
              
              check_cell_content('editor', 1, 13, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
      end
    end
end


Then('I fill in the following value for the new item') do |table|
    table.hashes.each do |hash|
      ui_editor_select_by_location(1,2)
      ui_editor_fill_inline "notation", "#{hash['SubmissionValue']}\n"
      ui_editor_select_by_location(1,3)
      ui_editor_fill_inline "preferred_term", "#{hash['PreferredTerm']}\n"
      ui_editor_select_by_location(1,4)
      ui_editor_fill_inline "synonym", "#{hash['Synonyms']}\n"
      ui_editor_check_value 1, 4, "#{hash['Synonyms']}"
      ui_editor_select_by_location(1,5)
      ui_editor_fill_inline "definition", "#{hash['Definition']}\n"
      
     if page.has_button? "Hide Custom Properties"
      ui_editor_select_by_location(1, 7)
      ui_editor_fill_inline 'crf_display_value', "#{hash['CRFDisplayValue']}\n"
      ui_editor_select_by_location(1, 8)
      ui_editor_fill_inline 'display_order', "#{hash['DisplayOrder']}\n"
      ui_editor_select_by_location(1, 9)
      ui_editor_fill_inline 'synonym_sponsor', "#{hash['SynonymSponsor']}\n"
      if get_cell_bool_value('editor', 1, 10)
          if "#{hash['ADaMStage']}" == 'true'
            ui_editor_select_by_location(1, 10)
            check_cell_content('editor', 1, 10, true)
            #ui_check_table_cell_icon 'editor',1, 1, 'sel-filled'
            end
          if "#{hash['ADaMStage']}" == 'false'
            ui_editor_select_by_location(1, 10)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
              check_cell_content('editor', 1, 10, false)
             #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
          else
          if "#{hash['ADaMStage']}" == 'true'
            ui_editor_select_by_location(1, 10)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
            check_cell_content('editor', 1, 10, true)
            #ui_check_table_cell_icon 'editor',1, 1, 'sel-filled'
            end
          if "#{hash['ADaMStage']}" == 'false'
              ui_editor_select_by_location(1, 10)
              check_cell_content('editor', 1, 10, false)
             #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
        end
      
      if get_cell_bool_value('editor', 1, 11)
          if "#{hash['DCStage']}" == 'true'
            ui_editor_select_by_location(1, 11)
            check_cell_content('editor', 1, 11, true) 
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['DCStage']}" == 'false'
              ui_editor_select_by_location(1, 11)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
              check_cell_content('editor', 1, 11, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
          else
            if "#{hash['DCStage']}" == 'true'
              ui_editor_select_by_location(1, 11)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
              check_cell_content('editor', 1, 11, true) 
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['DCStage']}" == 'false'
              ui_editor_select_by_location(1, 11)
              
              check_cell_content('editor', 1, 11, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
      end

      if get_cell_bool_value('editor', 1, 12)

          if "#{hash['EDUse']}" == 'true'
            ui_editor_select_by_location(1, 12)
            check_cell_content('editor', 1, 12, true) 
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['EDUse']}" == 'false'
              ui_editor_select_by_location(1, 12)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
              check_cell_content('editor', 1, 12, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
          else
            if "#{hash['EDUse']}" == 'true'
            ui_editor_select_by_location(1, 12)
            ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
            check_cell_content('editor', 1, 12, true) 
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['EDUse']}" == 'false'
              ui_editor_select_by_location(1, 12)
              check_cell_content('editor', 1, 12, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
        end

      if get_cell_bool_value('editor', 1, 13)

          if "#{hash['SDTMStage']}" == 'true' 
            ui_editor_select_by_location(1, 13)
            check_cell_content('editor', 1, 13, true)
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['SDTMStage']}" == 'false'
              ui_editor_select_by_location(1, 13)
              ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
              check_cell_content('editor', 1, 13, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end

      else
        if "#{hash['SDTMStage']}" == 'true' 
            ui_editor_select_by_location(1, 13)
            ui_press_key :enter 
              ui_press_key :arrow_right
              wait_for_ajax 10
              ui_press_key :enter
              wait_for_ajax 10
            check_cell_content('editor', 1, 13, true)
            #ui_check_table_cell_icon 'editor', 1, 1, 'sel-filled'
            end
          if "#{hash['SDTMStage']}" == 'false'
              ui_editor_select_by_location(1, 13)
              
              check_cell_content('editor', 1, 13, false)
              #ui_check_table_cell_icon 'editor', 1, 1, 'times-circle'
            end
      end
    end
    end
      save_screen(TYPE)
      wait_for_ajax(20)
end

Then('the latest version of {string} is deleted') do |string|
    ui_table_search("history", "Incomplete")
    ui_check_table_info("history", 0, 0, 0)
    save_screen(TYPE)
    wait_for_ajax(20)
end
