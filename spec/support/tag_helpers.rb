module TagHelper

  def create_classification
      click_navbar_dashboard
      expect(page).to have_content 'Registration Status Counts'
      click_navbar_tags
      expect(page).to have_content 'Classifications'
      click_link 'New'
      fill_in 'iso_concept_system_label', with: 'Root'
      fill_in 'iso_concept_system_description', with: 'Tag Classification'
      click_button 'Create'
      expect(page).to have_content 'Concept system was successfully created.'
    end

  def create_tag_first_level(label, description)
      click_navbar_tags
      expect(page).to have_content 'Tag Viewer'
      ui_check_input("edit_label", 'Tags')
      fill_in 'add_label', with: "#{label}"
      fill_in 'add_description', with: "#{description}"
      click_on 'Create tag'
      expect(page).to have_content("#{label}")
      #click_link 'Close'
  end

  def create_tag_child(parent, label, description)
      click_navbar_tags
      expect(page).to have_content 'Tag Viewer'
      ui_click_node_name ("#{parent}")
      ui_check_input("edit_label", "#{parent}")
      fill_in 'add_label', with: "#{label}"
      fill_in 'add_description', with: "#{description}"
      click_on 'Create tag'
      expect(page).to have_content "#{label}"
  end

  def create_tag_form(identifier, label)
    # click_navbar_dashboard
    click_navbar_forms
    expect(page).to have_content 'Index: Forms'
    click_link 'New'
    fill_in 'form_identifier', with: "#{identifier}"
    fill_in 'form_label', with: "#{label}"
    click_button 'Create'
    expect(page).to have_content 'Form was successfully created.'
  end

  def create_tag_bc(identifier, label, template)
    # click_navbar_dashboard
    click_navbar_bc
    wait_for_ajax
    expect(page).to have_content 'Index: Biomedical Concepts'
    click_link 'New'
    fill_in "biomedical_concept_identifier", with: "#{identifier}"
    fill_in "biomedical_concept_label", with: "#{label}"
    ui_table_row_click("ims_list_table", "#{template}")
    ui_click_by_id("ims_add_button")
    click_button 'Create'
    expect(page).to have_content 'Biomedical Concept was successfully created.'
  end

  def create_tag_term(identifier, label)
      # click_navbar_dashboard
      click_navbar_terminology
      expect(page).to have_content 'All Terminologies'
      click_link 'New Terminology'
      fill_in 'thesauri_identifier', with: "#{identifier}"
      fill_in 'thesauri_label', with: "#{label}"
      click_button 'Submit'
      expect(page).to have_content 'Terminology was successfully created.'
    end

  def add_tags_term(identifier, tag)
    # click_navbar_dashboard
    click_navbar_terminology
    expect(page).to have_content 'All Terminologies'
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
    expect(page).to have_content 'Version history'
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Update Tags').click
    expect(page).to have_content 'Edit Tags:'
    ui_click_node_name("#{tag}") #{tag}"
    ui_click_tag_add
  end

end
