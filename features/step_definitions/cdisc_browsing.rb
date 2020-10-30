Then('I see Code Lists Index page is displayed') do
  expect(page).to have_content "Index: Code Lists"
  save_screen(TYPE)
end

When('I click {string} button') do |string|
  if string.include? 'New Item'
    click_link 'New Item'
    #click_button ui_button_label(new-item-button, "New Item") 
  end
  if string.include? 'New Code List'
    click_link 'New Code List'
    #click_button ui_button_label(tnb_new_button, "New Code List")  
    pause
  end
  wait_for_ajax(20)
end

Then('I see a new code lists: {string}') do |string|
  expect(page).to have_content string
  save_screen(TYPE)
end

Then('I see a new code list item {string}') do |string|
  expect(page).to have_content string
end

Then /I fill in the details for the code list ?(?:\(?(\w+)\)?.*)/ do |table|
  table.hashes.each do |hash|
    ui_check_table_cell("children_table", hash['No'], 1,"#{hash['CodeListItem']}")
    ui_check_table_cell("children_table", hash['No'], 4,"#{hash['Synonym']}")
    ui_editor_select_by_location(1,2)
      ui_editor_fill_inline "notation", "#{hash['SV']}\n"
      ui_editor_select_by_location(1,3)
      ui_editor_fill_inline "preferred_term", "#{hash['PT']}\n"
      ui_editor_select_by_location(1,4)
      ui_editor_fill_inline "synonym", "#{hash['SY']}\n"
      expect(page).to have_content "#{hash['SY']}"
      ui_editor_select_by_location(1,5)
      ui_editor_fill_inline "definition", "#{hash['DEF']}\n"
  end
end

When('I update Synonyms to {string}') do |string|
   ui_editor_fill_inline "synonym", "#{string}\n"
   wait_for_ajax(20)
end

Then('I see Synonyms is {string}') do |string|
 # expect(page).to have_content "#{string}"
  ui_check_table_cell("children_table", 1, 3,string)
  save_screen(TYPE)
end

When('I delete Synonym {string}') do |string|
  ui_editor_fill_inline "synonym", "\n"
  wait_for_ajax(20)
end

Then('I see Synonyms is empty') do
  ui_check_table_cell("children_table", 1, 3,"\n")
  save_screen(TYPE)
end




















##################### Pre-conditions - Given statements

Given /[dD]ashboard/ do
   expect(page).to have_content 'Changes between two CDISC Terminology versions'
end

Given('the latest version of CDISC has Version Label: {string} and Version Number: {string}') do |string, string2|
  LATEST_VERSION = string2
  LATEST_VERSION_LABEL = string
  LVERSION = string2.split[0].to_i
  end

##################### When statements 

When /[bB]rowse every version of CDISC CT/ do
 click_browse_every_version
 wait_for_ajax(20)
 end

 When /[bB]rowse latest version/ do
  click_show_latest_version
  wait_for_ajax(20)
end

When /[Ss]ee the changes across versions/ do
 click_see_changes_all_versions
 wait_for_ajax(20)
end

When('I click Context menu for {string}') do |string|
        row = find("table#history tr", text: string)
        within(row) do
        ui_table_search("history", string)
        find(".icon-context-menu").click
        end
        wait_for_ajax(20)
  end


When('I click {string} in context menu for {string} on the History page') do |string, string2|
       ui_table_search("history", string2)
       find(".icon-context-menu").click
       context_menu_element_v3("history", string2, string)
       wait_for_ajax(20)

end

When('I click {string} in the context menu \(on top left corner of the page)') do |string|
      context_menu_element_header_v2(string)
end


When(/^I click {string} in the top of the page/) do |string|
  click_button fb_s_button
  wait_for_ajax(20)
 end

When('I enter {string} in the Code lists search area and click {string} to display the {string} code list') do |string, string2, string3|
      ui_child_search(string)
      find(:xpath, "//tr[contains(.,'#{string}')]/td/a", :text => string2).click
      wait_for_ajax(20)
end

When('I enter {string} in the Code List Items search area and click {string} to display the {string} code list item') do |string, string2, string3|
      ui_child_search(string)
      find(:xpath, "//tr[contains(.,'#{string}')]/td/a", :text => string2).click
      wait_for_ajax(20)
end

When('I enter {string} in the search area click {string} to display the {string} code list') do |string, string2, string3|
  ui_table_search("changes", string)
  find(:xpath, "//tr[contains(.,'#{string2}')]/td/a", :text => string2).click
  wait_for_ajax(20)
end

When('I sort on version {string} in the Difference table') do |string|
  ui_table_sort(Difference,string)
  wait_for_ajax(20)
end

When('I click Changes for the {string}, c-code: {string}') do |string, string2|
   ui_table_row_click(string, 'Changes')
   wait_for_ajax(20)
end

When('I access the created {string}, c-code:{string} by right-clicking and open in new tab') do |string, string2|
  new_window = window_opened_by {click_link find(:xpath, "//div[@id='created_div']/a", :text => string) } 
  switch_to_window new_window
  wait_for_ajax(20)    
end

When('I access the updated {string}, c-code:{string} by right-clicking and open in new tab') do |string, string2|
  new_window = window_opened_by {click_link find(:xpath, "//div[@id='updated_div']/a", :text => string) }
  switch_to_window new_window    
end

When('I access the deleted {string}, c-code:{string} by right-clicking and open in new tab') do |string, string2|
  new_window = window_opened_by { click_link find(:xpath, "//div[@id='deleted_div']/a", :text => string) }
  switch_to_window new_window 
  wait_for_ajax(20) 
  end

When('I click {string} at the item {string}') do |string, string2|
    find(:xpath, "//tr[contains(.,'#{string2}')]/td/a", :text => string).click
    wait_for_ajax(20)
end

When('I return on Dashbaord \(previous tab)') do
  switch_to_window "CDISC Terminology Changes - A3"
  wait_for_ajax(20)
end
  
  When /[cC]lose/ do
  click_button "Close"
  wait_for_ajax(20)
end
                
When /[hH]ome/ do
 click_link 'Home'
 wait_for_ajax(20)
end

When('I click Return') do
  click_link 'Return'
  wait_for_ajax(20)
end

When('I select CDISC version {string} and CDISC version {string} by dragging the slides and click Display') do |string, string2|
      ui_dashboard_slider(string,string2)
      click_link 'Display'
      wait_for_ajax(10)
end

When('I access the {string} in the navigation bar') do |string|
  if string == 'CDISC Terminology'
  click_navbar_cdisc_terminology
  wait_for_ajax(20)
  end
  if string == 'Code Lists'
  click_navbar_code_lists
  wait_for_ajax(20)
  end
  if string == 'Terminology'
  click_navbar_terminology
  wait_for_ajax(20)
  end
  if string == 'Biomedical Concepts'
  click_navbar_bc
  wait_for_ajax(20)
  end
end

When('I enter {string} in the search area') do |string|
         ui_child_search(string)
end



##################### Then statements

Then('I verify that Show and Search are enabled and all other menus are disabled for {string}') do |string|
        row = find("table#history tr", text: string)
        expect(row).to have_selector(".context-menu .option.disabled", text: "Edit", visible: false)
        expect(row).to have_selector(".context-menu .option.disabled", text: "Delete", visible: false)
        expect(row).to have_selector(".context-menu .option.disabled", text: "Document control", visible: false)
        expect(row).not_to have_selector(".context-menu .option.disabled", text: "Show", visible: false)
        expect(row).not_to have_selector(".context-menu .option.disabled", text: "Search", visible: false)
        save_screen(TYPE)
        end

Then /latest (?:release\s)*version is/ do 
 expect(page).to have_content LATEST_VERSION
 ui_check_table_info("history", 1, 10, LVERSION)
 save_screen(TYPE)
  wait_for_ajax(20)
end

Then /History page is displayed/ do
 expect_page('Version History of')
 wait_for_ajax(20)
 save_screen(TYPE)
end

Then('I see the list of code lists for the {string}') do |string|
  expect(page).to have_content string
  save_screen(TYPE)
  wait_for_ajax(20)
end


Then('I see the list of code lists included in the latest release version as specified in pre-condition') do
  expect(page).to have_content LATEST_VERSION_LABEL
  save_screen(TYPE)
  wait_for_ajax(20)
end

Then('the release has {int} entries\/code lists') do |int|
  ui_check_table_info("children_table", 1, 10, int)
  wait_for_ajax(20)
  save_screen(TYPE)
end


Then('I see the items in the {string} code list is displayed') do |string|
       expect(page).to have_content string
       wait_for_ajax(20)
       save_screen(TYPE)
end

Then('the list has {int} entries') do |int|
 ui_check_table_info("children_table", 1, 10, int)
 wait_for_ajax(20)
 save_screen(TYPE)
end


Then('I see the {string} code list item') do |string|
  expect(page).to have_selector("#pts-panel .card-content", text: string)
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see that the shared Preferred terms are displayed as {string} and {string}') do |string, string2|
      expect(page).to have_selector("#pts-panel .card-content", text: string)
      expect(page).to have_selector("#pts-panel .card-content", text: string2)
      save_screen(TYPE)
end

Then('I see that the shared Synonyms are displayed as {string} and {string}') do |string, string2|
      expect(page).to have_selector("#synonyms-panel .card-content", text: string)
      expect(page).to have_selector("#synonyms-panel .card-content", text: string2)
      save_screen(TYPE)
end


Then('I see that {string}') do |string|
  expect(page).to have_content string
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('that it is not possible to add any {string}') do |string|
  expect(page).not_to have_content string
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Controlled Terminology Changes Across versions displayed') do
  expect(page).to have_content 'Changes'
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see the differences in the {string} code list is displayed') do |string|
      expect(page).to have_content 'Differences'
      expect(page).to have_content string
      wait_for_ajax(20)
      save_screen(TYPE) 
end

Then('the changes to the {string} code list items') do |string|
      expect(page).to have_content 'Changes'
      expect(page).to have_content string
      wait_for_ajax(20)
      save_screen(TYPE) 
end

Then('the Differences panel has {int} entries and no updates to Submission Value, Preferred Term, Synonym or Definition') do |int|
      ui_check_table_info("differences_table", 1, 10, int)
      wait_for_ajax(20)
      save_screen(TYPE)
 #Pending checking          
end

Then('the Changes panel displays {int} entries') do |int|
    ui_check_table_info("changes", 1, 10, int)
      wait_for_ajax(20)
      save_screen(TYPE)
end

Then('the {string}, c-code: {string} was created (+) in version {string} and deleted (-) in version {string}') do |string, string2, string3, string4|
  ui_table_search("changes",string2)
  ui_check_table_cell_create("changes",1,string3)
  ui_check_table_cell_delete("changes",1,string4)
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('the code list item {string}, c-code: {string} and {string}, c-code: {string} is displayed as the first two rows') do |string, string2, string3, string4|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('a PDF report is generated and contains the {int} entires in the Changes panel') do |int|
# Then('a PDF report is generated and contains the {float} entires in the Changes panel') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the Differences panel is displayed') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('{int} changes are displayed') do |int|
# Then('{float} changes are displayed') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end


Then('I see {int} code lists created, {int} code lists updated, {int} code list deleted') do |int, int2, int3|
  expect(page).to have_content 'Created Code List'
  expect(page).to have_content int
  expect(page).to have_content 'Updated Code List'
  expect(page).to have_content int2
  expect(page).to have_content 'Deleted Code List'
  expect(page).to have_content int3
  wait_for_ajax(20)
  save_screen(TYPE)
end


Then('I see the Differences and Changes for the {string} code list for CDISC version {string} and CDISC version {string}') do |string, string2, string3|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('I see that {int} new codes were created {string} in version {string}') do |int, string, string2|
# Then('I see that {float} new codes were created {string} in version {string}') do |float, string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('I see that code list and code list items are maked deleted {string} in version {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('a PDF report is generated and contains the {int} entires in the Changes panel') do |int|
  new_window = window_opened_by { click_link 'PDF Report' }
  within_window new_window do
    sleep 10
    expect(current_path).to include("changes_report.pdf")
    expect(current_path).to include("thesauri/managed_concepts")
    wait_for_ajax(20)
    save_screen(TYPE)
    page.execute_script "window.close();"
  end
end

 Then /the Dashbaord is displayed/ do 
  expect(page).to have_content 'Changes between two CDISC Terminology versions'
  wait_for_ajax(20)
  save_screen(TYPE)
end


Then('I see {int} code lists with following synonyms') do |int, table|
  if int < 10
  ui_check_table_info("children_table", 1, int, int)
  else
   ui_check_table_info("children_table", 1, 10, int)
  end
    table.hashes.each do |hash|
    ui_check_table_cell("children_table", hash['No'], 1,"#{hash['CodeList']}")
    ui_check_table_cell("children_table", hash['No'], 3,"#{hash['Synonym']}")
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
       