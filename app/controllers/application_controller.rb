class ApplicationController < ActionController::Base

  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Pundit after action, verify authorized (checks if authorization was checked)
  before_action :before_action_steps

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

  # Report a CRUD error
  def crud_error(exception)
    # TODO: This is wierd but not going to worry about it for the mo. Something odd in the
    # exception def?
    flash[:error] = 'A database operation failed. ' + exception.message[:message].to_s
    redirect_to root_path
    true
  end

  # Convert triples to a string
  # @todo Move to a better location?
  def to_turtle(triples)
    result = ""
    triples.each do |key, triple_array|
      triple_array.each do |triple|
        if triple[:object].start_with?('http://')
          result += "<#{triple[:subject]}> \t\t\t<#{triple[:predicate]}> \t\t\t<#{triple[:object]}> . \n"
        else
          object_text = triple[:object]
          # TODO: Compare with SparqlUtility::replace_special_char
          object_text.gsub!("\r", "\\r")
          object_text.gsub!("\n", "\\n")
          object_text.gsub!("\"", "\\\"")
          result += "<#{triple[:subject]}> \t\t\t<#{triple[:predicate]}> \t\t\t\"#{object_text}\" . \n"
        end
      end
    end
    return result
  end

  # Clear the breadcrumbs session variable before any controller action.
  def before_action_steps
    session[:breadcrumbs] = ""
  end

  # Get Token for a Managed Item.
  def get_token(mi)
    token = Token.obtain(mi, current_user)
    if token.nil?
      flash[:error] = "The item is locked for editing by another user."
      redirect_to request.referer
    end
    return token
  end

  # Edit an item
  def edit_item(item)
    @token = get_token(item)
    new_item = item.create_next_version
    return item if new_item.uri == item.uri
    @token.release
    @token = get_token(new_item)
    return new_item
  end

  def after_sign_out_path_for(*)
   new_user_session_path
  end

  # Normalizes array of versions of CDISC ct
  def normalize_versions(versions)
    @normalized = Array.new
    min_i = strdate_to_f(versions[0])
    max_i = strdate_to_f(versions[-1])

    versions.each do |x|
      i = strdate_to_f(x[:date])
      normalized_i = (100)*(i - min_i) / (max_i - min_i) + 0
      @normalized.push(normalized_i)
    end
    return @normalized
  end


  def strdate_to_f(d)
    return Date.parse(d.to_s).strftime('%Q').to_f
  end

end
