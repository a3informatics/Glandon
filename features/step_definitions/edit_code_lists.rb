##################### When statements #####################

When('I update Synonyms to {string}') do |string|
  ui_editor_select_by_location(1,4)
   ui_editor_fill_inline "synonym", "#{string}\n"
   wait_for_ajax(20)
end

When('I delete Synonym {string}') do |string|
  ui_editor_select_by_location(1,4)
  ui_editor_fill_inline "synonym", "\n"
  wait_for_ajax(20)
end
When('I update Preferred Term to {string}') do |string|
  ui_editor_select_by_location(1,3)
   ui_editor_fill_inline 'preferred_term', "#{string}\n"
   wait_for_ajax(20)
end

When('I delete Preferred Term {string}') do |string|
  ui_editor_select_by_location(1,3)
  ui_editor_fill_inline 'preferred_term', "\n"
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

