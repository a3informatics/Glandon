# Application Controller. Base controller
#
# @author Dave Iberson-Hurst
# @since 0.0.1
class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :before_action_callback
  after_action :after_action_callback, unless: :devise_controller?
  rescue_from Exceptions::DestroyError, :with => :crud_error_handler
  rescue_from Exceptions::CreateError, :with => :crud_error_handler
  rescue_from Exceptions::UpdateError, :with => :crud_error_handler
  rescue_from User::NotAuthorizedError, :with => :not_authorized_handler

  @@action_access = 
  {
    new: :create, create: :create, 
    index: :read, history: :read, show: :read, view: :read, 
    edit: :update, update: :update,
    destroy: :delete
  }
  @@authorization_klass = nil
  @@model_klass = nil

  [:create, :read, :update, :delete].each do |access|
    define_singleton_method "#{access}_access" do |*args|
      args.each {|a| @@action_access[a] = access}
    end
  end

  def self.associated_klasses(params)
    @@authorization_klass = params[:authorization] if params.key?(:authorization)
    @@model_klass = params[:model] if params.key?(:model)
    @@authorization_klass = params[:all] if params.key?(:all)
    @@model_klass = params[:all] if params.key?(:all)
  end

  def authenticate_and_authorize
    authenticate_user!
    current_user.authorized?(authorization_klass, @@action_access[action_name.to_sym])
  end

  # Not Authorized Handler
  #
  # @return [Boolean] always returns true
  def not_authorized_handler
    flash[:error] = 'You do not have the access rights to that operation.'
    redirect_to root_path
    true
  end

  # Report a CRUD error
  def crud_error_handler(exception)
    # @todo Something odd in the exception def?
    flash[:error] = 'A database operation failed. ' + exception.message[:message].to_s
    redirect_to root_path
    true
  end

  # Before Action. Anything that needs to be done before the action executes
  #
  # @return [Void] no return
  def before_action_callback
    # Clear the breadcrumbs session variable before any controller action.
    session[:breadcrumbs] = ""
  end

  # After Action. Anything that needs to be done after the action executes
  #
  # @return [Void] no return
  def after_action_callback
    Errors.application_error(self.class.name, "after_action_callback", "The action did not check the authorization.") unless current_user.authorization_checked?
  end

  # Model Klass. The model klass for the controller
  #
  # @raise [Errors::ApplicationLogicError] raised if method called.
  # @return [Class] the class
  def model_klass
    return @@model_klass unless @@model_klass.nil?
    Errors.application_error(self.class.name, "model_klass", "Model classs not set.")
  end

  # Authorization Klass. The model klass for the controller uses for authorization
  #
  # @raise [Errors::ApplicationLogicError] raised if method called.
  # @return [Class] the class
  def authorization_klass
    return @@authorization_klass unless @@authorization_klass.nil?
    Errors.application_error(self.class.name, "model_klass", "Authorization class not set.")
  end

  # Path For. Default path for a controller action pair. Individual controllers should overload.
  #
  # @param [Symbol] the action
  # @param [Object] the object
  # @raise [Errors::ApplicationLogicError] raised if method called.
  def path_for(action, object)
    Errors.application_error(self.class.name, "path_for", "Generic path_for method called. Controllers should overload.")
  end

  # Protect From Bad Id. Check params[:id] to protect us from anything nasty, should be a uri.
  #
  # @raise [Errors::ApplicationLogicError] raised if a bad id detected.
  # @return [String] the id of anythign ok.
  def protect_from_bad_id(params)
    Errors.application_error(self.class.name, __method__.to_s, "Possible threat from bad id detected #{params[:id]}.") unless Uri.safe_id?(params[:id])
    params[:id]
  end

  # Ids to URIs. Change specified ids to uris in a param array. Non destructive.
  #
  # @param [Hash] params the source hash. Not changed
  # @param [Array] keys array of symbols denoting the keys to be processed
  # @return [Hash] updated hash
  def ids_to_uris(params, keys)
    new_params = params.dup
    keys.each do |key|
      next unless new_params.key?(key)
      new_params[key] = new_params[key].is_a?(Array) ? new_params[key].map{|x| Uri.new(id: x)} : Uri.new(id: new_params[key])
    end
    new_params
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

  # Get Token. Get the token for a Managed Item.
  #
  # @param [Object] mi the managed item object
  # @return [Token] the token or nil if not found. Flash error set to standard error in not found.
  def get_token(mi)
    token = Token.obtain(mi, current_user)
    return token if !token.nil?
    token = Token.find_token_for_item(mi)
    user = token.nil? ? "<unknown>" : User.find(token.user_id).email
    flash[:error] = "The item is locked for editing by user: #{user}."
    nil
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "The item is locked for editing by user: <unknown>."
    nil
  end

  # Edit Item. Edit a managed item helper
  #
  # @param [Object] item the managed item
  # @return [Object] the new item. It may be the same item. Will be nil if cannot be locked. Token set in controller
  def edit_item(item)
    @token = get_token(item)
    return nil if @token.nil?
    new_item = item.create_next_version
    return item if new_item.uri == item.uri
    @token.release
    @token = get_token(new_item)
    return nil if @token.nil?
    return new_item
  end

  def after_sign_out_path_for(*)
   new_user_session_path
  end

  # Token Timeout Message.
  #
  # @return [String] the timeout message
  def token_timeout_message
    return "The changes were not saved as the edit lock has timed out."
  end

  # Token Destroy Message.
  #
  # @param [Object] mi the managed item object
  # @return [String] the timeout message
  def token_destroy_message(mi)
    token = Token.find_token_for_item(mi)
    user = token.nil? ? "<unknown>" : User.find(token.user_id).email
    return "The #{mi.audit_type} cannot be deleted as it is locked for editing by user: #{user}."
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

  # Date to floating point.
  def strdate_to_f(d)
    return Date.parse(d.to_s).strftime('%Q').to_f
  end

  helper_method :normalize_versions
  
end
