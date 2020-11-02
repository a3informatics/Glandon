
##################### When statements 

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
  # today = Date.today
  # log(today)
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


##################### Then statements 

Then('I see {int} code lists with following synonyms') do |int, table|
  if int < 10
  ui_check_table_info("children_table", 1, int, int)
  else
   ui_check_table_info("children_table", 1, 10, int)
  end
    table.hashes.each do |hash|
    ui_check_table_cell("children_table", hash['No'], 1,"#{hash['CodeList']}")
    ui_check_table_cell("children_table", hash['No'], 4,"#{hash['Synonym']}")
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see {int} code lists with following preferred terms') do |int, table|
  if int < 10
  ui_check_table_info("children_table", 1, int, int)
  else
   ui_check_table_info("children_table", 1, 10, int)
  end
    table.hashes.each do |hash|
    ui_check_table_cell("children_table", hash['No'], 1,"#{hash['CodeList']}")
    ui_check_table_cell("children_table", hash['No'], 3,"#{hash['PreferredTerm']}")
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see {int} code list items with following synonyms') do |int, table|
  if int < 10
  ui_check_table_info("children_table", 1, int, int)
  else
   ui_check_table_info("children_table", 1, 10, int)
  end
    table.hashes.each do |hash|
    ui_check_table_cell("children_table", hash['No'], 1,"#{hash['CodeListItem']}")
    ui_check_table_cell("children_table", hash['No'], 4,"#{hash['Synonym']}")
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see {int} code list items with following preferred terms') do |int, table|
  if int < 10
  ui_check_table_info("children_table", 1, int, int)
  else
   ui_check_table_info("children_table", 1, 10, int)
  end
    table.hashes.each do |hash|
    ui_check_table_cell("children_table", hash['No'], 1,"#{hash['CodeListItem']}")
    ui_check_table_cell("children_table", hash['No'], 3,"#{hash['PreferredTerm']}")
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see {int} code list items') do |int|
if int < 10
  ui_check_table_info("children_table", 1, int, int)
  else
   ui_check_table_info("children_table", 1, 10, int)
  end
   wait_for_ajax(20)
   save_screen(TYPE)
end

Then('I see synonym {string} being shared with {string} codelist for the {string} item') do |string, string2, string3|
  expect(page).to have_content 'Shared Synonyms'
  expect(page).to have_xpath("//div[@id='synonyms-panel']/div/div/div/div", :text => string)
  expect(page).to have_xpath("//div[@id='synonyms-panel']/div/div/div/a/div/div", :text => string2)
  expect(page).to have_xpath("//div[@id='synonyms-panel']/div/div/div/a/div/div", :text => string3)
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see preferred term {string} being shared with {string} codelist for the {string} item') do |string, string2, string3|
  expect(page).to have_content 'Shared Preferred Terms'
  expect(page).to have_xpath("//div[@id='pts-panel']/div/div/div/div", :text => string)
  expect(page).to have_xpath("//div[@id='pts-panel']/div/div/div/a/div/div", :text => string2)
  expect(page).to have_xpath("//div[@id='pts-panel']/div/div/div/a/div/div", :text => string3)
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Code Lists Index page is displayed') do
  expect(page).to have_content "Index: Code Lists"
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see a new code list starting with {string}') do |string|
  expect(page).to have_content string
  expect(page).to have_content 'Not Set'
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see a new code list item') do
  ui_editor_check_value 1, 2, 'Not Set'
  ui_editor_check_value 1, 3, 'Not Set'
  ui_editor_check_value 1, 5, 'Not Set'
  ui_editor_check_value 1, 6, 'None'
  end

Then /I fill in the details for the code list ?(?:\(?(\w+)\)?.*)/ do |string, table|

  table.hashes.each do |hash|
      ui_editor_select_by_location(1,2)
      ui_editor_fill_inline "notation", "#{hash['SV']}\n"
      ui_editor_select_by_location(1,3)
      ui_editor_fill_inline "preferred_term", "#{hash['PT']}\n"
      ui_editor_select_by_location(1,4)
      ui_editor_fill_inline "synonym", "#{hash['SY']}\n"
      ui_editor_check_value 1, 4, "#{hash['SY']}"
      ui_editor_select_by_location(1,5)
      ui_editor_fill_inline "definition", "#{hash['DEF']}\n"
  end
  wait_for_ajax(20)
  save_screen(TYPE)
  end

Then('I see Synonyms is {string}') do |string|
  ui_editor_check_value 1, 4, string
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Preferred Term is {string}') do |string|
  ui_editor_check_value 1, 3, string
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Synonyms is empty') do
  ui_editor_check_value 1, 4, ""
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Preferred Term is empty') do
  ui_editor_check_value 1, 3, ""
  wait_for_ajax(20)
  save_screen(TYPE)
end