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
    redirect_to backgrounds_path
  end

  def destroy_multiple
    case the_params[:items].to_sym
    when :completed
      Background.where(complete: true).destroy_all
    when :all
      Background.destroy_all
    else
      flash[:error] = "Requested delete operation not recognized."
    end
		redirect_to backgrounds_path
	end

private
 
  def the_params()
    params.require(:backgrounds).permit(:items)
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize Import
  end

end
