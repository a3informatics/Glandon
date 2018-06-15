class Imports::TermsController < ApplicationController
  
  before_action :authenticate_and_authorized
  before_action :files, only: [:new, :index]
  
  def new
    @th = []
    Thesaurus.all.each { |t| @th << t if t.registrationStatus == :Incomplete.to_s }
    @term = Import::Term.new
    @code_lists = []
    render "index"
  end

  def index
    @term = Import::Term.new
    if the_params[:filename].blank?
      render :json => { data: [] }, :status => 200
    else
      code_lists = @term.list(the_params)
      render :json => { data: code_lists }, :status => 200
    end
  end

  def create
    term = Import::Term.new
    object = term.import(the_params)
    render :json => { errors: object.errors.full_messages }, :status => 200
  end
  
private
 
  def files
    @file_type = the_params[:file_type].to_sym
    ext = @file_type == :excel ?  "*.xlsx" : "*.xml" 
    @files = Dir.glob(Rails.root.join("public", "upload") + ext)
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize Import
  end

  def the_params
    params.require(:imports).permit(:uri, :filename, :identifier, :file_type)
  end
    
end
