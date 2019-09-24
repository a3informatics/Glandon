module ScenarioHelpers

  def instruction_text
    return "By placing a tick in one box in each group below, please indicate which " +
      "statements best describe your own health state today."
  end

  def vas_text
    return "To help people say how good or bad a health state is, we have drawn a scale (rather like a thermometer) " +
      "on which the best state you can imagine is marked 100 and the worst state you can imagine is marked 0. \n\n" +
      "We would like you to indicate on this scale how good or bad your own health is today, in your opinion. " +
      " Please do this by drawing a line from the box below to whichever point on the scale indicates how good or " +
      " bad your health state is today."
  end

  def scroll_to_navbar
    page.execute_script("document.getElementById('sidebar').scrollIntoView(false);")
  end

  # def click_navbar_terminology
  #   click_link 'main_nav_te'
  # end

  # def click_navbar_bc
  #   click_link 'main_nav_bc'
  # end

  # def click_navbar_form
  #   click_link 'main_nav_f'
  # end

  # def click_navbar_ig_domain
  #   click_link 'main_nav_sig'
  # end

  # def click_navbar_adam_ig_domain
  #   click_link 'main_nav_aig'
  # end

  # def click_navbar_sponsor_domain
  #   click_link 'main_nav_sd'
  # end

  # def click_navbar_import
  #   click_link 'main_nav_i'
  # end

  def expect_page(text)
    expect(page).to have_content(text)
  end

  def click_table_link text, link_text
    find(:xpath, "//tr[contains(.,'#{text}')]/td/a", :text => "#{link_text}").click
  end

  def click_main_table_link(text, link_text)
    find(:xpath, "//table[@id='main']/tbody/tr[contains(.,'#{text}')]/td/a", :text => "#{link_text}").click
  end

  def main_search(search_text)
    input = find(:xpath, '//*[@id="main_filter"]/label/input')
    input.set("#{search_text}")
    input.native.send_keys(:return)
  end

  def click_secondary_table_link(text, link_text)
    find(:xpath, "//table[@id='secondary']/tbody/tr[contains(.,'#{text}')]/td/a", :text => "#{link_text}").click
  end

  def secondary_search(search_text)
    input = find(:xpath, '//*[@id="secondary_filter"]/label/input')
    input.set("#{search_text}")
    input.native.send_keys(:return)
  end

  def term_editor_row_label(row, text, exit_key)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[2]").click
    term_editor_field("label", text, exit_key)
  end

  def term_editor_notation(text, exit_key)
    term_editor_field("notation", text, exit_key)
  end

  def term_editor_update_notation(identifier, text, exit_key)
    row = editor_get_row(identifier)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[3]").click
    term_editor_field("notation", text, exit_key)
  end

  def term_editor_preferred_term(text, exit_key)
    term_editor_field("preferredTerm", text, exit_key)
  end

  def term_editor_synonym(text, exit_key)
    term_editor_field("synonym", text, exit_key)
  end

  def term_editor_definition(text, exit_key)
    term_editor_field("definition", text, exit_key)
  end

  def term_editor_field(name, text, exit_key)
    expect(page).to have_css("#DTE_Field_#{name}", wait: 10)
    fill_in "DTE_Field_#{name}", with: "#{text}\t" if exit_key == :tab
    fill_in "DTE_Field_#{name}", with: "#{text}\n" if exit_key == :return
    wait_for_ajax(10)
  end

  def term_editor_edit_children(unique_text)
    find(:xpath, "//tr[contains(.,'#{unique_text}')]/td/button", :text => 'Edit').click
  end

  def term_editor_concept(prefix, identifier, label, notation, preferred_term, synonym, definition)
    fill_in 'Identifier', with: identifier
    click_button 'New'
    expect(page).to have_xpath("//table[@id='editor_table']/tbody/tr/td", text: "#{prefix}.#{identifier}", wait: 10)
    row = editor_get_row("#{prefix}.#{identifier}")
    term_editor_row_label(row, label, :tab)
    term_editor_notation(notation, :tab)
    term_editor_preferred_term(preferred_term, :tab)
    term_editor_synonym(synonym, :tab)
    term_editor_definition(definition, :return)
  end

  def editor_get_row(identifier)
    row = 0
    page.all('#editor_table tbody tr').each do |tr|
      row += 1
      cell_text = find(:xpath, "//*[@id=\"editor_table\"]/tbody/tr[#{row}]/td[1]").text
      return row if cell_text == identifier
    end
    return -1
  end

  def bc_scroll_to_editor_table
    page.execute_script("document.getElementById('editor_table').scrollIntoView(false);")
  end

  def bc_scroll_to_bc_table
    page.execute_script("document.getElementById('bc_table').scrollIntoView(false);")
  end

  def bc_scroll_to_all_bc_panel
    page.execute_script("document.getElementById('all_bc_panel').scrollIntoView(false);")
  end

  def bc_set_cat(term_list)
    row = editor_get_row("Category (--CAT)")
    bc_editor_enabled(row)
    bc_editor_add_terms(row, term_list)
  end

  def bc_set_test_code(term_list)
    row = editor_get_row("Test Code (--TESTCD)")
    bc_editor_enabled(row)
    bc_editor_add_terms(row, term_list)
  end

  def bc_set_test_name(term_list)
    row = editor_get_row("Test Name (--TEST)")
    bc_editor_enabled(row)
    bc_editor_add_terms(row, term_list)
  end

  def bc_set_date_and_time(question_text)
    row = editor_get_row("Date Time (--DTC)")
    bc_editor_enabled(row)
    bc_editor_collect(row)
    bc_editor_question_text(row, question_text)
  end

  def bc_set_result_value_coded(question_text, term_list)
    row = editor_get_row("Result Value (--ORRES)")
    bc_editor_enabled(row)
    bc_editor_collect(row)
    bc_editor_question_text(row, question_text)
    bc_editor_add_terms(row, term_list)
  end

  def bc_set_result_value(question_text, format)
    row = editor_get_row("Result Value (--ORRES)")
    bc_editor_enabled(row)
    bc_editor_collect(row)
    bc_editor_question_text(row, question_text)
    bc_editor_format(row, format)
  end

  def bc_editor_question_text(row, text)
    bc_editor_field(row, 2, "question_text", text)
  end

  def bc_editor_prompt_text(row, text)
    bc_editor_field(row, 3, "prompt_text", text)
  end

  def bc_editor_enabled(row)
    bc_editor_click(row, 4)
  end

  def bc_editor_collect(row)
    bc_editor_click(row, 5)
  end

  def bc_editor_format(row, text)
    bc_editor_field(row, 7, "format", text)
  end

  def bc_editor_select_terminology(row)
    bc_editor_click(row, 9)
  end

  def bc_editor_field(row, column, field_name, text)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[#{column}]").click
    expect(page).to have_css("#DTE_Field_#{field_name}", wait: 10)
    fill_in "DTE_Field_#{field_name}", with: text
    wait_for_ajax(10)
  end

  def bc_editor_click(row, column)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[#{column}]").click
    wait_for_ajax(10)
  end

  def bc_editor_add_terms(row, term_list)
    bc_editor_select_terminology(row)
    term_list.each do |term|
      bc_editor_find_term(term)
      ui_click_by_id 'tfe_add_item'
      wait_for_ajax(10)
    end
  end

  def bc_editor_find_term(item_code)
    fill_in 'searchTable_csearch_cl', with: item_code[:cl]
    ui_hit_return('searchTable_csearch_cl')
    wait_for_ajax(10)
    fill_in 'searchTable_csearch_item', with: item_code[:cli]
    ui_hit_return('searchTable_csearch_item')
    wait_for_ajax(10)
    ui_table_row_click('searchTable', item_code[:cli])
  end

  def bc_create(identifier, label, template)
    fill_in "biomedical_concept_identifier", with: identifier
    fill_in "biomedical_concept_label", with: label
    select template, from: "biomedical_concept_uri"
    click_button 'Create'
    wait_for_ajax(10)
  end

  def bc_export_ttl(c_code, status)
    scroll_to_navbar
    click_navbar_bc
    main_search(c_code)
    click_main_table_link "BC #{c_code}", 'History'
    click_main_table_link "BC #{c_code}", 'Show'
    click_link 'Export Turtle'
    wait_for_specific_download("ACME_BC #{c_code}.ttl")
    rename_file("ACME_BC #{c_code}.ttl", "ACME_BC_#{c_code}_#{status}.ttl")
    copy_file_to_db("ACME_BC_#{c_code}_#{status}.ttl")
  end

  def form_create(identifier, label, new_label)
    click_navbar_forms
    expect(page).to have_content 'Index: Forms'
    click_link 'New'
    fill_in 'form_identifier', with: "#{identifier}"
    fill_in 'form_label', with: "#{label}"
    click_button 'Create'
    expect(page).to have_content 'Form was successfully created.'
    ui_main_show_all
    ui_table_row_link_click("#{identifier}", "History")
    expect(page).to have_content "History: #{identifier}"
    ui_table_row_link_click("#{identifier}", "Edit")
    fill_in 'formLabel', with: "#{new_label}"
  end

  def form_bc_search(search_text)
    input = find(:xpath, '//*[@id="bcTable_filter"]/label/input')
    input.set("#{search_text}")
    input.native.send_keys(:return)
  end

  def form_bc_click
    find(:xpath, "//*[@id=\"bcTable\"]/tbody/tr/td[2]").click
  end

end
