require 'controller_helpers.rb'

class UploadsController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_user!

  def index
    authorize Upload
  	@upload = Upload.new
    @public_files = upload_files("*").map do |f|
      file = f.split('/')[-1]
      { :name => file.include?('.') ? file.split('.')[0] : file,
        :extension => file.include?('.') ? file.split('.')[-1] : "" }
    end
  end

  def create
    authorize Upload
    if params[:upload].nil?
      redirect_to uploads_path
      flash[:error] = 'No file selected.'
    else
      post = Upload.save(params[:upload])
      redirect_to uploads_path
      flash[:success] = 'Upload complete.'
    end
  end

end
