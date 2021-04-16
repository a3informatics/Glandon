#################### When statements 

When('I access the Manage users menu from the top navigation bar') do 
  click_link 'users_button'
end

When('I click on the lock for the {string} Role') do |string|
  if string == "Community Reader"
    find(:xpath, "//tr[contains(.,'community@s-cubed.dk')]/td/a", :class => 'lock-user').click
  end
end

When('I click on the unlock for the {string} Role') do |string|
  if string == "Community Reader"
    find(:xpath, "//tr[contains(.,'community@s-cubed.dk')]/td/a", :class => 'unlock-user').click
  end
end

When('I enter current password') do 
     fill_in 'user_current_password', with: C_COMM_READER_PW
end
When('I enter new password') do
     fill_in 'user_password', with: C_COMM_READER_PW_NEW
end
When ('I enter confirm new password') do
    fill_in 'user_password_confirmation', with: C_COMM_READER_PW_NEW
end

When('I click Update button for password change') do
    click_button 'password-update-btn'
end

When ('I log on as Community Reader with new password') do
    visit "/users/sign_in"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => C_COMM_READER_PW_NEW
    click_button "Log in"
end

##################### Then statements 
Then('I see the Users management page') do
  expect(page).to have_content "Users"
  wait_for_ajax(20)
  save_screen(TYPE)
 end

Then('I see the message {string}') do |string|
  expect(page).to have_content string
  wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I see the User Settings page') do
    expect(page).to have_content 'User Settings'
    expect(page).to have_content 'Preferences'
      wait_for_ajax(20)
  save_screen(TYPE)
end

Then('I am signed in successfully as Community Reader') do
    expect(page).to have_text "Community Reader"
    expect(page).to have_text 'Signed in successfully'
    wait_for_ajax(20)
   save_screen(TYPE)
end


