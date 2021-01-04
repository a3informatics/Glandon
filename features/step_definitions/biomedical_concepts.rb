#################### When statements 


When('I select {string}, version {string} as the BC template') do |string,string2|
      VER = string2.split[0].to_i
      ui_in_modal do
        find('#new-item-template').click
        ip_pick_managed_items(:bct, [ { identifier: string, version: VER} ], 'new-bc')
      end
end

When('I enter\/select the values that defines the BC') do |table|
    i = 1
    select 'All', from: 'editor_length'
    table.hashes.each do |hash|
    
        ui_editor_select_by_location(i,1)
        if "#{hash['Enable']}" == 'true' 
        ui_check_table_cell_icon 'editor', i, 1, 'sel-filled'
        end
        if "#{hash['Enable']}" == 'false'
          ui_press_key :enter 
          ui_press_key :arrow_right
          wait_for_ajax 10
          ui_press_key :enter
          wait_for_ajax 10
          ui_check_table_cell_icon 'editor', i, 1, 'times-circle'
        end
        ui_editor_select_by_location(i,2)
        if "#{hash['Collect']}" == 'true' 
        ui_check_table_cell_icon 'editor', i, 2, 'sel-filled'
        end
        if "#{hash['Collect']}" == 'false' 
          ui_press_key :enter
          ui_press_key :arrow_right
          wait_for_ajax 10
          ui_press_key :enter
          wait_for_ajax 10
          ui_check_table_cell_icon 'editor', i, 2, 'times-circle'
        end
        ui_editor_select_by_location(i,4)
        ui_editor_fill_inline "question_text", "#{hash['Question']}\n"
        ui_editor_select_by_location(i,5)
        ui_editor_fill_inline "prompt_text", "#{hash['Prompt']}\n"
        ui_editor_select_by_location(i,7)
        ui_editor_fill_inline "format", hash['Format']
        if !hash['Codelist'].blank?
          ui_editor_select_by_location(i,8)
          wait_for_ajax 20
          ui_press_key :enter
          ui_in_modal do
          ip_check_tabs [:unmanaged_concept], 'bc-term-ref'
          ip_pick_unmanaged_items :unmanaged_concept, [
          { parent: "#{hash['Codelist']}", owner: 'CDISC', version: hash['Version'], identifier: "#{hash['Terminology']}" }], 'bc-term-ref', false
          ip_submit 'bc-term-ref'      
          end
        end
      i = i + 1
    end
  wait_for_ajax 20
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
  wait_for_ajax(20)
  save_screen(TYPE)
end
