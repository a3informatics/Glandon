 def import_select_files(names)
    names.each do |name|
      find(:xpath, "//select[@id='imports_files_']/option[contains(.,'#{name}')]").click(:shift)
    end
  end

##################### Pre-conditions - Given statements #####################
 Given('File {string} has been uploaded') do |string|
 	section = id_to_section_map('main_nav_u')
    # Expand sidebar if collapsed
    ui_navbar_toggle if ui_navbar_collapsed?
    ui_expand_section(section) if !ui_section_expanded?(section)
    click_link 'main_nav_u'
	 #click_navbar_terminology
	 wait_for_ajax(20)
     expect(page).to have_text string
 end
##################### When statements #####################

When('I select {string} to import') do |string|
	import_select_files [string]
end

When('I slide auto load to green') do
	find(".material-switch").click
	wait_for_ajax 10
end


##################### Then statements #####################

Then('I see file being imported successfully') do
	sleep 12.0
	expect_page "Import of New Sponsor Code List(s) from Excel. Identifier: CT, Owner: S-cubed"
	expect_page "No errors were detected with the import."
	wait_for_ajax 10
	zoom_out
	save_screen(TYPE)
	zoom_in 
end