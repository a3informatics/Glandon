##################### When statements #####################

When('I update Synonyms to {string}') do |string|
  ui_editor_select_by_location(1,4)
   ui_editor_fill_inline "synonym", "#{string}\n"
   wait_for_ajax(20)
end

When('I delete Synonym {string}') do |string|
  ui_editor_select_by_location(1,4)
  ui_editor_fill_inline "synonym", "\n"
  wait_for_ajax(20)
end
When('I update Preferred Term to {string}') do |string|
  ui_editor_select_by_location(1,3)
   ui_editor_fill_inline 'preferred_term', "#{string}\n"
   wait_for_ajax(20)
end

When('I delete Preferred Term {string}') do |string|
  ui_editor_select_by_location(1,3)
  ui_editor_fill_inline 'preferred_term', "\n"
  wait_for_ajax(20)
end

