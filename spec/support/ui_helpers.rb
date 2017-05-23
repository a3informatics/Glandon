module UiHelpers

	# General UI helpers
  # ==================
  
  def ui_check_page_has(text)
  	expect(page).to have_content(text)
  end

  def ui_click_ok(text="")
    a = page.driver.browser.switch_to.alert
    expect(a.text).to eq(text) if !text.empty?
    a.accept 
  end

  def ui_click_cancel(text="")
    a = page.driver.browser.switch_to.alert
    expect(a.text).to eq(text) if !text.empty?
    a.dismiss
  end
  
  def ui_table_row_link_click(content, link_text)
    find(:xpath, "//tr[contains(.,'#{content}')]/td/a", :text => "#{link_text}").click
  end

  def ui_table_row_click(table, content)
    within "##{table}" do
      find('td', :text => "#{content}").click 
    end
  end

  def ui_table_row_double_click(table, content)
    within "##{table}" do
      find('td', :text => "#{content}").double_click
    end
  end

  # Note: Won't work if field disabled
  def ui_check_input(id, value)
    expect(find_field("#{id}").value).to eq "#{value}"
  end

  def ui_check_disabled_input(field_id, value)
    expect(find_field("#{field_id}", disabled: true).value).to eq(value)
  end

  def ui_check_checkbox(id, value)
    assert page.has_no_checked_field?(id) if !value 
    assert page.has_checked_field?(id) if value 
  end

  def ui_check_radio(id, value)
    expect(find_field("#{id}").checked?).to eq(value)
  end

  def ui_check_div_text(id, text)
    text_field = page.find(:xpath, "//div[@id=\"#{id}\"]")
    expect(text_field.text).to eq(text)
  end

  def ui_set_focus(field_id)
    page.execute_script %Q{ $('##{field_id}').trigger('focus') }
  end

  def ui_field_disabled(field_id)
    expect(page).to have_field("#{field_id}", disabled: true)
  end

  def ui_field_enabled(field_id)
    expect(page).to have_field("#{field_id}", disabled: false)
  end

  def ui_button_disabled(id)
    expect(page).to have_button("#{id}", disabled: true)
  end       

  def ui_button_enabled(id)
    expect(page).to have_button("#{id}", disabled: false)
  end       

  def ui_button_label(id, text)
    expect(find("##{id}").text).to eq(text)
  end

  # Datatables
  #
  def ui_main_show_all
    page.evaluate_script("dtMainTableAll()")
  end

  def ui_main_search(text)
  	input = find(:xpath, '//*[@id="main_filter"]/label/input')
    input.set(text)
    input.native.send_keys(:return)
  end

  # check table cell
  def ui_check_table_cell(table_id, row, col, text)
    cell = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]").text
    expect(cell).to eq(text)
  end

  # check table cell options
  def ui_check_table_cell_options(table_id, row, col, options)
    expect(check_table_cell_options(table_id, row, col, options)).to eq(true)
  end

  def check_table_cell_options(table_id, row, col, options)
    cell = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]").text
    options.each do |text|
    	return true if cell == text
    end
    return false
  end

  # check table row
  def ui_check_table_row(table_id, row, data)
    page.all("table##{table_id} tbody tr:nth-child(#{row}) td").each_with_index do |td, index|
      if index < data.length
        expect(td.text).to eq(data[index]) if !data[index].nil?
      end
    end
  end

  def ui_check_anon_table_row(row, data)
    page.all("table tbody tr:nth-child(#{row}) td").each_with_index do |td, index|
      if index < data.length
        expect(td.text).to eq(data[index]) if !data[index].nil?
      end
    end
  end

  def ui_check_td_with_id(id, text)
    td = find(:xpath, "//*[@id='#{id}']")
    #//*[@id="conceptLabel"]
    expect(td.text).to eq(text)
  end

  def ui_check_page_options(table_id, options)
    index = 1
    options.each do |key, value|
      expect(find(:xpath, "//*[@id='#{table_id}_length']/label/select/option[#{index}]")[:value]).to eq("#{value}")
      expect(find(:xpath, "//*[@id='#{table_id}_length']/label/select/option[#{index}]").text).to eq(key)
      index += 1
    end
  end

  # Flash
  # Not checked
  def ui_check_no_flash_message_present
    expect(page).not_to have_selector(:css, "alert")
  end

  def ui_check_flash_message_present
    expect(page).to have_selector(:css, "alert")
  end

  # Breadcrumb
  # ==========
  def ui_check_breadcrumb(crumb_1, crumb_2, crumb_3, crumb_4)
    if !crumb_1.empty?
      li = find(:xpath, '//*[@id="breadcrumb_1"]')
      expect(li.text).to eq(crumb_1)
    end
    if !crumb_2.empty?
      li = find(:xpath, '//*[@id="breadcrumb_2"]')
      expect(li.text).to eq(crumb_2)
    end
    if !crumb_3.empty?
      li = find(:xpath, '//*[@id="breadcrumb_3"]')
      expect(li.text).to eq(crumb_3)
    end    
    if !crumb_4.empty?
      li = find(:xpath, '//*[@id="breadcrumb_4"]')
      expect(li.text).to eq(crumb_4)
    end    
  end

  def ui_click_breadcrumb(index)
    a = find(:xpath, "//*[@id=\"breadcrumb_#{index}\"]/a")
    a.click
  end

  # Screen Size
  # ===========
  def set_screen_size(width=1200, height=786)
    page.driver.browser.manage.window.resize_to(width, height)
  end

  # Buttons etc
  # ===========
  def ui_click_close
    page.evaluate_script("rhClickClose()")
  end

  def ui_click_save
    page.evaluate_script("rhClickSave()")
  end

  def ui_click_by_id(id)
    page.evaluate_script("simulateClick($('##{id}')[0])")
  end

  def ui_click_back_button
    page.evaluate_script('window.history.back()')
  end

  # Return
  def ui_hit_return(id)
    find("##{id}").native.send_keys(:return)
  end

  # Backspace
  def ui_hit_backspace(id)
    find("##{id}").native.send_keys(:backspace)
  end

  # Scroll by
  def ui_scroll_to_id(id)
    page.execute_script("document.getElementById(#{id}).scrollTop += 100")
  end

	def ui_scroll_to_id_2(id)
  	page.execute_script("document.getElementById('#{id}').scrollIntoView(false);")
  end

  # D3 Tree Functions
  # =================

  def ui_click_node_name(text)
    page.evaluate_script("rhClickNodeByName(\"#{text}\")")
  end

  def ui_click_node_key(key)
    page.evaluate_script("rhClickNodeByKey(#{key})")
  end

  def ui_double_click_node_key(key)
    page.evaluate_script("rhDblClickNodeByKey(#{key})")
  end

  def ui_check_node_ordinal(key, value)
    expect(page.evaluate_script("rhGetOrdinal(#{key})").to_i).to eq(value)
  end

  def ui_check_node_is_common(key, value)
    expect(page.evaluate_script("rhGetCommon(#{key})")).to eq(value)
  end

  def ui_get_last_node
    return page.evaluate_script("d3eLastKey()").to_i
  end

  def ui_clear_current_node
    page.evaluate_script("d3eClearCurrent()")
  end

  def ui_get_current_key
    page.evaluate_script("rhGetCurrent()").to_i
  end

  def ui_get_key_by_path(path)
    return page.evaluate_script("rhGetViaPath(#{path})").to_i
  end

  def ui_get_key_by_name(text)
    return page.evaluate_script("rhGetViaName(\"#{text}\")").to_i
  end

  def ui_check_validation_error(current_key, field, text, error_msg, to_key)
    ui_click_node_key(current_key)
    fill_in field, with: text
    ui_click_node_key(to_key)
    expect(ui_get_current_key).to eq(current_key)
    expect(page).to have_content(error_msg)
  end

  def ui_check_validation_ok(current_key, field, text, to_key)
    ui_click_node_key(current_key)
    fill_in field, with: text
    ui_click_node_key(to_key)
    #wait_for_ajax
    expect(ui_get_current_key).to eq(to_key)
  end

end