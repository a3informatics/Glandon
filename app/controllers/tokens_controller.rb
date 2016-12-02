class TokensController < ApplicationController
  
  before_action :authenticate_user!

  C_CLASS_NAME = "TokensController"

  def index
    authorize Token
    ConsoleLogger.debug(C_CLASS_NAME, "index", "Here")
    Token.expire
    @timeout = Token.get_timeout
    @tokens = Token.all
  end

  def release
  	authorize Token
  	item = Token.find(params[:id])
  	item.release
    respond_to do |format|
      format.html  { redirect_to tokens_path }
      format.json  { render :json => {}, :status => 200 }
    end
  end

end