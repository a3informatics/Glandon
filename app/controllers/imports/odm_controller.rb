require_dependency 'import/odm' # Needed becuase Odm is alos name of a gem.

class Imports::OdmController < ApplicationController
  
  before_action :authenticate_and_authorized
  before_action :files, only: [:new, :index]
  
  def new
    @odm = Import::Odm.new
    @forms = []
    render "index"
  end

  def index
    @odm = Import::Odm.new
    if params[:imports].blank?
      flash[:error] = "A file must be selected."
      @forms = []
    else
      filename = get_filename(the_params)
      @forms = @odm.list({filename: filename})
      @forms.each {|f| f[:filename] = filename}
    end
  end

  def create
    odm = Import::Odm.new
    object = odm.import(the_params)
    if params[:imports].blank?
      flash[:error] = object.errors.full_messages.to_sentence
      redirect_to imports_odm_index_path(imports: {files: [the_params[:filename]]})
    else
      flash[:success] = "The form was created."
      redirect_to forms_path 
    end
  end
  
private
 
  def files
    @files = Dir.glob(Rails.root.join("public", "upload") + "*.xml")
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize Import
  end

  def the_params
    params.require(:imports).permit(:identifier, :filename, :files => [])
  end

  def get_filename(params)
    params[:files].reject!(&:blank?)
    return params[:files].first
  end
    
end
