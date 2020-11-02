
Given('Terminology version {string} is set to current') do |string|
     click_navbar_cdisc_terminology
      wait_for_ajax(30)
      context_menu_element("history", 1, string, :make_current)
      wait_for_ajax(10)
      ui_check_table_row_indicators("history", 3, 8, ["Current version"], new_style: true)
end


#################### When statements 


When ('I enable "Select all current"') do 
 page.find("#select-all-current").click 
end


When ('I enter {string} in the Code List') do |string|
   ui_term_column_search(:code_list, string)
end

When ('I enter {string} in the Definition') do |string|
  ui_term_column_search(:definition, string)
end


##################### Then statements 


Then('I see the "Select Terminology" selector window') do 
  expect(page).to have_content("Select Terminology")
end


Then('I see the "Search current" page') do 
  expect(page).to have_content("Search Current")
end


Then('I see {int} search results') do |int|
  if int == 0 
 ui_check_table_info("searchTable", 0, 0, 0)
  end
  if int < 10
  ui_check_table_info("searchTable", 1, int, int)
  end
  if int == 10
    ui_check_table_info("searchTable", 1, 10, int)
  end
end
