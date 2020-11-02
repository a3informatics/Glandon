#################### When statements 


When('I fill in {string} as the identifier and {string} as the label') do |string,string2|

  ui_in_modal do
  fill_in 'identifier', with: string
  fill_in 'label', with: string
   end     
  end


When('I select {string}, version {string} as the BC template') do |string,string2|
      find('#new-item-template').click
    ip_pick_managed_items(:bct, [ { identifier: string, version: string2 } ], 'new-bc')
end


When('I enter\/select the values that defines the BC') do |table|
   table.hashes.each do |row|
         ui_editor_select_by_location(row,1)
        if hash['Enable'] == 'true' 
        ui_check_table_cell_icon 'editor', row, 1, 'sel-filled'
        end
        if hash['Enable'] == 'false' 
          ui_editor_select_by_location row, 1
          ui_press_key :arrow_right
          ui_press_key :enter
          wait_for_ajax 10
          ui_check_table_cell_icon 'editor', row, 1, 'times-circle'
        end
        ui_editor_select_by_location(row,2)
        if hash['Collect'] == 'true' 
        ui_check_table_cell_icon 'editor', row, 2, 'sel-filled'
        end
        if hash['Collect'] == 'false' 
          ui_editor_select_by_location row, 2
          ui_press_key :arrow_right
          ui_press_key :enter
          wait_for_ajax 10
          ui_check_table_cell_icon 'editor', row, 2, 'times-circle'
        end
      ui_editor_select_by_location(row,3)
       ui_editor_fill_inline "alias", "#{hash['Alias']}\n"
      ui_editor_select_by_location(row,4)
       ui_editor_fill_inline "question_text", "#{hash['Question']}\n"
      ui_editor_select_by_location(row,5)
       ui_editor_fill_inline "prompt_text", "#{hash['Prompt']}\n"
      ui_editor_select_by_location(row,7)
       ui_editor_fill_inline "format", "#{hash['Format']}\n"
      ui_editor_select_by_location(row,8)
      ui_press_key :enter
      ui_in_modal do
        ip_pick_unmanaged_items :unmanaged_concept, [
            { parent: "#{hash['Codelist']}", version: "#{hash['Version']}", submission_value: "#{hash['Terminology']}" }
          ], 'bc-term-ref'
      end
  end
  wait_for_ajax(20)
end


##################### Then statements 
Then('I see Biomedical Concepts Index page is displayed') do 
  expect(page).to have_content "Index: Biomedical Concepts"
  wait_for_ajax(20)
  save_screen(TYPE)
end


Then('I see the Biomedical Concept Editor for {string}') do |string|
  expect(page).to have_content string
  expect(page).to have_content 'Biomedical Concept Editor'
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('the BC {string} gets created') do |string|
  expect(page).to have_content string
  expect(page).to have_content 'Biomedical Concept Editor'
end
