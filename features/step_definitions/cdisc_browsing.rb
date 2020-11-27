
##################### Pre-conditions - Given statements

Given /on Community [dD]ashboard/ do
	expect(page).to have_content 'Changes between two CDISC Terminology versions'
end

Given('the latest version of CDISC has Version Label: {string} and Version Number: {string}') do |string, string2|
	LATEST_VERSION = string2
	LATEST_VERSION_LABEL = string
	LVERSION = string2.split[0].to_i
end

##################### When statements 

When('I click "Browse every version of CDISC CT"') do
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


When('I sort on version {string} in the Changes table') do |string|
  ui_table_sort('changes',string)
  wait_for_ajax(20)
end

When('I select CDISC version {string} and CDISC version {string} by dragging the slides and click Display') do |string, string2|
  ui_dashboard_slider(string,string2)
  click_link 'Display'
  wait_for_ajax(10)
pause
end

##################### Then statements #####################

Then /latest (?:release\s)*version is/ do 
	expect(page).to have_content LATEST_VERSION
	ui_check_table_info("history", 1, 10, LVERSION)
	save_screen(TYPE)
	wait_for_ajax(20)
end
          
Then /the Community Dashboard is displayed/ do
  expect(page).to have_content 'Changes between two CDISC Terminology versions'
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then ('I am on Dashboard') do
  expect(page).to have_content 'Dashboard'
  wait_for_ajax(20)
  save_screen(TYPE)
  end


### Context menu ###

Then('I verify that Show and Search are enabled and all other menus are disabled for {string}') do |string|
  row = find("table#history tr", text: string)
  expect(row).to have_selector(".context-menu .option.disabled", text: "Edit", visible: false)
  expect(row).to have_selector(".context-menu .option.disabled", text: "Delete", visible: false)
  expect(row).to have_selector(".context-menu .option.disabled", text: "Document control", visible: false)
  expect(row).not_to have_selector(".context-menu .option.disabled", text: "Show", visible: false)
  expect(row).not_to have_selector(".context-menu .option.disabled", text: "Search", visible: false)
  save_screen(TYPE)
end


Then('I see Controlled Terminology Changes Across versions displayed') do
  expect(page).to have_content 'Changes'
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Submission value changes displayed') do
  expect(page).to have_content 'Submission value changes'
  expect(page).to have_content 'Submission value changes: CDISC, CT'
  wait_for_ajax(20)
  save_screen(TYPE)
end


Then('I see the differences in the {string} code list is displayed') do |string|
  expect(page).to have_content 'Differences'
  expect(page).to have_content string
  wait_for_ajax(20)
  save_screen(TYPE) 
end

Then('the Differences panel has {int} entries and no updates to Submission Value, Preferred Term, Synonym or Definition') do |int|
  if int < 10
	  ui_check_table_info("differences_table", 1, int, int)
	else
		ui_check_table_info("differences_table", 1, 10, int)
	end
  wait_for_ajax(20)
  save_screen(TYPE)
	#Pending checking          
end

Then('the Changes panel displays {int} entries') do |int|
   find('#main_area').scroll_to find('#changes')
  if int < 10
    ui_check_table_info("changes", 1, int, int)
  else
    ui_check_table_info("changes", 1, 10, int)
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('the Differences panel displays {int} entries') do |int|
  if int < 10
    ui_check_table_info("differences_table", 1, int, int)
  else
    ui_check_table_info("differences_table", 1, 10, int)
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('the {string}, c-code: {string} was created \(+) in version {string} and deleted \(-) in version {string}') do |string, string2, string3, string4|
  ui_table_search('changes', string2)

	pos_cr = page.all(:xpath, "//table[@id='changes']/thead/tr/th[.='#{string3}']/preceding-sibling::*").length+1
  ui_check_table_cell_create('changes',1,pos_cr)
  
	pos_dl = page.all(:xpath, "//table[@id='changes']/thead/tr/th[.='#{string4}']/preceding-sibling::*").length+1
  ui_check_table_cell_delete('changes',1,pos_dl)
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('the code list item {string}, c-code: {string} and {string}, c-code: {string} is displayed as the first two rows') do |string, string2, string3, string4|
  ui_table_search('changes', "")
  ui_check_table_cell('changes', 1, 1, string2)
  ui_check_table_cell('changes', 1, 2, string)
  ui_check_table_cell('changes', 2, 1, string4)
  ui_check_table_cell('changes', 2, 2, string3)
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('the Differences panel is displayed') do
  expect(page).to have_content 'Differences'
  wait_for_ajax(20)
  save_screen(TYPE)
end


Then('I see the Differences and Changes for the {string} code list for CDISC version {string} and CDISC version {string}') do |string, string2, string3|
  
    expect(page).to have_content 'Differences'
    wait_for_ajax(20)
    save_screen(TYPE)
    find('#main_area').scroll_to find('#changes')
    expect(page).to have_content 'Changes'
    expect(page).to have_content string
    #expect(page).to have_content string2
    expect(page).to have_content string3
    wait_for_ajax(20)
    save_screen(TYPE)
         
end

Then('I see that {int} new codes were created {string} in version {string}') do |int, string, string2|
   pos_cr = page.all(:xpath, "//table[@id='changes']/thead/tr/th[.='#{string2}']/preceding-sibling::*").length+1
   i = 1
   if i < int+1
     ui_check_table_cell_create('changes',i,pos_cr)
     i = i+1
   else
    ui_check_table_cell_create('changes',int+1,pos_cr, false)
   end

   wait_for_ajax(20)
   save_screen(TYPE)
end

Then('I see that code list and code list items are maked deleted {string} in version {string}') do |string, string2|
  pos_cr = page.all(:xpath, "//table[@id='changes']/thead/tr/th[.='#{string2}']/preceding-sibling::*").length+1
  ui_check_table_cell_delete('changes',1,pos_cr)
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('a PDF report is generated and contains the {int} entires in the Changes panel') do |int|
  new_window = window_opened_by { click_link 'PDF Report' }
  within_window new_window do
    sleep 10
    expect(current_path).to include("changes_report.pdf")
    expect(current_path).to include("thesauri/managed_concepts")
       
    save_screen(TYPE)
    # var x = document.getElementsByTagName('embed')[0]
    # x.src = "url/to/your.pdf?page=page_number"
    page.execute_script "window.close();"
    end
 
end

Then('a PDF report is generated and contains the {int} entries in the Submission value changes panel') do |int|
  new_window = window_opened_by { page.find("#report").find(:xpath, '..').click }
  within_window new_window do
    sleep 10
    expect(current_path).to include("submission_report.pdf")
    expect(current_path).to include("thesauri/")
    save_screen(TYPE)
    page.execute_script "window.close();"
  end
 end

Then('all search terminology fields are cleared') do
	expect(find('#overall_search').value).to eq ''
	expect(find('#searchTable_csearch_parent_identifier').value).to eq ''
	expect(find('#searchTable_csearch_parent_label').value).to eq ''
	expect(find('#searchTable_csearch_identifier').value).to eq ''
	expect(find('#searchTable_csearch_notation').value).to eq ''
	expect(find('#searchTable_csearch_preferred_term').value).to eq ''
	expect(find('#searchTable_csearch_synonym').value).to eq ''
	expect(find('#searchTable_csearch_definition').value).to eq ''
	expect(find('#searchTable_csearch_tags').value).to eq ''
	save_screen(TYPE)
end

Then('all search terminology fields are cleared except code list which contains {string}') do |string|
	expect(find('#overall_search').value).to eq ''
	expect(find('#searchTable_csearch_parent_identifier').value).to eq string
	expect(find('#searchTable_csearch_parent_label').value).to eq ''
	expect(find('#searchTable_csearch_identifier').value).to eq ''
	expect(find('#searchTable_csearch_notation').value).to eq ''
	expect(find('#searchTable_csearch_preferred_term').value).to eq ''
	expect(find('#searchTable_csearch_synonym').value).to eq ''
	expect(find('#searchTable_csearch_definition').value).to eq ''
	expect(find('#searchTable_csearch_tags').value).to eq ''
  save_screen(TYPE)
end
