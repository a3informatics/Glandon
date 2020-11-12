require 'controller_helpers.rb'

class UploadsController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_user!

  def index
    authorize Upload
  	@upload = Upload.new
    @public_files = upload_files("*").map do |f|
      file = f.rpartition('/').last
      { :name => file.include?('.') ? file.rpartition('.').first : file,
        :extension => file.include?('.') ? file.rpartition('.').last : "" }
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
    authorize Upload, :destroy?
    item = Upload.new
    item.delete_multiple(the_params)
    render json: {data: []}
  end

  def destroy_all
    authorize Upload, :destroy?
    item = Upload.new
    item.delete_all
    render json: {data: []}
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
