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

  def destroy_multiple
    authorize Upload, :delete?
    item = Upload.new
    item.delete_multiple(the_params)
    set_flash('Files succesfully deleted.')
    redirect_to uploads_path
  end

  def destroy_all
    authorize Upload, :delete?
    item = Upload.new
    item.delete_all
    set_flash('All files deleted.')
    redirect_to uploads_path
  end

private

  def set_flash(msg)
    if item.errors.empty? 
      flash[:success] = msg
    else
      flash[:error] = item.error.full_messages.to_sentence
    end
  end

  def the_params
    params.require(:upload).permit(:files => [])
  end

end
