module UserAccountHelpers

  def ua_create
    @user_c = User.create :email => "curator@example.com", :password => "12345678" 
    @user_c.add_role :curator
    @user_r = User.create :email => "reader@example.com", :password => "12345678" 
    @user_r.add_role :reader
    @user_sa = User.create :email => "sys_admin@example.com", :password => "12345678" 
    @user_sa.add_role :sys_admin
    @user_ca = User.create :email => "content_admin@example.com", :password => "12345678" 
    @user_ca.add_role :content_admin
  end

  def ua_destroy
    user = User.where(:email => "curator@example.com").first
    user.destroy
    user = User.where(:email => "reader@example.com").first
    user.destroy
    user = User.where(:email => "sys_admin@example.com").first
    user.destroy
    user = User.where(:email => "content_admin@example.com").first
    user.destroy
  end

end