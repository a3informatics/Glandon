#Pre-conditions - Given statements

Given /[dD]ashboard/ do
   expect(page).to have_content 'Changes between two CDISC Terminology versions'
end

Given('the latest version of CDISC has Version Label: {string} and Version Number: {string}') do |string, string2|
  LATEST_VERSION = string2
  LATEST_VERSION_LABEL = string
  LVERSION = string2.split[0].to_i
  end

# When statements 

When /[bB]rowse every version of CDISC CT/ do
 click_browse_every_version
 wait_for_ajax(20)
 end

 When /[bB]rowse latest version/ do
  click_show_latest_version
  wait_for_ajax(20)
end

When('I click Context menu for {string}') do |string|
        row = find("table#history tr", text: string)
        within(row) do
        ui_table_search("history", string)
        find(".icon-context-menu").click
        end
  end


When('I click {string} in context menu for {string} on the History page') do |string, string2|
       ui_table_search("history", string2)
       find(".icon-context-menu").click
       context_menu_element_v3("history", string2, string)
       wait_for_ajax(20)

end

When('I click {string} in the context menu \(on top left corner of the page)') do |string|
      context_menu_element_header_v2 (string)
      
end

When('I enter {string} in the Code lists search area and click {string} to display the {string} code list') do |string, string2, string3|
      ui_child_search(string)
      find(:xpath, "//tr[contains(.,'C66729')]/td/a", :text => string2).click
      wait_for_ajax(20)
end

When('I enter {string} in the Code List Items search area and click {string} to display the {string} code list item') do |string, string2, string3|
      ui_child_search(string)
      find(:xpath, "//tr[contains(.,'C38299')]/td/a", :text => string2).click
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


#Then statements

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

 Then /the Dashbaord is displayed/ do 
  expect(page).to have_content 'Changes between two CDISC Terminology versions'
  wait_for_ajax(20)
  save_screen(TYPE)
end


       