module FormHelpers

  def create_form(identifier, label, new_label)
    visit '/users/sign_in'
    expect(page).to have_content 'Email'
    fill_in 'Email', with: 'form_edit@example.com'
    fill_in 'Password', with: '12345678'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'  
    click_link 'Forms'
    expect(page).to have_content 'Index: Forms'  
    click_link 'New'
    fill_in 'form_identifier', with: "#{identifier}"
    fill_in 'form_label', with: "#{label}"
    click_button 'Create'
    expect(page).to have_content 'Form was successfully created.'
    ui_main_show_all
    ui_table_row_link_click("#{identifier}", "History")
    expect(page).to have_content "History: #{identifier}"
    ui_table_row_link_click("#{identifier}", "Edit")
    fill_in 'formLabel', with: "#{new_label}"
  end

  def load_form(identifier)
    visit '/users/sign_in'
    expect(page).to have_content 'Email'
    fill_in 'Email', with: 'form_edit@example.com'
    fill_in 'Password', with: '12345678'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'  
    click_link 'Forms'
    expect(page).to have_content 'Index: Forms' 
    ui_main_show_all
    expect(page).to have_content "#{identifier}" 
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'History').click
    expect(page).to have_content 'History:'  
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Edit').click
    expect(page).to have_content 'Edit:'  
  end

  def reload_form(identifier)
    click_link 'main_nav_f'
    expect(page).to have_content 'Index: Forms' 
    ui_main_show_all
    expect(page).to have_content "#{identifier}" 
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'History').click
    expect(page).to have_content 'History:'  
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Edit').click
    expect(page).to have_content 'Edit:'  
  end

end