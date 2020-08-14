module QualificationUserHelpers


  C_PASSWORD = "Changeme1?"
  C_CURATOR = "curator@s-cubed.dk"
  C_READER = "reader@s-cubed.dk"
  C_SYS_ADMIN = "sysadmin@s-cubed.dk"
  C_CONTENT_ADMIN = "contadmin@s-cubed.dk"
  C_TERM_READER = "termreader@s-cubed.dk"
  C_TERM_CURATOR = "termcurator@s-cubed.dk"
  C_COMM_READER = "community@s-cubed.dk"
  C_SYS_CONTENT_ADMIN = "admin@s-cubed.dk"


def quh_create
    @user_c = User.create :email => C_CURATOR, :password => C_PASSWORD,:name => "Curator"
    @user_c.add_role :curator
    @user_c.remove_role :reader # Get reader on the create
    unforce_first_pass_change @user_c
    @user_r = User.create :email => C_READER, :password => C_PASSWORD,:name => "Full Reader"
    @user_r.add_role :reader
    unforce_first_pass_change @user_r
    @user_sa = User.create :email => C_SYS_ADMIN, :password => C_PASSWORD,:name => "Community Reader"
    @user_sa.add_role :sys_admin # Sys Admin will have reader access here.
    @user_sa.remove_role :reader # Get reader on the create
    unforce_first_pass_change @user_sa
    @user_ca = User.create :email => C_CONTENT_ADMIN, :password => C_PASSWORD,:name => "Content Admin"
    @user_ca.add_role :content_admin
    @user_ca.remove_role :reader # Get reader on the create
    unforce_first_pass_change @user_ca
    @user_tr = User.create :email => C_TERM_READER, :password => C_PASSWORD,:name => "Term Reader"
    @user_tr.add_role :term_reader
    @user_tr.remove_role :reader # Get reader on the create
    unforce_first_pass_change @user_tr
    @user_tc = User.create :email => C_TERM_CURATOR, :password => C_PASSWORD,:name => "CT Curator"
    @user_tc.add_role :term_curator
    @user_tc.remove_role :reader # Get reader on the create
    unforce_first_pass_change @user_tc
    @user_cr = User.create :email => C_COMM_READER, :password => C_PASSWORD,:name => "Community Reader"
    @user_cr.add_role :community_reader
    @user_cr.remove_role :reader # Get reader on the create
    unforce_first_pass_change @user_cr
    @user_sca = User.create :email => C_SYS_CONTENT_ADMIN, :password => C_PASSWORD, :name => "Admin"
    @user_sca.add_role :sys_admin
    @user_sca.add_role :content_admin
    @user_sca.remove_role :reader # Get reader on the create
    unforce_first_pass_change @user_sca
  end

  def quh_destroy
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
    user = User.where(:email => C_SYS_CONTENT_ADMIN).first
    user.destroy
  end

  def quh_reader_login
    quh_generic_login C_READER
  end

  def quh_curator_login
    quh_generic_login C_CURATOR
  end

  def quh_content_admin_login
    quh_generic_login C_CONTENT_ADMIN
  end

  def quh_sys_admin_login
    quh_generic_login C_SYS_ADMIN
  end

  def quh_term_reader_login
    quh_generic_login C_TERM_READER
  end

  def quh_term_curator_login
    quh_generic_login C_TERM_CURATOR
  end

  def quh_community_reader_login
    quh_generic_login C_COMM_READER
  end

  def quh_sys_and_content_admin_login
    quh_generic_login C_SYS_CONTENT_ADMIN
  end

  def quh_logoff
    click_on 'logoff_button'
  end

  def quh_generic_login(email, password=C_PASSWORD)
    visit "/users/sign_in"
    fill_in :placeholder => "Email", :with => email
    fill_in :placeholder => "Password", :with => password
    click_button "Log in"
    expect(page).to have_content "Signed in successfully"
  end

  # Custom users
  def quh_add_user(args)
    args[:password] = C_PASSWORD if !args.key?(:password)
    args[:role] = :reader if !args.key?(:role)
    @usr = User.create :email => args[:email], :password => args[:password]
  puts colourize("***** User create error: #{@usr.errors.full_messages.to_sentence}. Args: #{args} *****", "red") if @usr.errors.any?
    @usr.add_role args[:role]
    unforce_first_pass_change @usr
    return @usr
  end

  def quh_remove_user(email)
    User.where(:email => email).first.destroy
  end

  def unforce_first_pass_change(user)
    user.password_changed_at = Time.now
    user.save
  end

end
