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

  def create_tag(parent, label, description)
   # visit '/users/sign_in'
   # expect(page).to have_content 'Email'
   # fill_in 'Email', with: 'form_edit@example.com'
   # fill_in 'Password', with: '12345678'
   # click_button 'Log in'
    #expect(page).to have_content 'Signed in successfully'  
      click_link 'Dashboard'
      expect(page).to have_content 'Registration Status Counts'   
      click_link 'Tags'
      expect(page).to have_content 'Classifications'  
      find(:xpath, "//tr[contains(.,'Root')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Root'
      click_link 'New'
      fill_in 'iso_concept_system_label', with: "#{label}"
      fill_in 'iso_concept_system_description', with: "#{description}"
      click_button 'Create'
      expect(page).to have_content 'Concept system node was successfully created.'   
    #click_link 'Tags'
    #expect(page).to have_content 'Manage Tags'  
    #ui_click_node_name "#{parent}"
    #fill_in 'Add New Tag', with: "#{label}"
    #fill_in 'Description', with: "#{description}"
     # #fill_in 'iso_concept_system_label', with: 'Tag1'
     # #fill_in 'iso_concept_system_description', with: 'Tag 1'
    # click_button 'Add'
    # expect(page).to have_content("#{label}")
    # click_link 'Close'
  end

  def create_tag_child(parent, identifier, label)
      click_link 'Dashboard'
      expect(page).to have_content 'Registration Status Counts'   
      click_link 'Tags'
      expect(page).to have_content 'Classifications'  
      find(:xpath, "//tr[contains(.,'Root')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Root'
      find(:xpath, "//tr[contains(.,#{parent})]/td/a", :text => 'Show').click
      click_link 'New'
      fill_in 'iso_concept_system_label', with: "#{identifier}"
      fill_in 'iso_concept_system_description', with: "#{label}"
      click_button 'Create'
      pause
      expect(page).to have_content 'Concept system node was successfully created.' 
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
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Tags').click
    expect(page).to have_content 'Edit Tags:'
    ui_click_node_name("#{tag}") #{tag}"
    #expect(display_label).to have_content "#{tag}"
    ui_click_tag_add
    #ui_check_table_cell("iso_managed_tag_table", 1, 1, "#{tag}")
    #ui_click_save
    #ui_click_close
  end

end