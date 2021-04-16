##################### When statements 

When('I click Change notes in the context menu for the code list') do
	context_menu_element_header(:change_notes)
	sleep 1
end

When('I fill in the change note') do |table|
	table.hashes.each do |hash|
	page.find("#cn-new-ref").click
    sleep 0.2
    page.find("#cn-new-ref").set(hash['REF'])
    page.find("#cn-new-text").click
    sleep 0.2
    page.find("#cn-new-text").set(hash['DESCR'])
	end
end

When('I click Save to save the change note') do
	page.find("#save-cn-new-button").click
    wait_for_ajax(20)
end

When('I click Delete to delete the change note') do
	page.find("#del-cn-0-button").click
	end

##################### Then statements #####################

Then('I see the Change notes modal') do
	expect(page).to have_content("Change notes for")
	wait_for_ajax(20)
	save_screen(TYPE)
end

Then('I see a new empty change note being added') do
	expect(page).to have_css ("#cn-new")
	wait_for_ajax(20)
	save_screen(TYPE)
end

Then('I see a new change note saved by {string} at today\'s date') do |string|
	expect(page.find("#cn-0-email").text).to eq(string)
	expect(page.find("#cn-0-date").text).to have_content(Date.today.strftime("%d/%m/%Y"))
    expect(page).to have_css(".note", count: 1)
    wait_for_ajax(20)
	save_screen(TYPE)
	end


Then('I see no change notes') do
	expect(page).to have_css(".note", count: 0)
	wait_for_ajax(20)
	save_screen(TYPE)
end