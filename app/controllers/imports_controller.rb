class ImportsController < ApplicationController
  
  before_action :authenticate_and_authorized

  def index
    @items = Import.all
  end
  
  def show
    @import = Import.find(params[:id])
    @job = Background.find(@import.background_id)
    @errors = @import.load_error_file
  end

  def destroy
    Import.find(params[:id]).destroy
    redirect_to imports_path
  end

  def destroy_multiple
    # Only implements all currently
    Import.all.each {|item| item.destroy}
    redirect_to imports_path
  end

  def list
    @items = Import.list
  end
  
private
 
  def the_params()
    params.require(:imports).permit(:items)
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize Import
  end

end
