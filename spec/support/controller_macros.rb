module ControllerMacros
  
  C_PASSWORD = "Changeme1%"
  C_EMAIL = "base@example.com"
  
  def login_admin
    #before(:each) do
    #  @request.env["devise.mapping"] = Devise.mappings[:admin]
    #  sign_in FactoryGirl.create(:admin) # Using factory girl as an example
    #end
  end

  def login_no_role
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.create :email => C_EMAIL, :password => C_PASSWORD
      @user.remove_role :reader
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in @user
    end
  end

  def login_sys_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.create :email => C_EMAIL, :password => C_PASSWORD
      @user.add_role :sys_admin
      @user.remove_role :reader
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in @user
    end
  end

  def login_community_reader
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.create :email => C_EMAIL, :password => C_PASSWORD
      @user.add_role :community_reader
      @user.remove_role :reader
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in @user
    end
  end

  def login_term_reader
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.create :email => C_EMAIL, :password => C_PASSWORD
      @user.add_role :term_reader
      @user.remove_role :reader
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in @user
    end
  end

  def login_term_curator
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.create :email => C_EMAIL, :password => C_PASSWORD
      @user.add_role :term_curator
      @user.remove_role :reader
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in @user
    end
  end

  def login_reader
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.create :email => C_EMAIL, :password => C_PASSWORD
      @user.add_role :reader
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in @user
    end
  end

  def login_curator
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.create :email => C_EMAIL, :password => C_PASSWORD
      @user.add_role :curator
      @user.remove_role :reader
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in @user
    end
  end

  def login_content_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.create :email => C_EMAIL, :password => C_PASSWORD
      @user.add_role :content_admin
      @user.remove_role :reader
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in @user
    end
  end

end