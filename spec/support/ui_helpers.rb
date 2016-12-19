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
  
  def ui_click_node(text)
    fill_in 'click_node_text', with: text
    click_button 'click_node'
  end

  def ui_table_row_link_clink(content, link_text)
    find(:xpath, "//tr[contains(.,'#{content}')]/td/a", :text => "#{link_text}").click
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

end