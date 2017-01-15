module UiHelpers

	# General UI helpers
  # ==================
  
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

  # Note: Won't work if field disabled
  def ui_check_input(id, value)
    expect(find_field("#{id}").value).to eq "#{value}"
  end

  def ui_check_disabled_input(field_id, value)
    expect(find_field("#{field_id}", disabled: true).value).to eq(value)
  end

  def ui_check_checkbox(id, value)
    #expected = "on" if value
    #expected = "off" if !value
    #expect(find_field("#{id}").value).to eq("#{expected}")
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

  # Not sure this works!!!!
  def ui_is_not_visible(field_id)
    #expect(page).not_to have_selector("#{field_id}", visible: true)
    #page.find("#{field_id}")[:class].include?("hidden")
    expect(page).not_to have_selector(:xpath, "//div[@id='#{field_id}' and @class='panel panel-default']")
  end

  # Not sure this works!!!!
  def ui_is_visible(field_id)
    #expect(page).to have_selector("#{field_id}", visible: true)
    expect(page).to have_selector(:xpath, "//div[@id='#{field_id}' and @class='panel panel-default']")
  end

  # Datatables
  #
  def ui_main_show_all
    page.evaluate_script("dtMainTableAll()")
  end

  def ui_cdisc_search_show_all
    page.evaluate_script("csSearchTableAll()")
  end
  
  # check table row
  def ui_check_table_row(table_id, row, data)
    page.all("table##{table_id} tbody tr:nth-child(#{row}) td").each_with_index do |td, index|
      #puts "#{td.text} <-> #{data[index]}, for index #{index}"
      if index < data.length
        expect(td.text).to eq(data[index])
      end
    end
  end

   def ui_check_anon_table_row(row, data)
    page.all("table tbody tr:nth-child(#{row}) td").each_with_index do |td, index|
      #puts "#{td.text} <-> #{data[index]}, for index #{index}"
      if index < data.length
        expect(td.text).to eq(data[index])
      end
    end
  end

  def ui_check_td_with_id(id, text)
    td = find(:xpath, "//*[@id='#{id}']")
    #//*[@id="conceptLabel"]
    expect(td.text).to eq(text)
  end

  def ui_check_no_flash_message_present
    expect(page).not_to have_selector(:css, "alert")
  end

  def ui_check_flash_message_present
    expect(page).to have_selector(:css, "alert")
  end

  # Close and Save
  # ==============
  def ui_click_close
    page.evaluate_script("rhClickClose()")
  end

  def ui_click_save
    page.evaluate_script("rhClickSave()")
  end

  def ui_click_by_id(id)
    page.evaluate_script("simulateClick($('##{id}')[0])")
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