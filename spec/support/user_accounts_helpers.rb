module UserAccountHelpers

	C_PASSWORD = "12345678"
	C_CURATOR = "curator@example.com"
	C_READER = "reader@example.com"
	C_SYS_ADMIN = "sys_admin@example.com"
	C_CONTENT_ADMIN = "content_admin@example.com"
  C_TERM_READER = "term_reader@example.com"
	C_TERM_CURATOR = "term_curator@example.com"
  
  def ua_create
    @user_c = User.create :email => C_CURATOR, :password => C_PASSWORD 
    @user_c.add_role :curator
    @user_c.remove_role :reader # Get reader on the create
    @user_r = User.create :email => C_READER, :password => C_PASSWORD 
    @user_r.add_role :reader
    @user_sa = User.create :email => C_SYS_ADMIN, :password => C_PASSWORD 
    @user_sa.add_role :sys_admin # Sys Admin will have reader access here.
    @user_sa.remove_role :reader # Get reader on the create
    @user_ca = User.create :email => C_CONTENT_ADMIN, :password => C_PASSWORD 
    @user_ca.add_role :content_admin
    @user_ca.remove_role :reader # Get reader on the create
    @user_tr = User.create :email => C_TERM_READER, :password => C_PASSWORD 
    @user_tr.add_role :term_reader
    @user_tr.remove_role :reader # Get reader on the create
    @user_tc = User.create :email => C_TERM_CURATOR, :password => C_PASSWORD 
    @user_tc.add_role :term_curator
    @user_tc.remove_role :reader # Get reader on the create
  end

  def ua_destroy
    user = User.where(:email => C_CURATOR).first
    user.destroy
    user = User.where(:email => C_READER).first
    user.destroy
    user = User.where(:email => C_SYS_ADMIN).first
    user.destroy
    user = User.where(:email => C_CONTENT_ADMIN).first
    user.destroy
    user = User.where(:email => C_TERM_READER).first
    user.destroy
    user = User.where(:email => C_TERM_CURATOR).first
    user.destroy
  end

  def ua_reader_login
  	ua_generic_login C_READER, C_PASSWORD
  end  

  def ua_curator_login
  	ua_generic_login C_CURATOR, C_PASSWORD
  end  

  def ua_content_admin_login
  	ua_generic_login C_CONTENT_ADMIN, C_PASSWORD
  end  

  def ua_sys_admin_login
  	ua_generic_login C_SYS_ADMIN, C_PASSWORD
  end

  def ua_term_reader_login
  	ua_generic_login C_TERM_READER, C_PASSWORD
  end

  def ua_term_curator_login
  	ua_generic_login C_TERM_CURATOR, C_PASSWORD
  end

  def ua_logoff
  	click_link "logoff_button"
  end

  def generic_login(email, password)
  	visit "/users/sign_in"
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Log in"
    expect(page).to have_content "Signed in successfully"
  end

end