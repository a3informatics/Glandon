module UiHelpers

  # General Tag helpers
	def ui_click_tag_add
    ui_click_by_id('tag_add')
  end

  def ui_click_tag_delete
    ui_click_by_id('tag_delete')
  end

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

  def ui_table_row_col_link_click(table_id, row, col)
    find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]/a").click
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

  def ui_link_disabled(id)
    expect(page).to have_no_link("#{id}")
  end

  def ui_button_label(id, text)
    expect(find("##{id}").text).to eq(text)
  end

  def ui_select_check_selected(id, value)
    expect(page).to have_select(id, selected: value)
  end

  def ui_select_check_options(id, options)
    expect(page).to have_select(id, with_options: options)
  end

  # Check this, not used so far! :)
  def ui_select_check_all_options(id, options)
    expect(page).to have_select(id, options: options)
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

  def ui_child_search(text)
    input = find(:xpath, '//*[@id="children_table_filter"]/label/input')
    input.set(text)
    #input.native.send_keys(:return)
  end

  # check table cell
  def ui_check_table_cell(table_id, row, col, text)
    cell = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]").text
    expect(cell).to eq(text)
  end

  def ui_check_table_head(table_id, col, text)
    head = find(:xpath, "//*[@id='#{table_id}']/thead/tr/th[#{col}]").text
    expect(head).to eq(text)
  end

  # check table cell, start with text
  def ui_check_table_cell_starts_with(table_id, row, col, text)
    cell = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]").text
    expect(text.start_with?(text)).to eq(true)
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
  puts "Cell: >#{cell}<"
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

  def ui_check_table_info(table_id, first, last, total)
    expect(page).to have_css("##{table_id}_info", text: "Showing #{first} to #{last} of #{total} entries")
  end

  # Flash
  def ui_check_no_flash_message_present
    expect(page).not_to have_selector(:css, ".alert")
  end

  def ui_check_flash_message_present
    expect(page).to have_selector(:css, ".alert")
  end

  # Terminology
    def ui_term_overall_search(text)
    input = find(:xpath, '//*[@id="searchTable_filter"]/label/input')
    input.set(text)
    input.native.send_keys(:return)
    wait_for_ajax(15)
  end

  def ui_term_column_search(column, text)
    column_input_map =
    {
      notation: "searchTable_csearch_submission_value",
      code_list: "searchTable_csearch_cl",
      definition: "searchTable_csearch_definition"
    }
    input = column_input_map[column]
    fill_in input, with: text
    ui_hit_return(input)
    wait_for_ajax(15)
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
    #page.driver.browser.manage.window.resize_to(width, height)
    window = Capybara.current_session.current_window
  	window.resize_to(width, height)
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

  # Navigation
  # ==========

  def ui_section_expanded?(section)
    x = page.execute_script("$('##{section}').hasClass('collapsed')")
    #x = page.find("##{section}")[:class].include?("collapsed")
  end

  def ui_expand_section(section)
    page.execute_script("$('##{section}').removeClass('collapsed')")
  end

  def ui_collapse_section(section)
    page.execute_script("$('##{section}').addClass('collapsed')")
  end

  def ui_navbar_click (id)
    id_to_section_map = {
			main_nav_in: "main_nav_sysadmin", main_nav_ira: "main_nav_sysadmin", main_nav_im: "main_nav_sysadmin", main_nav_at: "main_nav_sysadmin", main_nav_el: "main_nav_sysadmin",
			main_nav_u: "main_nav_impexp", main_nav_i: "main_nav_impexp", main_nav_e: "main_nav_impexp", main_nav_bj: "main_nav_impexp",
			main_nav_ics: "main_nav_util", main_nav_ma: "main_nav_util", main_nav_ahr: "main_nav_util",
			main_nav_te: "main_nav_term", main_nav_ct: "main_nav_term",
			main_nav_bc: "main_nav_biocon", main_nav_bct: "main_nav_biocon",
			main_nav_f: "main_nav_forms",
			main_nav_sig: "main_nav_sdtm", main_nav_sm: "main_nav_sdtm", main_nav_sd: "main_nav_sdtm",
			main_nav_aig: "main_nav_adam"
			} 
    section = id_to_section_map[id.to_sym]
    ui_expand_section(section) if !ui_section_expanded?(section)
    click_link "#{id}"
  end
 
  #System Admin
  def click_navbar_at
    ui_navbar_click('main_nav_at')
  end
 
  def click_navbar_el
    ui_navbar_click('main_nav_el')
  end

	#Dashboard
	def click_navbar_dashboard
		visit 'dashboard'
	end

	#System Admin
	def click_navbar_namespaces
		ui_navbar_click('main_nav_in')
	end

	def click_navbar_regauthorities
		ui_navbar_click('main_nav_ira')
	end

	def click_navbar_manitems
		ui_navbar_click('main_nav_im')
	end

	def click_navbar_at
		ui_navbar_click('main_nav_at')
	end

	def click_navbar_el
		ui_navbar_click('main_nav_el')
	end

	#Import/Export
	def click_navbar_upload
		ui_navbar_click('main_nav_u')
	end

	def click_navbar_import
		ui_navbar_click('main_nav_i')
	end

	def click_navbar_export
		ui_navbar_click('main_nav_e')
	end

	def click_navbar_background_jobs
		ui_navbar_click('main_nav_bj')
	end

  #Utilities
  def click_navbar_tags
    ui_navbar_click('main_nav_ics')
  end

	def click_navbar_ma
    ui_navbar_click('main_nav_ma')
  end

	def click_navbar_ahr
    ui_navbar_click('main_nav_ahr')
  end

  #Terminology
  def click_navbar_terminology
    ui_navbar_click('main_nav_te')
  end

  def click_navbar_cdisc_terminology
    ui_navbar_click('main_nav_ct')
  end

  #Biomedical Concepts
	def click_navbar_bct
    ui_navbar_click('main_nav_bct')
  end

  def click_navbar_bc
    ui_navbar_click('main_nav_bc')
  end

  #Forms
  def click_navbar_forms
    ui_navbar_click('main_nav_f')
  end

  #SDTM
  def click_navbar_ig_domain
    ui_navbar_click('main_nav_sig')
  end

	def click_navbar_sdtm_model
    ui_navbar_click('main_nav_sm')
  end

  def click_navbar_sponsor_domain
    ui_navbar_click('main_nav_sd')
  end

	#ADaM
	def click_navbar_adam_ig_domain
    ui_navbar_click('main_nav_aig')
  end

  #Community Version

  def click_browse_every_version
    click_link 'btn-browse-cdisc'
  end

  def click_search_the_latest_version
    click_link 'btn-search-latest'
  end

  def ui_check_table_cell_extensible(table_id, row, col, text)
    cell = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]").has_css?(".icon-extend")
    expect(cell).to eq(text)
  end

  #Context Menu
  def context_menu_element (table_id, column_nr, text, action )
    action_to_option_map =
    {
      show: "Show",
      search: "Search",
      edit: "Edit",
      delete: "Delete"
    }
    option = action_to_option_map[action]
    js_code = "var el = contextMenuElement('#{table_id}', #{column_nr}, '#{text}', '#{option}'); "
    js_code += "if (el != null) { $(el)[0].click(); } else { console.log('No match found'); } "
    page.execute_script(js_code)
  end

  def ui_dashboard_slider (start_date, end_date)
    slider = "var tl_slider = $('.timeline-container').data(); "
    slider += "tl_slider.moveToDate(tl_slider.l_slider, '#{start_date}'); "
    slider += "tl_slider.moveToDate(tl_slider.r_slider, '#{end_date}'); "
    page.execute_script(slider)
  end

  def ui_dashboard_alpha_filter (filter, filter_text)
    filter_control_map =
    {
      created: { index: 0, id: 'btn_f_created' },
      updated: { index: 1, id: 'btn_f_updated' },
      deleted: { index: 2, id: 'btn_f_deleted' }
    }
    id = filter_control_map[filter][:id]
    eq = filter_control_map[filter][:index]
    click_link "#{id}"
    js_script = "$('.alph-slider').eq(#{eq}).data().moveToLetter('#{filter_text}'); "
    page.execute_script(js_script)
  end


  def ui_create_terminology
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      expect(page).to have_content 'New Terminology'
      fill_in 'thesauri_identifier', with: 'SELECT TEST'
      fill_in 'thesauri_label', with: 'Test Terminology'
      click_button 'Create'
  end




  # Return
  def ui_hit_return(id)
    # Amended to allow for spaces in id
    field = find(:xpath, "//*[@id=\"#{id}\"]")
    field.native.send_keys(:return)
  end

  # Backspace
  def ui_hit_backspace(id)
    # Amended to allow for spaces in  id
    field = find(:xpath, "//*[@id=\"#{id}\"]")
    field.native.send_keys(:backspace)
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

  def ui_get_search_results
    #return page.evaluate_script("rhGetViaName(\"A\")").to_i
    return page.evaluate_script("d3GetSearch()")
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
