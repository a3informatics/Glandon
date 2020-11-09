 ##################### Pre-conditions - Given statements




##################### When statements 

When('I fill in {string} as the identifier and {string} as the label') do |string,string2|
  ui_in_modal do
  fill_in 'identifier', with: string
  fill_in 'label', with: string
   end     
end

When('I enter {string} in the Code lists search area and click {string} to display the {string} code list') do |string, string2, string3|
      ui_child_search(string)
      find(:xpath, "//tr[contains(.,'#{string}')]/td/a", :text => string2).click
      wait_for_ajax(20)
end

When('I enter {string} in the Code List Items search area and click {string} to display the {string} code list item') do |string, string2, string3|
      ui_child_search(string)
      find(:xpath, "//tr[contains(.,'#{string}')]/td/a", :text => string2).click
      wait_for_ajax(20)
end

When('I enter {string} in the search area click {string} to display the {string} code list') do |string, string2, string3|
  if string2 == 'Changes'
    ui_table_search("changes", string)
    find(:xpath, "//tr[contains(.,'#{string2}')]/td/a", :text => string2).click
    wait_for_ajax(20)
  end
end

When('I enter {string} in the search area') do |string|
         ui_child_search(string)
end




