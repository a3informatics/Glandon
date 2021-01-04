  
  C_CURATOR = "curator@s-cubed.dk"
  C_READER = "reader@s-cubed.dk"
  C_SYS_ADMIN = "sysadmin@s-cubed.dk"
  C_CONTENT_ADMIN = "contadmin@s-cubed.dk"
  C_TERM_READER = "termreader@s-cubed.dk"
  C_TERM_CURATOR = "termcurator@s-cubed.dk"
  C_COMM_READER = "community@s-cubed.dk"
  C_SYS_CONTENT_ADMIN = "admin@s-cubed.dk"
  
 C_PASSWORD = "Changeme1?" # on localhost
#C_PASSWORD = "Changeme10?" #on VAL for community reader

if ENVIRONMENT == 'TEST'
  Given('I am signed in successfully as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => C_PASSWORD
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => C_PASSWORD
    end
    click_button "Log in"
    expect(page).to have_text string
    expect(page).to have_text 'Signed in successfully'
  end
end

if ENVIRONMENT == 'VAL'
  Given('I am signed in successfully as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => 'Changeme11?'
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => 'Changeme5?'
    end
    click_button "Log in"
    expect(page).to have_text string
    expect(page).to have_text 'Signed in successfully'
  end
end

if ENVIRONMENT == 'REMOTE_TEST'
  Given('I am signed in successfully as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => 'Changeme2?'
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => 'Changeme2?'
    end
    click_button "Log in"
    expect(page).to have_text string
    expect(page).to have_text 'Signed in successfully'
  end
end

