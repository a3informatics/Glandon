##################### Pre-conditions - Given statements #####################



##################### When statements #####################

### Navigation bar ###

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
  if string == 'Forms'
    click_navbar_forms
    wait_for_ajax(20)
  end
end

When('I click {string} in/at the top/bottom of the page') do |string|
  if string == 'PDF Report'
		# Ignore. All PDF handling is in the THEN-statement
	  #click_button string
  end
  
  if string =='Start'
    find('#fb_s_button').click 
  end
  if string =='Changes'
   click_link 'Changes'
  end
  wait_for_ajax(20)

end

When('I click History on the index page for {string}') do |string|
   ui_table_search("index", string)
   find(:xpath, "//tr[contains(.,string)]/td/a").click
  end

def check_version_info(*args)
      args.each do |a|
        expect( find('#imh_header') ).to have_content a
      end
end

When('I advance the status to {string}') do |string|
  check_version_info('Incomplete')
  click_on 'Submit Status Change'
  find('#version-label-edit').click
  fill_in 'Version label', with: 'Form Version Label'
  click_on 'Update Version Label'
  find('#version-edit').click
  select 'Major', from: 'select-release'
  click_on 'Update Version'
  click_on 'Submit Status Change'
  click_on 'Submit Status Change'
  click_on 'Submit Status Change'
    check_version_info(string, 'Form Version Label')
end

### Context menu ###

When('I click Context menu for {string}') do |string|
	row = find("table#history tr", text: string)
	within(row) do
	ui_table_search("history", string)
	find(".icon-context-menu").click
	end
	wait_for_ajax(20)
end

When('I click {string} in context menu for {string}') do |string, string2|
  ui_table_search("history", string2)
  find(".icon-context-menu").click
  context_menu_element_v3("history", string2, string)
  wait_for_ajax(20)
 end

 When('I click Edit in context menu for the latest version of the {string} code list') do |string|
  #ui_table_search("history", "Incomplete")
  context_menu_element_v2('history', 1, :edit)
  
    wait_for_ajax(20)
end

When('I click Show in context menu for the latest version of the {string} code list') do |string|
  context_menu_element_v2('history', 1, :show)
    wait_for_ajax(20)
end


When('I click {string} in the confirmation box') do |string|
  ui_confirmation_dialog('string')
end

When('I enter {string} in the search area and click {string} in the context menu') do |string, string2|
  ui_table_search("history", string)
  find(".icon-context-menu").click
  context_menu_element_v3("history", string, string2)
  wait_for_ajax(20)      
end

When('I click {string} in context menu for {string} on the History page') do |string, string2|
	ui_table_search("history", string2)
	find(".icon-context-menu").click
	context_menu_element_v3("history", string2, string)
	wait_for_ajax(20)
end

When('I click {string} in context menu for {string} {string} version on the History page') do |string, string2, string3|
  ui_table_search("history", string3)
  find(".icon-context-menu").click
  context_menu_element_v3("history", string2, string)
  wait_for_ajax(20)
end

When('I enter {string} in the search area and click {string} on the Code List page') do |string, string2|
  ui_child_search(string)
  find(:xpath, "//tr[contains(.,string)]/td/a", :text => string2).click
    wait_for_ajax(20)      
end


When('I click {string} in the context menu \(on top left corner of the page)') do |string|
  context_menu_element_header_v2(string)
end

When('I click {string} at the item {string}') do |string, string2|
  find(:xpath, "//tr[contains(.,'#{string2}')]/td/a", :text => string).click
  wait_for_ajax(20)
end


### Buttons ###
  
When /[cC]lose/ do
  click_button "Close"
 wait_for_ajax(20)
end

When('I click Return') do
  click_link 'Return'
  # click_on 'Return'
  wait_for_ajax(20)
end

When /[hH]ome/ do
 click_link 'Home'
 wait_for_ajax(20)
end

When('I click {string} button') do |string|
  if string == 'New item'
    find('#new-item-button').click
  else
	click_on string
  wait_for_ajax(30)
end
end

When('I click "Submit and proceed/Proceed"') do
  click_button "Submit and proceed"
end


When('I click Changes for the {string}, c-code: {string}') do |string, string2|
  find(:xpath, "//tr[contains(.,'#{string}')]/td/a", :text => "Changes").click
   wait_for_ajax(20)
end

### Tables ###
When('I click first row in table') do
	find(:xpath, "//table[@id='searchTable']/tbody/tr[1]").double_click
end


### Open in new tab and return to pervious tab from changes page ###

When('I access the created {string}, c-code:{string} by right-clicking and open in new tab') do |string, string2|
  if ENVIRONMENT == 'TEST'
  tit = 'Changes: '+string+' ('+string2+') - Glandon MDR'
  else 
  tit = 'Changes: '+string+' ('+string2+') - A3 MDR'
  end

  find("#created_div a", text: string).click(:command, :shift)
  wait_for_ajax(20)

  page.switch_to_window { title == tit }
  wait_for_ajax(20)

 end


When('I access the updated {string}, c-code:{string} by right-clicking and open in new tab') do |string, string2|
  if ENVIRONMENT == 'TEST'
  tit = 'Changes summary: '+string+' ('+string2+') - Glandon MDR'
  else 
  tit = 'Changes summary: '+string+' ('+string2+') - A3 MDR'
  end

  find("#updated_div a", text: string).click(:command, :shift)
  wait_for_ajax(20)
  page.switch_to_window { title == tit }
  wait_for_ajax(20)

end

When('I access the deleted {string}, c-code:{string} by right-clicking and open in new tab') do |string, string2|
  if ENVIRONMENT == 'TEST'
  tit = 'Changes: '+string+' ('+string2+') - Glandon MDR'
  else 
  tit = 'Changes: '+string+' ('+string2+') - A3 MDR'
  end

  find("#deleted_div a", text: string).click(:command, :shift)
  wait_for_ajax(20)
  page.switch_to_window { title == tit}
  wait_for_ajax(20)
end

When('I return on {string} \(previous tab)') do |string|
 
  if ENVIRONMENT == 'TEST'
  page.switch_to_window { title == 'CDISC Terminology Changes - Glandon MDR' }
  else 
  page.switch_to_window { title == string }
  end
   wait_for_ajax(60)

end


##################### Then statements #####################

Then /History page is displayed/ do
	expect_page('Version History of')
	wait_for_ajax(20)
	save_screen(TYPE)
end

Then('I see {int} code lists') do |int|
 ui_check_table_info("children", 1, 10, int)
  if int < 10
    ui_check_table_info("children", 1, int, int)
  else
    ui_check_table_info("children", 1, 10, int)
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('code list item {string} differences is displayed') do |string|
  expect(page).to have_content string
  expect(page).to have_content "Differences"
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see {string} Index page is displayed') do |string|
  expect(page).to have_content "Index: #{string}"
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('the list has {int} entries') do |int|
  if int < 10
    ui_check_table_info('children', 1, int, int)
  else
    ui_check_table_info('children', 1, 10, int)
  end
	wait_for_ajax(20)
	save_screen(TYPE)
end


Then('the form list has {int} entries') do |int|
  if int < 10
    ui_check_table_info('show', 1, int, int)
  else
    ui_check_table_info('show', 1, 10, int)
  end
  wait_for_ajax(20)
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

Then('the {string} has been deleted') do |string|
  expect(page).not_to have_content string
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see the {string} page') do |string|
  expect(page).to have_content string
  wait_for_ajax(20)
  save_screen(TYPE)
end


Then('the status for {string} is {string}') do |string, string2|
 expect(page).to have_content string
   expect(page).to have_content string2
  wait_for_ajax(20)
  save_screen(TYPE)
end


