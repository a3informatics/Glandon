#################### When statements 
When('I double click on tag {string} in the tags editor') do |string|
	find_node(string).double_click
      
end

##################### Then statements 

Then('I see Showing Managed Items tagged with the {string} Tag') do |string|
  expect(page).to have_content "Showing Managed Items tagged with the #{string} Tag"
  wait_for_ajax(20)
	  zoom_out
	  save_screen(TYPE)
	  zoom_in 
end

Then('I see {int} entries being tagged') do |int|
	# No items tagged
      ui_in_modal do
		 if int < 10
		    ui_check_table_info("managed-items", 1, int, int)
		  else
		    ui_check_table_info("managed-items", 1, 10, int)
		  end
	  wait_for_ajax(20)
	  zoom_out
	  save_screen(TYPE)
	  zoom_in 
	  click_on 'Close'
		  end     
end