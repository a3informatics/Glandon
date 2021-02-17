##################### Pre-conditions - Given statements
Given('the Sanofi terminology {string} has been loaded and owner is Sanofi') do |string|
    click_navbar_terminology
    wait_for_ajax(20)
    expect(page).to have_content 'Index: Terminology'
    expect(page).to have_content string
    expect(page).to have_content 'Sanofi'
end

##################### Then statements #####################

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

Then('I see the list of code lists for the {string}') do |string|
  expect(page).to have_content string
  expect(page).to have_content 'Code Lists'
  save_screen(TYPE)
  wait_for_ajax(20)
end

Then('I see code list {string} is displayed') do |string|
  expect(page).to have_content string
  save_screen(TYPE)
  wait_for_ajax(20)  
  end

Then('I see that the code list {string} is not extensible') do |string|
  ui_child_search(string)
  ui_check_table_cell_extensible('children', 1, 5, false)
  save_screen(TYPE)
  wait_for_ajax(20) 
end

Then('I see that the code list {string} is extensible') do |string|
  ui_child_search(string)
  ui_check_table_cell_extensible('children', 1, 5, true)
  save_screen(TYPE)
  wait_for_ajax(20) 
end

Then('I see the list of code lists included in the latest release version as specified in pre-condition') do
  expect(page).to have_content LATEST_VERSION_LABEL
  save_screen(TYPE)
  wait_for_ajax(20)
end

Then('the release has {int} entries\/code lists') do |int|
  ui_check_table_info("children", 1, 10, int)
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see the items in the {string} code list is displayed') do |string|
       expect(page).to have_content string
       wait_for_ajax(20)
       save_screen(TYPE)
end

Then('I see the items in the {string} form displayed') do |string|
       expect(page).to have_content string
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

Then('the changes to the {string} code list items') do |string|
      find('#main_area').scroll_to find('#changes')
      expect(page).to have_content 'Changes'
      expect(page).to have_content string
      wait_for_ajax(20)
      save_screen(TYPE) 
end

Then('I see {int} code lists with following synonyms') do |int, table|
  if int < 10
  ui_check_table_info("children", 1, int, int)
  else
   ui_check_table_info("children", 1, 10, int)
  end
    table.hashes.each do |hash|
    ui_check_table_cell("children", hash['No'], 1,"#{hash['CodeList']}")
    ui_check_table_cell("children", hash['No'], 4,"#{hash['Synonym']}")
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see {int} code lists with following preferred terms') do |int, table|
  if int < 10
  ui_check_table_info("children", 1, int, int)
  else
   ui_check_table_info("children", 1, 10, int)
  end
    table.hashes.each do |hash|
    ui_check_table_cell("children", hash['No'], 1,"#{hash['CodeList']}")
    ui_check_table_cell("children", hash['No'], 3,"#{hash['PreferredTerm']}")
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see {int} code list items with following synonyms') do |int, table|
  if int < 10
  ui_check_table_info("children", 1, int, int)
  else
   ui_check_table_info("children", 1, 10, int)
  end
    table.hashes.each do |hash|
    ui_check_table_cell("children", hash['No'], 1,"#{hash['CodeListItem']}")
    ui_check_table_cell("children", hash['No'], 4,"#{hash['Synonym']}")
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see {int} code list items with following preferred terms') do |int, table|
  if int < 10
  ui_check_table_info("children", 1, int, int)
  else
   ui_check_table_info("children", 1, 10, int)
  end
    table.hashes.each do |hash|
    ui_check_table_cell("children", hash['No'], 1,"#{hash['CodeListItem']}")
    ui_check_table_cell("children", hash['No'], 3,"#{hash['PreferredTerm']}")
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see {int} code list items') do |int|
if int < 10
  ui_check_table_info("children", 1, int, int)
  else
   ui_check_table_info("children", 1, 10, int)
  end
   wait_for_ajax(20)
   save_screen(TYPE)
end

Then('I see {int} code list items in the editor') do |int|
    if int < 10
      ui_check_table_info "editor", 1, int, int
    else
      ui_check_table_info "editor", 1, 10, int
    end
   wait_for_ajax(20)
   save_screen(TYPE)
end

Then('there are {string} entries displayed in the table') do |string,table|
  expect(page).to have_content string+" entries"
	table.hashes.each do |it|
	  expect(page).to have_content it['item']
	end
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

Then('I see preferred term {string} being shared with {string} codelist for the {string} item') do |string, string2, string3|
  expect(page).to have_content 'Shared Preferred Terms'
  expect(page).to have_xpath("//div[@id='pts-panel']/div/div/div/div", :text => string)
  expect(page).to have_xpath("//div[@id='pts-panel']/div/div/div/a/div/div", :text => string2)
  expect(page).to have_xpath("//div[@id='pts-panel']/div/div/div/a/div/div", :text => string3)
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Code Lists Index page is displayed') do
  expect(page).to have_content "Index: Code Lists"
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see the Search Terminology page displayed for release {string} version {string}') do |string,string2|
  expect(page).to have_content "Search Terminology"
  expect(page).to have_content string
  expect(page).to have_content string2
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see a new code list starting with {string}') do |string|
  expect(page).to have_content string
  expect(page).to have_content 'Not Set'
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see a new code list item') do
  ui_table_search('editor', 'Not Set')
 pause
  ui_press_key :enter
  ui_editor_check_value 1, 2, 'Not Set'
  ui_editor_check_value 1, 3, 'Not Set'
  ui_editor_check_value 1, 5, 'Not Set'
  ui_editor_check_value 1, 6, 'None'
  save_screen(TYPE)
  wait_for_ajax(20) 
  end

Then /I fill in the details for the code list ?(?:\(?(\w+)\)?.*)/ do |string, table|
  table.hashes.each do |hash|
      ui_editor_select_by_location(1,2)
      ui_editor_fill_inline "notation", "#{hash['SV']}\n"
      ui_editor_select_by_location(1,3)
      ui_editor_fill_inline "preferred_term", "#{hash['PT']}\n"
      ui_editor_select_by_location(1,4)
      ui_editor_fill_inline "synonym", "#{hash['SY']}\n"
      ui_editor_check_value 1, 4, "#{hash['SY']}"
      ui_editor_select_by_location(1,5)
      ui_editor_fill_inline "definition", "#{hash['DEF']}\n"
  end
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Synonyms is {string}') do |string|
  ui_editor_check_value 1, 4, string
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Preferred Term is {string}') do |string|
  ui_editor_check_value 1, 3, string
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Display Order is {string}') do |string|
  ui_editor_check_value 1, 8, string
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Sponsor Synonym is {string}') do |string|
  ui_editor_check_value 1, 9, string
  wait_for_ajax(20)
  save_screen(TYPE)
end


Then('I see Synonyms is empty') do
  ui_editor_check_value 1, 4, ""
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see Preferred Term is empty') do
  ui_editor_check_value 1, 3, ""
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('the following types of attributes for the code list is displayed:') do |table|
  table.hashes.each do |hash|
    check_table_headers('editor', [hash])
    end
    wait_for_ajax(20)
    save_screen(TYPE)
  end

  def check_table_headers(table, headers)
    theaders = all(:xpath, "//div[@id='#{ table }_wrapper']//thead/tr/td", visible: false)

    theaders.each do |th|
      puts th.text
      expect(headers).to include(th.text)
    end
  end

 
  def check_cell_content(table, row, col, data, icon = false)
    cell = find(:xpath, "//table[@id='#{ table }']//tbody/tr[#{ row }]/td[ #{ col }]", visible: false)

    if data.is_a? String
      expect(cell).to have_content data
    else
      expect(cell).to have_selector(data ? ".icon-sel-filled" : ".icon-times-circle")
    end
  end

 Then('I see the following attributes for {string}:') do |string,table|
    ui_table_search('editor',string)

     table.hashes.each do |hash|
      check_cell_content('editor', 1, 1, "#{hash['Identifier']}")
      check_cell_content('editor', 1, 2, "#{hash['SubmissionValue']}")
      check_cell_content('editor', 1, 3, "#{hash['PreferredTerm']}")
      check_cell_content('editor', 1, 4, "#{hash['Synonyms']}") 
      check_cell_content('editor', 1, 5, "#{hash['Definition']}")
      check_cell_content('editor', 1, 6, "#{hash['Tags']}")
      check_cell_content('editor', 1, 7, "#{hash['CRFDisplayValue']}")
      check_cell_content('editor', 1, 8, "#{hash['DisplayOrder']}") # CRF Display Value
      check_cell_content('editor', 1, 9, "#{hash['SynonymSponsor']}")

      if hash['ADaMStage'] == 'false'  # Adam stage
         check_cell_content('editor', 1, 10, false)  # Adam stage
      else 
         check_cell_content('editor', 1, 10, true)
      end
      if hash['DCStage'] == 'false'
         check_cell_content('editor', 1, 11, false) # DC stage
      else
         check_cell_content('editor', 1, 11, true) # DC stage
      end
      if hash['EDUse'] == 'false'
         check_cell_content('editor', 1, 12, false) # ED Use
      else
         check_cell_content('editor', 1, 12, true) # ED Use
      end
      if hash['SDTMStage'] == 'false'
         check_cell_content('editor', 1, 13, false) # SDTM stage
      else
         check_cell_content('editor', 1, 13, true) # SDTM stage
      end
    end
    wait_for_ajax(20)
    save_screen(TYPE)
end
      
Then('I see the following attributes for {string} of 2019 Release 1:') do |string,table|
 ui_table_search('children',string)
     table.hashes.each do |hash|
    if ENVIRONMENT == 'PROD'
      check_cell_content('children', 1, 1, "#{hash['Identifier']}")
      check_cell_content('children', 1, 2, "#{hash['SubmissionValue']}")
      check_cell_content('children', 1, 3, "#{hash['PreferredTerm']}")
      check_cell_content('children', 1, 4, "#{hash['Synonyms']}")
      check_cell_content('children', 1, 5, "#{hash['Definition']}")
      check_cell_content('children', 1, 6, "#{hash['Tags']}")
      check_cell_content('children', 1, 7, "#{hash['CRFDisplayValue']}")# CRF Display Value
      check_cell_content('children', 1, 8, "#{hash['DisplayOrder']}")
      check_cell_content('children', 1, 9, "#{hash['SynonymSponsor']}") # Sponsor synonym
      
      if hash['ADaMStage'] == 'false'  # Adam stage
         check_cell_content('children', 1, 10, false)  # Adam stage
      else 
         check_cell_content('children', 1, 10, true)
      end
      if hash['DCStage'] == 'false'
         check_cell_content('children', 1, 11, false) # DC stage
      else
         check_cell_content('children', 1, 11, true) # DC stage
      end
      if hash['SDTMStage'] == 'false'
         check_cell_content('children', 1, 13, false) # SDTM stage
      else
         check_cell_content('children', 1, 13, true) # SDTM stage
      end
    else
      check_cell_content('children', 1, 1, "#{hash['Identifier']}")
      check_cell_content('children', 1, 2, "#{hash['SubmissionValue']}")
      check_cell_content('children', 1, 3, "#{hash['PreferredTerm']}")
      check_cell_content('children', 1, 4, "#{hash['Synonyms']}")
      check_cell_content('children', 1, 5, "#{hash['Definition']}")
      check_cell_content('children', 1, 6, "#{hash['Tags']}")
      check_cell_content('children', 1, 7, "#{hash['CRFDisplayValue']}") # CRF Display Value
      check_cell_content('children', 1, 8, "#{hash['DisplayOrder']}")
      check_cell_content('children', 1, 9, "#{hash['SynonymSponsor']}") # Sponsor synonym
      
      if hash['ADaMStage'] == 'false'  # Adam stage
         check_cell_content('children', 1, 10, false)  # Adam stage
      else 
         check_cell_content('children', 1, 10, true)
      end
      if hash['DCStage'] == 'false'
         check_cell_content('children', 1, 11, false) # DC stage
      else
         check_cell_content('children', 1, 11, true) # DC stage
      end
      if hash['SDTMStage'] == 'false'
         check_cell_content('children', 1, 12, false) # SDTM stage
      else
         check_cell_content('children', 1, 12, true) # SDTM stage
      end
    end
  end

    wait_for_ajax(20)
    save_screen(TYPE)
  end