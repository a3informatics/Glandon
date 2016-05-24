class ApplicationController < ActionController::Base
  
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

  # CRUD exceptions
  rescue_from Exceptions::DestroyError, :with => :crud_error
  rescue_from Exceptions::CreateError, :with => :crud_error
  rescue_from Exceptions::UpdateError, :with => :crud_error

  def crud_error(exception)
    # TODO: This is wierd but not going to worry about it for the mo. Something odd in the 
    # exception def?
    flash[:error] = 'A database operation failed. ' + exception.message[:message].to_s
    redirect_to root_path
    true
  end
  
  def to_turtle(triples)
    result = ""
    triples.each do |key, triple_array|
      triple_array.each do |triple|
        if triple[:object].start_with?('http://')
          result += "<#{triple[:subject]}> \t\t\t<#{triple[:predicate]}> \t\t\t<#{triple[:object]}> . \n"
        else
          result += "<#{triple[:subject]}> \t\t\t<#{triple[:predicate]}> \t\t\t\"#{triple[:object]}\" . \n"
        end
      end
    end
    return result
  end

end
