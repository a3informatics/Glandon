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
end

When('I click {string} in/at the top/bottom of the page') do |string|
  if string == 'PDF Report'
		# Ignore. All PDF handling is in the THEN-statement
	  #click_button string
  end
  
  if string =='Start'
    find('#fb_s_button').click 
  end
  if string =='View Changes'
   click_link 'View Changes'
  end
  wait_for_ajax(20)

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

  row = find("table#history tr", text: string2)
        within(row) do
        ui_table_search("history", string2)
        find(".icon-context-menu").click
          if string.downcase! == 'edit'
            context_menu_element('history', 4, string2, :edit)
          end
          if string.downcase! == 'show'
            context_menu_element('history', 4, string2, :show)
          end
          if string.downcase! == 'search'
            context_menu_element('history', 4, string2, :search)
          end
        end
        wait_for_ajax(20)
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
                
When /[hH]ome/ do
 click_link 'Home'
 wait_for_ajax(20)
end

When('I click Return') do
  click_link 'Return'
  # click_on 'Return'
  wait_for_ajax(20)
end

When('I click {string} button') do |string|
	click_on string
  wait_for_ajax(20)
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
  tit = 'Changes: '+string+' ('+string2+') - A3'
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
  tit = 'Changes summary: '+string+' ('+string2+') - A3'
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
  tit = 'Changes: '+string+' ('+string2+') - A3'
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

Then('code list item {string} differences is displayed') do |string|
  expect_page('Preferred term: EPIC-CP - Pain or Burning With Urination')
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
	ui_check_table_info("children_table", 1, 10, int)
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



