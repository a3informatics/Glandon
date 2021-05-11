
##################### When statements #####################

When('I access the History page of the terminology {string}') do |string|
	section = id_to_section_map('main_nav_te')
    # Expand sidebar if collapsed
    ui_navbar_toggle if ui_navbar_collapsed?
    ui_expand_section(section) if !ui_section_expanded?(section)
    click_link 'main_nav_te'
	ui_table_search("index", string)
    find(:xpath, "//tr[contains(.,string)]/td/a").click
end

When('I select version {string} in the picker') do |string|
	ui_in_modal do
    ui_dashboard_single_slider string
	wait_for_ajax 20
    end
end

When('I click {string} in the picker') do |string|
	click_button string
	 wait_for_ajax 20
end

When('I click on the {string} from the impacted list') do |string|
	find(:xpath, "//table[@id='changes-cdisc-table']//tr[contains(.,'#{string}')]").click
 end

When('I click on the Change Details tab') do
 find(:xpath, "//*[@id='tab-changes']/div").click
end

When('I click on the CSV Report') do
	  click_link "CSV"     
end


##################### Then statements #####################
Then('I see the CDISC version picker') do
	expect(page).to have_content 'Pick a version of the CDISC CT'
	wait_for_ajax(50)
	save_screen(TYPE)
end

Then('I see Impact Analysis for {string}') do |string|
	expect(page).to have_content 'Impact Analysis '+string
	wait_for_ajax(20)
	save_screen(TYPE)

end

Then('I see the list of Changed CDISC Terms') do
	expect(page).to have_content 'Changed CDISC Terms'
	wait_for_ajax(20)
	save_screen(TYPE)
end

Then('I see {int} CDISC code lists being impacted from the terminology') do |int|
  expect(page).to have_content 'Items affected by the CDISC Code List change'
  if int < 10
	  ui_check_table_info("changes-cdisc-table", 1, int, int)
	else
		ui_check_table_info("changes-cdisc-table", 1, 10, int)
	end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Terminology/Subset/Extension {string} impacted') do |string|
	 expect(page).to have_content string
	 wait_for_ajax(20)
	 save_screen(TYPE)
end

Then('I see the Differences summary and the Changes summary for versions {string} and {string}') do |string1, string2|
      expect(page).to have_content 'Differences summary'
      expect(page).to have_content 'Changes summary'
      expect(page).to have_content string1
      expect(page).to have_content string2
      wait_for_ajax(20)
	  save_screen(TYPE)     
end
