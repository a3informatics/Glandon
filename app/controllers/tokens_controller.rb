class TokensController < ApplicationController
  
  before_action :authenticate_user!

  C_CLASS_NAME = "TokensController"

  def index
    authorize Token
    Token.expire
    @timeout = Token.get_timeout
    @tokens = Token.all
  end

  def release
  	authorize Token
    release_token(params[:id])
    respond_to do |format|
      format.html { redirect_to tokens_path }
      format.json { render :json => {}, :status => 200 }
    end
  end

  def release_multiple
    authorize Token, :release?
    the_params[:id_set].each {|id| release_token(id)}
    render :json => {}, :status => 200
  end

  def status
    authorize Token
    if Token.exists?(params[:id])
      item = Token.find(params[:id])
      respond_to do |format|
        format.json { render :json => { running: !item.timed_out?, remaining: item.remaining }, :status => 200 }
      end
    else
      respond_to do |format|
        format.json { render :json => { running: false, remaining: 0 }, :status => 200 }
      end    
    end
  end

  def extend_token
    authorize Token
    if Token.exists?(params[:id])
      item = Token.find(params[:id])
      item.extend_token
      respond_to do |format|
        format.json { render :json => {}, :status => 200 }
      end
    else
      respond_to do |format|
        format.json { render :json => {}, :status => 200 }
      end
    end    
  end

private

  # Release a single token, check for any exceptions and log if any.
  def release_token(id)
    item = Token.find(id)
    item.release
  rescue => e
    ConsoleLogger.info(this.class.name, "release_multiple", "Exception raised releasing token #{id}.")
  end

  # Strong params
  def the_params
    params.require(:token).permit(id_set: [])
  end

end