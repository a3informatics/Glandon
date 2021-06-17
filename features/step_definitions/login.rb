  
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

if ENVIRONMENT == 'VAL' 
C_COMM_READER_PW = 'Changeme22?'
C_COMM_READER_PW_NEW = 'Changeme23?'
C_CURATOR_PW ='Changeme9?'
C_SYS_CONTENT_ADMIN_PW ='Changeme12?'
end

if ENVIRONMENT == 'REMOTE_TEST' 
C_COMM_READER_PW = 'Changeme5?'
C_COMM_READER_PW_NEW = 'Changeme6?'
C_CURATOR_PW = 'Changeme7?'
C_SYS_CONTENT_ADMIN_PW = 'Changeme6?'
C_CONTENT_ADMIN_PW = 'Changeme5?'
end

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
    if string == "Admin"
    fill_in "Email", :with => C_SYS_CONTENT_ADMIN
    fill_in "Password", :with => C_PASSWORD
    end
    if string == "Content Admin"
    fill_in "Email", :with => C_CONTENT_ADMIN
    fill_in "Password", :with => C_PASSWORD
    end
    click_button "Log in"
    expect(page).to have_text 'Signed in successfully'
  end
end

if ENVIRONMENT == 'VAL'
  Given('I am signed in successfully as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => C_COMM_READER_PW
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => C_CURATOR_PW
    end
    if string == "Admin"
    fill_in "Email", :with => C_SYS_CONTENT_ADMIN
    fill_in "Password", :with => C_SYS_CONTENT_ADMIN_PW
    end
    if string == "Content Admin"
    fill_in "Email", :with => C_CONTENT_ADMIN
    fill_in "Password", :with => C_PASSWORD
    end
    click_button "Log in"
    expect(page).to have_text string
    expect(page).to have_text 'Signed in successfully'
  end
end

if ENVIRONMENT == 'PROD'
  Given('I am signed in successfully as {string}') do |string|
    visit "/users/sign_in"
    if string == "Curator"
    fill_in "Email", :with => 'kl@s-cubed.dk'
    pause
  
    end
    click_button "Log in"
    expect(page).to have_text 'Content Admin, System Admin'
    expect(page).to have_text 'Signed in successfully'
  end
end

if ENVIRONMENT == 'REMOTE_TEST'
  Given('I am signed in successfully as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => C_COMM_READER_PW
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => C_CURATOR_PW
    end
    if string == "Admin"
    fill_in "Email", :with => C_SYS_CONTENT_ADMIN
    fill_in "Password", :with => C_SYS_CONTENT_ADMIN_PW
    end
    if string == "Content Admin"
    fill_in "Email", :with => C_CONTENT_ADMIN
    fill_in "Password", :with => C_CONTENT_ADMIN_PW
    end
    click_button "Log in"
    expect(page).to have_text string
    expect(page).to have_text 'Signed in successfully'
  end
end

When('I log off as {string}') do |string|
 ua_logoff
end

if ENVIRONMENT == 'TEST'
  When('I log on as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => C_PASSWORD
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => C_PASSWORD
    end
    if string == "Admin"
    fill_in "Email", :with => C_SYS_CONTENT_ADMIN
    fill_in "Password", :with => C_PASSWORD
    end
    click_button "Log in"
    expect(page).to have_text string
    expect(page).to have_content "Signed in successfully"
 end
end

if ENVIRONMENT == 'VAL'
When('I log on as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => C_COMM_READER_PW
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => C_CURATOR_PW
    end
    if string == "Admin"
    fill_in "Email", :with => C_SYS_CONTENT_ADMIN
    fill_in "Password", :with => C_SYS_CONTENT_ADMIN_PW
    end
    click_button "Log in"
    expect(page).to have_text string
    expect(page).to have_content "Signed in successfully"
 end
end

if ENVIRONMENT == 'REMOTE_TEST'
When('I log on as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => C_COMM_READER_PW
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => C_CURATOR_PW
    end
    if string == "Admin"
    fill_in "Email", :with => C_SYS_CONTENT_ADMIN
    fill_in "Password", :with => C_SYS_CONTENT_ADMIN_PW
    end
    click_button "Log in"
    expect(page).to have_text string
    expect(page).to have_content "Signed in successfully"
 end
end

if ENVIRONMENT == 'TEST'
  When('I try to log on as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => C_PASSWORD
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => C_PASSWORD
    end
  pause
    click_button "Log in"
 end 
end

if ENVIRONMENT == 'VAL'
When('I try to log on as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => C_COMM_READER_PW
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => C_CURATOR_PW
    end
    click_button "Log in"
 end 
end

if ENVIRONMENT == 'REMOTE_TEST'
When('I try to log on as {string}') do |string|
    visit "/users/sign_in"
    if string == "Community Reader"
    fill_in "Email", :with => C_COMM_READER
    fill_in "Password", :with => C_COMM_READER_PW
    end 
    if string == "Curator"
    fill_in "Email", :with => C_CURATOR
    fill_in "Password", :with => C_CURATOR_PW
    end
    click_button "Log in"
 end 
end


