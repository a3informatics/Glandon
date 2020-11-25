module RemoteServerHelpers

  @server_address = 'https://mdr-v1.s-cubed-global.com/'
  @server_address_t = 'https://mdr-t1.s-cubed-global.com/'

  def self.switch_to_remote
    Capybara.app_host = @server_address
    Capybara.run_server = false
  end

  def self.switch_to_remote_test
    Capybara.app_host = @server_address_t
    Capybara.run_server = false
  end

  def self.switch_to_local
    Capybara.run_server = true
  end

  # C_PASSWORD = "Changeme1#"
  # C_CURATOR = "curator@example.com"
  # C_READER = "reader@example.com"
  # C_SYS_ADMIN = "sys_admin@example.com"
  # C_CONTENT_ADMIN = "content_admin@example.com"
  # C_TERM_READER = "term_reader@example.com"
  # C_TERM_CURATOR = "term_curator@example.com"
  # C_COMM_READER = "comm_reader@example.com"

  # def ua_generic_login(email, password=C_PASSWORD)
  #   visit "/users/sign_in"
  #   fill_in :placeholder => "Email", :with => email
  #   fill_in :placeholder => "Password", :with => password
  #   click_button "Log in"
  #   expect(page).to have_content "Signed in successfully"
  # end

  # def ua_reader_login
  #   ua_generic_login C_READER
  # end

  # def ua_curator_login
  #   ua_generic_login C_CURATOR
  # end

  # def ua_content_admin_login
  #   ua_generic_login C_CONTENT_ADMIN
  # end

  # def ua_sys_admin_login
  #   ua_generic_login C_SYS_ADMIN
  # end

  # def ua_term_reader_login
  #   ua_generic_login C_TERM_READER
  # end

  # def ua_term_curator_login
  #   ua_generic_login C_TERM_CURATOR
  # end

  # # Deprecate, use the pne below, just a better name
  # def ua_comm_reader_login
  #   ua_generic_login C_COMM_READER, C_PASSWORD
  # end

  # def ua_community_reader_login
  #   ua_generic_login C_COMM_READER, C_PASSWORD
  # end

  # def ua_logoff
  #   click_on 'logoff_button'
  # end

end