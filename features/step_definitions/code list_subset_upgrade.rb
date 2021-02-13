##################### When statements 

When('I click Subsets in the context menu') do
  context_menu_element_header(:subsets)
end

When('I click Upgrade in the context menu') do
  context_menu_element_header(:upgrade)
end

When('click Yes in the modal') do
  ui_in_modal do
        click_on "Yes"
      end
end


##################### Then statements #####################
Then('I see the subset {string} being linked to the master code list') do |string|
  ui_in_modal do
        ui_check_table_info 'subsets-index-table', 1, 1, 1
        ui_check_table_cell("subsets-index-table", 1, 2, string)
        save_screen(TYPE)
        wait_for_ajax(20)
        end
end

Then('no subsets are linked to the new versin of themaster code list') do
   ui_in_modal do
        ui_check_table_info 'subsets-index-table', 0, 0, 0
        save_screen(TYPE)
        wait_for_ajax(20)
        end
end

Then('the Source Code List dislpays {int} itmes') do |int| 
  ui_check_table_info 'source-table', 1, int, int
  expect(page).to have_content "Source Code List"
  save_screen(TYPE)
  wait_for_ajax(20)
end
