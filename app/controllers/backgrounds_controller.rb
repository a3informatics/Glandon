# Background Controller.
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class BackgroundsController < ApplicationController

	before_action :authenticate_and_authorized

	def index
		@jobs = Background.all
  end

	def destroy
    Background.find(params[:id]).destroy
		render :json => {}, :status => 200
  end

  def destroy_multiple
    case the_params[:items].to_sym
	    when :completed
	      Background.where(complete: true).destroy_all
	    when :all
	      Background.destroy_all
	    else
				render :json => { errors: [ "Requested delete operation not recognized." ] }, :status => 200
				return
	    end
		render :json => {}, :status => 200
	end

private

  def the_params()
    params.require(:backgrounds).permit(:items)
  end

  def model_klass
    Import
  end

end
