module TagHelper

  def create_classification
      click_link 'Dashboard'
      expect(page).to have_content 'Registration Status Counts'   
      click_link 'Tags'
      expect(page).to have_content 'Classifications'  
      click_link 'New'
      fill_in 'iso_concept_system_label', with: 'Root'
      fill_in 'iso_concept_system_description', with: 'Tag Classification'
      click_button 'Create'
      expect(page).to have_content 'Concept system was successfully created.'
    end

  def create_tag_first_level(label, description)
      click_link 'Dashboard'
      expect(page).to have_content 'Registration Status Counts'   
      click_link 'Tags'
      expect(page).to have_content 'Tag Viewer'  
      ui_check_input("edit_label", 'Tags')
      fill_in 'add_label', with: "#{label}"
      fill_in 'add_description', with: "#{description}"
      click_button 'Add tag'
      expect(page).to have_content("#{label}")
      #click_link 'Close'
  end

  def create_tag_child(parent, identifier, label)
      click_link 'Dashboard'
      expect(page).to have_content 'Registration Status Counts'   
      click_link 'Tags'
      expect(page).to have_content 'Tag Viewer'  
      ui_click_node_name ("#{parent}")
      ui_check_input("edit_label", "#{parent}")
      fill_in 'add_label', with: "#{identifier}"
      fill_in 'add_description', with: "#{label}"
      click_button 'Add tag'
      expect(page).to have_content "#{identifier}" 
  end

  def create_tag_form(identifier, label)
    click_link 'Forms'
    expect(page).to have_content 'Index: Forms'  
    click_link 'New'
    fill_in 'form_identifier', with: "#{identifier}"
    fill_in 'form_label', with: "#{label}"
    click_button 'Create'
    expect(page).to have_content 'Form was successfully created.'
  end

  def create_tag_bc(identifier, label, template)
    #ui_scroll_to_id("biomedical_concept_identifier")
    click_link 'Biomedical Concepts'
    wait_for_ajax
    expect(page).to have_content 'Index: Biomedical Concepts'  
    click_link 'New'
    fill_in "biomedical_concept_identifier", with: "#{identifier}"
    fill_in "biomedical_concept_label", with: "#{label}"
    ui_table_row_click("ims_list_table", "#{template}")
    ui_click_by_id("ims_add_button")
    click_button 'Create'
    expect(page).to have_content 'Biomedical Concept was successfully created.'
    #expect(page).to have_content("The Biomedical Concept was succesfully created.") 
  end

  def create_tag_term(identifier, label)
      click_link 'Terminology'
      expect(page).to have_content 'Index: Terminology'
      click_link 'New'
      expect(page).to have_content 'New Terminology:'
      fill_in 'thesauri_identifier', with: "#{identifier}"
      fill_in 'thesauri_label', with: "#{label}"
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
    end
 
  def add_tags(link, identifier, tag)
    click_link "#{link}"
    expect(page).to have_content 'Index:' 
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'History').click
    expect(page).to have_content 'History:'  
    # find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Edit').click
    # expect(page).to have_content 'Edit:'  
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Update Tags').click
    expect(page).to have_content 'Edit Tags:'
    ui_click_node_name("#{tag}") #{tag}"
    #expect(display_label).to have_content "#{tag}"
    ui_click_tag_add
    #ui_check_table_cell("iso_managed_tag_table", 1, 1, "#{tag}")
    #ui_click_save
    #ui_click_close
  end

end