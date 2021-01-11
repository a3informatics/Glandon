module EditorHelpers

  # DT Editor

  def ui_editor_fill_inline(field, text)
    sleep 0.5
    fill_in "DTE_Field_#{field}", with: text
    wait_for_ajax 20
  end

  def ui_editor_select_option(field, option_text)
    sleep 0.5
    select option_text, from: "DTE_Field_#{field}"
    ui_press_key :return 
    wait_for_ajax 20
  end

  def ui_editor_change_bool
    sleep 0.5
    ui_press_key :arrow_right 
    ui_press_key :return 
    wait_for_ajax 20
  end

  def ui_editor_select_by_location(row, col, with_offset = false, table = 'editor')
    target = find(:xpath, "//table[@id='#{ table }']//tbody/tr[#{ row }]/td[#{ col }]")
    if with_offset
      target.double_click(x: 10, y: 10)
    else
      target.double_click()
    end
  end

  def ui_editor_select_by_content(text, with_offset = false, table = 'editor')
    target = find(:xpath, "//table[@id='#{ table }']//tbody/tr/td[contains(.,'#{ text }')]")
    if with_offset
      target.double_click(x: 10, y: 10)
    else
      target.double_click()
    end
  end

  def ui_editor_check_value(row, col, text)
    expect(find(:xpath, "//table[@id='editor']//tr[#{row}]/td[#{col}]").text).to include(text)
  end

  def ui_editor_check_focus(row, col)
    expect(find(:xpath, "//table[@id='editor']//tr[#{row}]/td[#{col}]")[:class]).to include('focus')
  end

  def ui_editor_check_error(field, error_text)
    expect(find(".DTE_Inline_Field div[data-dte-e = 'msg-error']").text).to eq(error_text)
  end

  def ui_editor_check_disabled(field)
    expect(find(".DTE_Field_Name_#{field}")[:class]).to include("disabled")
  end

end
