class Imports::BaseController < ApplicationController
  
  before_action :authenticate_and_authorized
  before_action :get_file_type, only: [:new, :items]

  @@extension_map = ["*.xlsx", "*.xml", "*.xlsx"]

  def new
    @model = new_model
    files
  end

  def items
    @model = new_model
    if params[:imports].blank?
      render :json => {data: []}, :status => 200
    else
      filename = get_filename(the_params)
      @items = @model.list({filename: filename, file_type: @file_type})
      @items.each {|x| x[:filename] = filename}
      render :json => {data: @items}, :status => 200
    end
  end

  def create
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
    "Import::#{controller_name.classify}".constantize.new # Having to fiddle this to get singular form of namespace root.
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize Import
  end

  def get_file_type
    @file_type = the_params[:file_type].to_i
  end

  def files
    ext = @@extension_map[@file_type]
    @files = Dir.glob(Rails.root.join("public", "upload") + ext)
  rescue => e
    @files = []
  end

  def the_params(additional=[])
    list = additional + [:identifier, :filename, :file_type, :auto_load, :files => []]
    params.require(:imports).permit(list)
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
