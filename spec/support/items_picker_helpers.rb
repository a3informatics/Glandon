module ItemsPickerHelpers

  # Items Picker Helpers

  @@types_map = {
    thesauri: {
      pl: "Terminologies",
      s: "Terminology"
    },
    managed_concept: {
      pl: "Code Lists",
      s: "Code List",
    },
    unmanaged_concept: {
      pl: "Code List Items",
      s: "Code List Item"
    },
    bci: {
      pl: "Biomedical Concepts",
      s: "Biomedical Concept"
    },
    bct: {
      pl: "Biomedical Concept Templates",
      s: "Biomedical Concept Template"
    },
    form: {
      pl: "Forms",
      s: "Form"
    }
  }

  def ip_check_tabs(tab_types, id)
    tab_types.each do |type|
      expect(find "#items-picker-#{id} #items-picker-tabs").to have_content(@@types_map[type][:pl])
    end
  end

  def ip_check_tabs_gone(tab_types, id)
    tab_types.each do |type|
      expect(find "#items-picker-#{id} #items-picker-tabs").not_to have_content(@@types_map[type][:pl])
    end
  end

  def ip_click_tab(tab_type, id)
    find("#items-picker-#{id} .tab-option", text: @@types_map[tab_type][:pl], visible: true).click
  end

  def ip_item_click(table, id, text)
    find(:xpath, "//div[@id='items-picker-#{id}']//table[@id='#{table}']//tr[contains(.,'#{text}')]", visible: true).click
    wait_for_ajax 20
  end

  def ip_search(table, id, text)
    find(:xpath, "//div[@id='items-picker-#{id}']//div[@id='#{table}_filter']//input", visible: true).set(text)
  end

  def ip_check_selected_info(text, id)
    expect(find(:xpath, "//div[@id='items-picker-#{id}']//span[@id='selected-info']").text).to eq(text)
  end

  def ip_submit(id)
    find("#items-picker-#{id} #items-picker-submit").click
    wait_for_ajax 10
  end

  def ip_clear_selection(id)
    find("#items-picker-#{id} #clear-selection").click
  end

  def ip_remove_from_selection(items, id)
    find("#items-picker-#{id} #view-selection").click

    ui_in_modal do
      items.each do |i|
        find(:xpath, "//div[@id='items-picker-#{id}']//span[contains(concat(' ',normalize-space(@class), ' '),' bg-label') and contains(.,'#{i}')]", visible: true).click
      end
      click_on 'Dismiss'
    end

  end

  def ip_pick_managed_items(type, items, id, submit = true)
    ui_in_modal do
      ip_click_tab(type, id)
      wait_for_ajax 20
      items.each do |i|
        if i.key?:owner # Searches owner + identifier if owner specified
          ip_search("index", id, "#{ i[:owner] } #{ i[:identifier] }")
        else              # Searches identifier only
          ip_search("index", id, i[:identifier])
        end
        ip_item_click("index", id, i[:identifier])
        ip_search("history", id, i[:version])
        ip_item_click("history", id, i[:version])
        ip_item_click("index", id, i[:identifier])
      end

      ip_submit(id) if submit
    end
  end

  def ip_pick_unmanaged_items(type, items, id, submit = true)
    ui_in_modal do
      ip_click_tab(type, id)
      wait_for_ajax 20
      items.each do |i|
        if i.key? :owner # Searches owner + parent if owner specified
          ip_search("index", id, "#{ i[:owner] } #{ i[:parent] }")
        else              # Searches parent only
          ip_search("index", id, i[:parent])
        end
        ip_item_click("index", id, i[:parent])
        ip_search("history", id, i[:version])
        ip_item_click("history", id, i[:version])
        ip_search("children", id, i[:identifier])
        ip_item_click("children", id, i[:identifier])

        ip_item_click("history", id, i[:version])
        ip_item_click("index", id, i[:parent])
      end

      ip_submit(id) if submit
    end
  end

end
