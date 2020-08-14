Given('I am on login page') do
  visit "/users/sign_in"
end

Then('I should see {string}') do |string|
 expect(page).to have_text string
end

