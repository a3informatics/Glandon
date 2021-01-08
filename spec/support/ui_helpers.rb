module UiHelpers

  # General UI helpers
  # ==================

  def ui_refresh_page(ajax_wait = false)
    page.driver.browser.navigate.refresh
    wait_for_ajax 20 if ajax_wait == true
  end

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
    input = find(:xpath, '//*[@id="children_filter"]/label/input')
    input.set(text)
    #input.native.send_keys(:return)
  end

  def ui_table_search(table_id, text)
    input = find(:xpath, "//*[@id=\"#{table_id}_filter\"]/label/input")
    input.set(text)
  end

  # check table cell
  def ui_check_table_cell(table_id, row, col, text)
    cell = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]").text
    expect(cell).to eq(text)
  end

  def ui_check_table_cell_edit(table_id, row, col)
    td = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]")
    expect(td.find('div span.icon-edit-circle', visible: :all)).to_not eq(nil)
  end

	def ui_check_table_cell_icon(table_id, row, col, icon)
		td = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]")
		expect(td.find("div .icon-#{icon}", visible: :all)).to_not eq(nil)
	end

  def ui_check_table_cell_delete(table_id, row, col)
    td = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]")
    expect(td.find('div span.icon-times-circle', visible: :all)).to_not eq(nil)
  end

  def ui_check_table_cell_no_change_right(table_id, row, col)
    td = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]")
    expect(td.find('div span.icon-arrow-circle-r', visible: :all)).to_not eq(nil)
  end

  def ui_check_table_cell_no_change_down(table_id, row, col)
    td = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]")
    expect(td.find('div span.icon-arrow-circle-d', visible: :all)).to_not eq(nil)
  end

  def ui_check_table_head(table_id, col, text)
    head = find(:xpath, "//*[@id='#{table_id}']//thead/tr/th[#{col}]").text
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

	def ui_check_table_button_class(table_id, row, col, classname)
    find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]/span")[:class].include?(classname)
  end


	# Indicators
  def ui_check_table_row_indicators(table_id, row, col, indicators, new_style: false)
		within("##{table_id}") do
			indicators.each do |i|
				expect(page).to have_xpath(".//tr[#{row}]/td[#{col}]/#{ new_style ? 'div/' : '' }span", count: indicators.length, visible: false)
				expect(page).to have_xpath(".//tr[#{row}]/td[#{col}]/#{ new_style ? 'div/' : '' }span", text: "#{i}", count: 1, visible: false)
			end
		end
  end

	def ui_check_indicators(parent, indicators, new_style: false)
		within(parent) do
			indicators.each do |i|
				expect(page).to have_xpath("./#{ new_style ? 'div/' : '' }span", count: indicators.length, visible: false)
				expect(page).to have_xpath("./#{ new_style ? 'div/' : '' }span", text: "#{i}", count: 1, visible: false)
			end
		end
	end

  # Flash
  def ui_check_no_flash_message_present
    expect(page).not_to have_selector(:css, ".alert")
  end

  def ui_check_flash_message_present
    expect(page).to have_selector(:css, ".alert")
  end

  # Terminology
  def ui_term_overall_filter(text)
    input = find(:xpath, '//*[@id="searchTable_filter"]/label/input')
    input.set(text)
  end

	def ui_term_overall_search(text)
		input = find("#overall_search")
		input.set(text)
		input.native.send_keys(:return)
		wait_for_ajax 120
	end

	def search_column_input_map(type)
		{ code_list: "searchTable_c#{type.to_s}_parent_identifier",
			code_list_name: "searchTable_c#{type.to_s}_parent_label",
			item: "searchTable_c#{type.to_s}_identifier",
			notation: "searchTable_c#{type.to_s}_notation",
			preferred_term: "searchTable_c#{type.to_s}_preferred_term",
			synonym: "searchTable_c#{type.to_s}_synonym",
			definition: "searchTable_c#{type.to_s}_definition",
			tags: "searchTable_c#{type.to_s}_tags",
			thesaurus: "searchTable_c#{type.to_s}_tidentifier",
			thesaurus_version: "searchTable_c#{type.to_s}_tversion" }
	end

  def ui_term_column_search(column, text, wait = true)
    input = search_column_input_map(:search)[column]
		begin
			fill_in input, with: text
			ui_hit_return(input)
  	rescue Capybara::ElementNotFound => e
			find("#searchTable_wrapper .dataTables_scrollBody").scroll_to(2000,0)
			fill_in input, with: text
			ui_hit_return(input)
			find("#searchTable_wrapper .dataTables_scrollBody").scroll_to(-2000,0)
    end
    wait_for_ajax(120) if wait
  end

	def ui_term_column_filter(column, text)
		input = search_column_input_map(:filter)[column]
		begin
			fill_in input, with: text
  	rescue Capybara::ElementNotFound => e
			find("#searchTable_wrapper .dataTables_scrollBody").scroll_to(2000,0)
			fill_in input, with: text
			find("#searchTable_wrapper .dataTables_scrollBody").scroll_to(-2000,0)
    end
	end

	def ui_term_filter_visible
		page.has_css?("#searchTable_wrapper .dataTables_scrollFoot")
	end

	def ui_term_input_empty?(type, column)
		begin
			result = find("##{search_column_input_map(type)[column]}").text == ""
  	rescue Capybara::ElementNotFound => e
			find("#searchTable_wrapper .dataTables_scrollBody").scroll_to(2000,0)
			result = find("##{search_column_input_map(type)[column]}").text == ""
			find("#searchTable_wrapper .dataTables_scrollBody").scroll_to(-2000,0)
    end
		result
	end

  def ui_header_show_more_tags
    sleep 0.3
    find( '.h-outside-wrap .expandable-content-btn', text: 'Show more' ).click
		sleep 0.3
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
  def ui_click_by_id(id)
    page.evaluate_script("simulateClick($('##{id}')[0])")
  end

  def ui_click_back_button
    page.evaluate_script('window.history.back()')
  end

  def ui_click_forward_button
    page.evaluate_script('window.history.forward()')
  end

  # Navigation
  # ==========
	def id_to_section_map
		{
			main_nav_in: "main_nav_sysadmin", main_nav_ira: "main_nav_sysadmin", main_nav_im: "main_nav_sysadmin", main_nav_at: "main_nav_sysadmin", main_nav_el: "main_nav_sysadmin",
			main_nav_u: "main_nav_impexp", main_nav_i: "main_nav_impexp", main_nav_e: "main_nav_impexp", main_nav_bj: "main_nav_impexp",
			main_nav_ics: "main_nav_util", main_nav_ma: "main_nav_util", main_nav_ahr: "main_nav_util",
			main_nav_te: "main_nav_term", main_nav_ct: "main_nav_term", main_nav_cl: "main_nav_term",
			main_nav_bc: "main_nav_biocon", main_nav_bct: "main_nav_biocon",
			main_nav_f: "main_nav_forms",
			main_nav_sig: "main_nav_sdtm", main_nav_sm: "main_nav_sdtm", main_nav_sd: "main_nav_sdtm", main_nav_c: "main_nav_sdtm", main_nav_ssd: "main_nav_sdtm",
			main_nav_aig: "main_nav_adam", main_nav_aigd: "main_nav_adam"
		}
	end

	def ui_check_item_locked(id)
		section = id_to_section_map[id.to_sym]
		ui_expand_section(section) if !ui_section_expanded?(section)
		item = page.find('#'+id)
		expect(item[:class]).to include('locked')
		expect(item[:href]).to eq('')
	end

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

  def ui_navbar_click(id)
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

  def click_navbar_code_lists
    ui_navbar_click('main_nav_cl')
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
    ui_navbar_click('main_nav_sd')
  end

	def click_navbar_sdtm_model
    ui_navbar_click('main_nav_sm')
  end

  def click_navbar_ig
    ui_navbar_click('main_nav_sig')
  end

  def click_navbar_sdtm_class
    ui_navbar_click('main_nav_c')
  end

  def click_navbar_sdtm_sponsor_domains
    ui_navbar_click('main_nav_ssd')
  end

	#ADaM
	def click_navbar_adam_ig
    ui_navbar_click('main_nav_aig')
  end

  def click_navbar_adam_ig_dataset
    ui_navbar_click('main_nav_aigd')
  end

  #Community Version
  def click_browse_every_version
    click_link 'btn-browse-cdisc'
  end

  def click_search_the_latest_version
    click_link 'btn-search-latest'
  end

  def click_see_changes_all_versions
    click_link 'btn-see-changes'
  end

  def click_submission_value_changes
    click_link 'btn-submission-changes'
  end

	def click_show_latest_version
		click_link 'btn-browse-latest'
	end


  def ui_check_table_cell_extensible(table_id, row, col, text)
    cell = find(:xpath, "//table[@id='#{table_id}']/tbody/tr[#{row}]/td[#{col}]").has_css?(".icon-extend")
    expect(cell).to eq(text)
  end

	# Context Menu
	def context_menu_actions_map
	 {
      show: "Show",
      search: "Search",
      edit: "Edit",
      delete: "Delete",
      document_control: "Document control",
			export_csv: "Export CSV",
			subsets: "Subsets",
			extend: "Extend",
			extension: "Extension",
			extending: "Extending",
			change_notes: "Change notes",
			change_instructions: "Change instructions",
			edit_tags: "Edit tags",
      list_change_notes: "List Change notes",
      edit_properties: "Edit properties",
      impact_analysis: "Impact Analysis",
			make_current: "Make current",
			clone: "Clone",
			compare: "Compare",
			run: "Run",
			results: "Results",
      upgrade: "Upgrade Code Lists",
			enable_rank: "Enable rank",
			edit_ranks: "Edit ranks",
			pair: "Pair",
			unpair: "Unpair",
			show_paired: "Show Paired",
      crf: "CRF",
      acrf: "aCRF"
    }
	end

  def context_menu_element (table_id, column_nr, identifier, action, row_nr = nil )
  	context_menu_element_v2(table_id, identifier, action)
  end

	# Identifier is either a String (finds row that contains the text) or an Integer (finds row by its index nr)
	def context_menu_element_v2 (table, identifier, action)
		option = context_menu_actions_map[action]

		row = find(:xpath, "//table[@id='#{ table }']//tr[contains(.,'#{ identifier }')]") if identifier.is_a? String
		row = find(:xpath, "//table[@id='#{ table }']//tbody/tr[#{ identifier }]") if identifier.is_a? Integer

		within( row ) do
			find(".icon-context-menu").click
			sleep 0.2
			find( "a.option", exact_text: option ).click
		end
	end

	def context_menu_element_header (action)
		option = context_menu_actions_map[action]
		menu = find( '#header-con-menu' )
		menu.click
		sleep 0.2

		within( menu ) do
			find( "a.option", exact_text: option ).click
		end
	end

	def context_menu_element_header_present?(action, state="enabled")
		option = context_menu_actions_map[action]
		menu = find( '#header-con-menu' )
		class_list = state == "enabled" ?
								 ".option" :
								 ".option.disabled"

		result = menu.has_css?( class_list, exact_text: option, visible: false )
		result
	end

  def ui_dashboard_slider (start_date, end_date)
    slider = "var tl_slider = $('.timeline-container').data(); "
    slider += "tl_slider.moveToDate(tl_slider.l_slider, '#{start_date}'); "
    slider += "tl_slider.moveToDate(tl_slider.r_slider, '#{end_date}'); "
    page.execute_script(slider)
		sleep 0.6
  end

	def ui_dashboard_single_slider (date)
		slider = "var tl_slider = $('.timeline-container').data(); "
		slider += "tl_slider.moveToDate(tl_slider.l_slider, '#{date}'); "
		page.execute_script(slider)
		sleep 0.6
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

	# Create new Items

  def ui_create_terminology(id, label, success = true)
    click_navbar_terminology
		click_link 'New Terminology'
    ui_in_modal do
	    fill_in "thesauri_identifier", with: id
	    fill_in "thesauri_label", with: label
	    click_button 'Submit'
		end
		wait_for_ajax 10
		expect(page).to have_content 'Terminology was successfully created.' if success
  end

	def ui_new_code_list
		identifier = ui_next_parent_identifier
		click_link 'New Code List'
		wait_for_ajax 30
		expect(page).to have_content identifier
		wait_for_ajax 30
		identifier
	end

	def ui_create_form(identifier, label, success = true)
		click_navbar_forms
		wait_for_ajax 20
		expect(page).to have_content 'Index: Forms'
		click_on 'New Form'

		ui_in_modal do
			fill_in 'identifier', with: identifier
			fill_in 'label', with: label
			click_on 'Submit'
		end

		wait_for_ajax 10
		expect(page).to have_content "Version History of '#{identifier}'" if success
	end

	def ui_create_bc(identifier, label, template, success = true)
		click_navbar_bc
		wait_for_ajax 20
		expect(page).to have_content 'Index: Biomedical Concepts'
		click_on 'New Biomedical Concept'

		ui_in_modal do
			fill_in 'identifier', with: identifier
			fill_in 'label', with: label

			find('#new-item-template').click
			ip_pick_managed_items(:bct, [ { identifier: template[:identifier], version: template[:version] } ], 'new-bc')

			click_on 'Submit'
		end

		wait_for_ajax 10
		expect(page).to have_content "Version History of '#{identifier}'" if success
  end
  
  def ui_create_sdtm_sd(prefix, identifier, label, based_on, success = true)
    click_navbar_sdtm_sponsor_domains
    wait_for_ajax 10
    
    click_on 'New SDTM Sponsor Domain'
    ui_in_modal do
      fill_in 'prefix', with: prefix
      fill_in 'identifier', with: identifier
      fill_in 'label', with: label

      find('#new-item-base').click
      ip_pick_managed_items(based_on[:type], [ { identifier: based_on[:identifier], version: based_on[:version] } ], 'new-sdtm-sd')

      click_on 'Submit'
    end

		wait_for_ajax 10
		expect(page).to have_content "Version History of '#{identifier}'" if success
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

	# Confirmation Dialog
	def ui_confirmation_dialog(confirm)
		ui_confirmation_dialog_with_message(confirm, "Are you sure you want to proceed?")
	end

	def ui_confirmation_dialog_with_message(confirm, message)
		sleep 0.5
		expect(page).to have_content(message)
		if confirm
			click_button "Yes"
		else
			click_button "No"
		end
		sleep 0.5
	end

	# Tabs
	def ui_click_tab (name)
		page.find(".tab-option", :text => "#{name}").click
	end

  # D3 Tree Functions
  def ui_click_node_name(text)
    sleep 0.2
    page.evaluate_script("rhClickNodeByName(\"#{text}\")")
    sleep 0.2
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

  # Status Page
  def ui_manage_status_page(old_state, new_state, owner, identifier, version)
    expect(page).to have_content 'Manage Status'
    expect(page).to have_content "#{old_state}"
    expect(page).to have_content "#{new_state}"
    expect(page).to have_content "Owner: #{owner}"
    expect(page).to have_content "Identifier: #{identifier}"
    expect(page).to have_content version
  end

	# Keys
	def ui_press_key(key, with_key = nil)
		if with_key.nil?
			page.driver.browser.action.send_keys(key).perform
		else
			page.driver.browser.action.key_down(with_key).send_keys(key).key_up(with_key).perform
		end
	end


	# Items Selector ### DEPRECATED
	def ui_selector_check_tabs(tab_names)
		tab_names.each do |name|
			expect(find ".tabs-layout").to have_content(name)
		end
	end

	def ui_selector_check_tabs_gone(tab_names)
		tab_names.each do |name|
			expect(find "#selector-type-tabs .tabs-sel").not_to have_content(name)
		end
	end

	def ui_selector_tab_click(tab_text)
		find(:xpath, "//div[contains(concat(' ',normalize-space(@class), ' '),' tab-option') and contains(.,'#{tab_text}')]", visible: true).click
	end

	def ui_selector_item_click(table, text)
		find(:xpath, "//div[@id='selector-type-tabs']//table[@id='#{table}']//tr[contains(.,'#{text}')]", visible: true).click
		wait_for_ajax 20
	end

	def ui_selector_search(table, text)
		find(:xpath, "//div[@id='selector-type-tabs']//div[@id='#{table}_filter']//input", visible: true).set(text)
	end

	def ui_selector_pick_managed_items(type, items)
		ui_in_modal do
			ui_selector_tab_click(type)
			wait_for_ajax 20
			items.each do |i|
				ui_selector_search("index", i[:identifier])
				ui_selector_item_click("index", i[:identifier])
				ui_selector_search("history", i[:version])
				ui_selector_item_click("history", i[:version])
				ui_selector_item_click("index", i[:identifier])
			end
			find("#selector-modal-submit").click
			wait_for_ajax 10
		end
	end

	def ui_selector_pick_unmanaged_items(type, items)
		ui_in_modal do
			ui_selector_tab_click(type)
			wait_for_ajax 20
			items.each do |i|
				ui_selector_search("index", i[:parent])
				ui_selector_item_click("index", i[:parent])
				ui_selector_search("history", i[:version])
				ui_selector_item_click("history", i[:version])
				ui_selector_search("children", i[:identifier])
				ui_selector_item_click("children", i[:identifier])

				ui_selector_item_click("history", i[:version])
				ui_selector_item_click("index", i[:parent])
			end
			find("#selector-modal-submit").click
			wait_for_ajax 10
		end
	end

	# Modals

	def ui_in_modal
		sleep 1
		wait_for_ajax 20
		yield
		sleep 1
	end


private

  def ui_next_parent_identifier
    configuration = Rails.configuration.thesauri[:identifiers][:parent][:generated]
    value = nv_predict_parent
    pattern = configuration[:pattern].dup
    pattern.sub!("[identifier]", '%0*d' % [configuration[:width].to_i, value])
  end

end
