class ExportsController < ApplicationController
  
  before_action :authenticate_and_authorized

  def index
  end

  def start
    @list_path = the_params[:export_list_path]
  end

  def terminologies
    render :json => { :data => Export.new.terminologies}, :status => 200
  end

  def biomedical_concepts
    render :json => { :data => Export.new.biomedical_concepts}, :status => 200
  end

  def forms
    render :json => { :data => Export.new.forms}, :status => 200
  end

  def download
    send_data PublicFile.read(the_params[:file_path]), filename: File.basename(the_params[:file_path]), type: 'application/x-turtle', disposition: 'inline'
  end

private
 
  def the_params
    params.require(:export).permit(:export_list_path, :file_path)
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize Export
  end

end
