# Imports Base Controller. The core controller for imports
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Imports::BaseController < ApplicationController
  
  include ControllerHelpers

  before_action :authenticate_and_authorized

  @@extension_map = ["*.xlsx", "*.xml", "*.xlsx"]

  def new
    get_file_type
    @model = new_model
    files
  end

  def items
    if params[:imports].blank?
      render :json => {data: []}, :status => 200
    else
      @model = new_model
      get_file_type
      filename = get_filename(the_params)
      @items = @model.list({filename: filename, file_type: @file_type})
      @items.each {|x| x[:filename] = filename}
      render :json => {data: @items}, :status => 200
    end
  end

  def create
    model = new_model
    model.create(check_filename(the_params))
    if request.format.json?
      render json: {data: []}, :status => 200
    else
      redirect_to import_path(model) 
    end
  end

private
 
  def new_model
    "Import::#{controller_name.classify}".constantize.new # They may be some better ways of doing this but it works.
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize Import
  end

  def get_file_type
    @file_type = the_params[:file_type].to_i
  end

  def files
    @files = upload_files(@@extension_map[@file_type])
  end

  def the_params(additional=[])
    list = additional + [:identifier, :filename, :file_type, :auto_load, :files => []]
    params.require(:imports).permit(list)
  end

  def check_filename(params)
    return params if params.key?(:filename)
    params[:filename] = get_filename(params)
    return params
  end

  def get_filename(params)
    params[:files].reject!(&:blank?)
    return params[:files].first
  end

  def no_file_error
    flash[:error] = "A file must be selected."
    @items = []
    respond_to do |format|
      format.html 
      format.json do
        render json: { data: @items }
      end
    end
  end

end
