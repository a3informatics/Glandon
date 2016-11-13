module ValidUserRequestHelper
  # Define a method which signs in as a valid user.
  def sign_in_as_admin_user
    @user ||= FactoryGirl.create :user
    @user.add_role :sys_admin 
    # We action the login request using the parameters before we begin.
    # The login requests will match these to the user we just created in the factory, and authenticate us.
    post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
    end
end

# Configure these to modules as helpers in the appropriate tests.
RSpec.configure do |config|
  # Include the help for the request specs.
  config.include ValidUserRequestHelper, :type => :request
end