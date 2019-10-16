class Users::SessionsController < Devise::SessionsController

  before_action :log_logout, :only => :destroy  #add this at the top with the other filters
  # Lines commented out may be useful for other events, e.g. failed login attempt.
  #after_filter :log_failed_login, :only => [:new, :create]

  def create
    super
    AuditTrail.user_event(current_user, "User logged in.")
  end

 private

  #def log_failed_login
  #end

  #def failed_login?
  #  (options = env["warden.options"]) && options[:action] == "unauthenticated"
  #end

  def log_logout
    AuditTrail.user_event(current_user, "User logged out.")
  end

end
