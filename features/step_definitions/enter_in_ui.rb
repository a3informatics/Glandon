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
         ui_table_search('children', string)
end

When('I enter {string} in the search area of the editor') do |string|
         ui_table_search('editor', string)
end


When('I enter {string} in the overall search field') do |string|
         fill_in 'Overall Search', with:string
         find('#overall_search').send_keys(:return)
         wait_for_ajax(20)
end

When('I enter {string} in the Code List search field') do |string|
         fill_in 'searchTable_csearch_parent_identifier', with:string
         find('#searchTable_csearch_parent_identifier').send_keys(:return)
         wait_for_ajax(20)
end
When('I enter {string} in the Code List Name search field') do |string|
         fill_in 'searchTable_csearch_parent_label', with:string
         find('#searchTable_csearch_parent_label').send_keys(:return)
         wait_for_ajax(20)
end
When('I enter {string} in the Item search field') do |string|
         fill_in 'searchTable_csearch_identifier', with:string
         find('#searchTable_csearch_identifier').send_keys(:return)
         wait_for_ajax(20)
end
When('I enter {string} in the Submission Value search field') do |string|
         fill_in 'searchTable_csearch_notation', with:string
         find('#searchTable_csearch_notation').send_keys(:return)
         wait_for_ajax(20)
end
When('I enter {string} in the Preferred Term search field') do |string|
         fill_in 'searchTable_csearch_preferred_term', with:string
         find('#searchTable_csearch_preferred_term').send_keys(:return)
         wait_for_ajax(20)
end
When('I enter {string} in the Synonym search field') do |string|
         fill_in 'searchTable_csearch_synonym', with:string
         find('#searchTable_csearch_synonym').send_keys(:return)
         wait_for_ajax(20)
end
When('I enter {string} in the Definition search field') do |string|
         fill_in 'searchTable_csearch_definition', with:string
         find('#searchTable_csearch_definition').send_keys(:return)
         wait_for_ajax(20)
end
When('I enter {string} in the Tags search field') do |string|
         fill_in 'searchTable_csearch_tags', with:string
         find('#searchTable_csearch_tags').send_keys(:return)
         wait_for_ajax(20)
end



