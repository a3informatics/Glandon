class IdentifiedItemsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @identifiedItems = IdentifiedItem.all
  end
  
  def new
    @identifiedItem = IdentifiedItem.new
  end
  
  def create
    @identifiedItem = IdentifiedItem.create(ii_params)
    redirect_to identified_items_path
  end

  def update
  end

  def edit
  end

  def destroy
     @identifiedItem = IdentifiedItem.find(params[:id])
     @identifiedItem.destroy
     redirect_to identified_items_path
  end

  def show
    redirect_to identified_items_path
  end
  
  private
    def ii_params
      params.require(:identified_item).permit(:identifier, :version)
    end

end
