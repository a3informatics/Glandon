# Imports Base Controller. The core controller for imports
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Imports::BaseController < ApplicationController
  
  include ControllerHelpers

  before_action :authenticate_and_authorized

  @@extension_map = ["*.xlsx", "*.xml", "*.xlsx"]

  def new
    @file_type = get_file_type
    @model = new_model
    @files = upload_files(@@extension_map[@file_type])
  end

  def items
    if params[:imports].blank?
      render :json => {data: []}, :status => 200
    else
      check_params
      @model = new_model
      @file_type = get_file_type
      @items = @model.list(the_params)
      render :json => {data: @items}, :status => 200
    end
  end

  def create
    check_params
    model = new_model
    model.create(the_params)
    if request.format.json?
      render json: {data: []}, :status => 200
    else
      redirect_to import_path(model) 
    end
  end

private
 
  def new_model
    klass.new
  end

  def klass
    "Import::#{controller_name.classify}".constantize # They may be some better ways of doing this but it works.
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize Import
  end

  def check_params
    return if Import.api?(the_params)
    the_params[:files].reject!(&:blank?)
  end

  def get_file_type
    the_params[:file_type].to_i
  end

  def the_params(additional=[])
    list = additional + [:identifier, :filename, :file_type, :auto_load, :files => []]
    params.require(:imports).permit(list)
  end

  def single_filename()
    return the_params[:files].first
  end

end
