module UiHelpers

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
  
  def ui_click_node_name(text)
    fill_in 'click_node_name_text', with: text
    click_button 'click_node_name'
  end

  def ui_click_node_key(key)
    fill_in 'click_node_key_text', with: key
    click_button 'click_node_key'
  end

  def ui_table_row_link_click(content, link_text)
    find(:xpath, "//tr[contains(.,'#{content}')]/td/a", :text => "#{link_text}").click
  end

  def ui_table_row_click(table, content)
    within "##{table}" do
      find('td', :text => "#{content}").click 
    end
  end

  def ui_check_input(id, value)
    expect(find_field("#{id}").value).to eq "#{value}"
  end

  def ui_check_div_text(id, text)
    text_field = page.find(:xpath, "//div[@id=\"#{id}\"]")
    expect(text_field.text).to eq(text)
  end

  def ui_check_node_ordinal(text, value)
    expect(page.evaluate_script("getOrdinal(\"#{text}\")").to_i).to eq(value)
  end

  def ui_get_last_node
    return page.evaluate_script("d3eLastKey()").to_i
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

  def ui_button_disabled(field_id)
    expect(page).to have_button("#{field_id}", disabled: true)
  end       

  def ui_button_enabled(field_id)
    expect(page).to have_button("#{field_id}", disabled: false)
  end       

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

end