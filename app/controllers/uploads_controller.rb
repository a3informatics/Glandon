class UploadsController < ApplicationController

  before_action :authenticate_user!

  def index
    authorize Upload
  	@upload = Upload.new
  end

  def create
    authorize Upload
    post = Upload.save(params[:upload])
    redirect_to uploads_path
    flash[:success] = 'Upload complete.'
  end

end
