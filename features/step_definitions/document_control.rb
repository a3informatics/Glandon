
#################### When statements 
When('I tick With dependencies') do
	dc_click_with_dependencies
end

When('I click on {string} in the Document control') do |string|
	click_on string
end

When('I click on Confirm and Proceed') do
	click_on 'Confirm and proceed'
	end

##################### Then statements #####################

Then('I see the document control for the {string} code list')	do |string|
   expect(page).to have_content "Document Control"
   expect(page).to have_content string
   save_screen(TYPE)
end

Then('the code list is in {string} state') do |string|
	 dc_check_status(string)
   save_screen(TYPE)
end

Then ('the modal Confirm Status Change with Dependencies is displayed with {int} items in {string} state') do |int,string|
        ui_in_modal do
        ui_check_table_info('managed-items', 1, int, int)
        for i in 1..int
          ui_check_table_cell('managed-items', i, 3, '1.0.0')
          ui_check_table_cell('managed-items', i, 7, string)
        end
        expect( find('#managed-items') ).to have_selector('.icon-sel-filled', count: int)
        save_screen(TYPE)
       end
 end

Then('I see message Changed Status of {int} items to {string}') do |int, string|
 wait_for_ajax 10 
      expect(page).to have_content "Changed Status of #{int} items to #{string}"
      save_screen(TYPE)
end

Then('I see message Changed Status to {string}') do |string|
 wait_for_ajax 10 
      expect(page).to have_content "Changed Status to #{string}"
      save_screen(TYPE)
end


Then('the state is {string} on the History page for {string}') do |string,string2|
    ui_check_table_cell('history', 1, 4, string2)
	  ui_check_table_cell('history', 1, 7, string)
    ui_check_table_cell('history', 1, 1, '1.0.0')
    save_screen(TYPE)
	end

