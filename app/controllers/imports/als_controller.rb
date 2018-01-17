class Imports::AlsController < ApplicationController
  
  before_action :authenticate_and_authorized
  before_action :files, only: [:new, :index]
  
  def new
    @als = Import::Als.new
    @forms = []
    render "index"
  end

  def index
    @als = Import::Als.new
    if params[:imports].blank?
      flash[:error] = "A file must be selected."
      @forms = []
    else
      filename = get_filename(the_params)
      @forms = @als.list({filename: filename})
      @forms.each {|f| f[:filename] = filename}
    end
  end

  def create
    als = Import::Als.new
    object = als.import(the_params)
    if !object.errors.empty?
      flash[:error] = object.errors.full_messages.to_sentence
      redirect_to imports_als_path(imports: {files: [the_params[:filename]]})
    else
      flash[:success] = "The form was created."
      redirect_to forms_path 
    end
  end
  
private
 
  def files
    @files = Dir.glob(Rails.root.join("public", "upload") + "*.xlsx")
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
