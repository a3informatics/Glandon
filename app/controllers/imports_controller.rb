# Import Controller.
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class ImportsController < ApplicationController

  before_action :authenticate_and_authorized

  def index
    respond_to do |format|
      format.html
      format.json do
        @items = Import.all
        results = []
        @items.each do |x|
          item = x.as_json
          item[:import_path] = import_path(id: x[:id])
          item[:complete] = x.complete
          results.push(item)
        end
        render json: {data: results}
      end
    end
  end

  def show
    @import = Import.find(params[:id])
    @job = Background.find(@import.background_id)
    @errors = @import.load_error_file
  end

  def destroy
    Import.find(params[:id]).destroy
    render json: {data: []}
  end

  def destroy_multiple
    # Only currently implements all
    Import.destroy_all
    render json: {data: []}
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
