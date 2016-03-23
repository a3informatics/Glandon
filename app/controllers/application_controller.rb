class ApplicationController < ActionController::Base
  #include Pundit
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Pundit after action, verify authorized (checks if authorization was checked)
	after_action :verify_authorized, unless: :devise_controller?

	# Pundit exception for not authorized
  rescue_from Pundit::NotAuthorizedError, :with => :not_authorized_method

  def not_authorized_method
    flash[:error] = 'You do not have the access rights to that operation.'
		redirect_to root_path
    true
  end


end
