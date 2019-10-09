module UserAccountHelpers

	C_PASSWORD = "Changeme1#"
	C_CURATOR = "curator@example.com"
	C_READER = "reader@example.com"
	C_SYS_ADMIN = "sys_admin@example.com"
	C_CONTENT_ADMIN = "content_admin@example.com"
  C_TERM_READER = "term_reader@example.com"
	C_TERM_CURATOR = "term_curator@example.com"
  C_COMM_READER = "comm_reader@example.com"

  def ua_create
    @user_c = User.create :email => C_CURATOR, :password => C_PASSWORD
    @user_c.add_role :curator
    @user_c.remove_role :reader # Get reader on the create
		unforce_first_pass_change @user_c
    @user_r = User.create :email => C_READER, :password => C_PASSWORD
    @user_r.add_role :reader
		unforce_first_pass_change @user_r
    @user_sa = User.create :email => C_SYS_ADMIN, :password => C_PASSWORD
    @user_sa.add_role :sys_admin # Sys Admin will have reader access here.
		@user_sa.remove_role :reader # Get reader on the create
		unforce_first_pass_change @user_sa
    @user_ca = User.create :email => C_CONTENT_ADMIN, :password => C_PASSWORD
    @user_ca.add_role :content_admin
    @user_ca.remove_role :reader # Get reader on the create
		unforce_first_pass_change @user_ca
    @user_tr = User.create :email => C_TERM_READER, :password => C_PASSWORD
    @user_tr.add_role :term_reader
    @user_tr.remove_role :reader # Get reader on the create
		unforce_first_pass_change @user_tr
    @user_tc = User.create :email => C_TERM_CURATOR, :password => C_PASSWORD
    @user_tc.add_role :term_curator
    @user_tc.remove_role :reader # Get reader on the create
		unforce_first_pass_change @user_tc
    @user_cr = User.create :email => C_COMM_READER, :password => C_PASSWORD
    @user_cr.add_role :community_reader
    @user_cr.remove_role :reader # Get reader on the create
		unforce_first_pass_change @user_cr
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
    user = User.where(:email => C_COMM_READER).first
    user.destroy
  end

  def ua_reader_login
  	ua_generic_login C_READER
  end

  def ua_curator_login
  	ua_generic_login C_CURATOR
  end

  def ua_content_admin_login
  	ua_generic_login C_CONTENT_ADMIN
  end

  def ua_sys_admin_login
  	ua_generic_login C_SYS_ADMIN
  end

  def ua_term_reader_login
  	ua_generic_login C_TERM_READER
  end

  def ua_term_curator_login
  	ua_generic_login C_TERM_CURATOR
  end

  # Deprecate, use the pne below, just a better name
  def ua_comm_reader_login
    ua_generic_login C_COMM_READER, C_PASSWORD
  end

  def ua_community_reader_login
    ua_generic_login C_COMM_READER, C_PASSWORD
  end

  def ua_logoff
  	click_on 'logoff_button'
  end

  def ua_generic_login(email, password=C_PASSWORD)
  	visit "/users/sign_in"
    fill_in :placeholder => "Email", :with => email
    fill_in :placeholder => "Password", :with => password
    click_button "Log in"
    expect(page).to have_content "Signed in successfully"
  end

	# Custom users
	def ua_add_user(args)
		args[:password] = C_PASSWORD if !args.key?(:password)
		args[:role] = :reader if !args.key?(:role)

		@usr = User.create :email => args[:email], :password => args[:password]
		@usr.add_role args[:role]
		unforce_first_pass_change @usr
		return @usr
	end

	def ua_remove_user(email)
		User.where(:email => email).first.destroy
	end

	def unforce_first_pass_change(user)
		user.password_changed_at = Time.now
		user.save
	end

end
