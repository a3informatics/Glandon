module ScenarioHelpers

  def click_navbar_terminology
    click_link 'main_nav_te'
  end

  def expect_page(text)
    expect(page).to have_content(text)
  end

  def click_table_link text, link_text
    find(:xpath, "//tr[contains(.,'#{text}')]/td/a", :text => "#{link_text}").click
  end

  def click_main_table_link(text, link_text)
    find(:xpath, "//table[@id='main']/tbody/tr[contains(.,'#{text}')]/td/a", :text => "#{link_text}").click
  end

  def click_secondary_table_link(text, link_text)
    find(:xpath, "//table[@id='secondary']/tbody/tr[contains(.,'#{text}')]/td/a", :text => "#{link_text}").click
  end

  def term_editor_row_label(row, text, exit_key)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[2]").click
    term_editor_field("label", text, exit_key)
  end

  def term_editor_notation(text, exit_key)
    term_editor_field("notation", text, exit_key)
  end

  def term_editor_update_notation(identifier, text, exit_key)
    row = term_editor_get_row(identifier)
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
    fill_in "DTE_Field_#{name}", with: "#{text}\t" if exit_key == :tab
    fill_in "DTE_Field_#{name}", with: "#{text}\n" if exit_key == :return
  end

  def term_editor_edit_children(unique_text)
    find(:xpath, "//tr[contains(.,'#{unique_text}')]/td/button", :text => 'Edit').click
  end

  def term_editor_concept(prefix, identifier, label, notation, preferred_term, synonym, definition)
    fill_in 'Identifier', with: identifier
    click_button 'New'
    expect_page identifier
  #byebug
    row = term_editor_get_row("#{prefix}.#{identifier}")
    term_editor_row_label(row, label, :tab)
    term_editor_notation(notation, :tab)
    term_editor_preferred_term(preferred_term, :tab)
    term_editor_synonym(synonym, :tab)
    term_editor_definition(definition, :return)
  end

  def term_editor_get_row(identifier)
    row = 0
    page.all('#editor_table tbody tr').each do |tr|
      row += 1
      cell_text = find(:xpath, "//*[@id=\"editor_table\"]/tbody/tr[#{row}]/td[1]").text
    #byebug
      return row if cell_text == identifier
    end
    return -1
  end

end