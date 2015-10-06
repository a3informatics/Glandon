class ScopedIdentifiersController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @scopedIdentifiers = ScopedIdentifier.all
  end
  
  def new
    @scopedIdentifier = ScopedIdentifier.new
  end
  
  def create
    @scopedIdentifier = ScopedIdentifier.create(ii_params)
    redirect_to scoped_identifiers_path
  end

  def update
  end

  def edit
  end

  def destroy
     @scopedIdentifier = ScopedIdentifier.find(params[:id])
     @scopedIdentifier.destroy
     redirect_to scoped_identifiers_path
  end

  def show
    redirect_to scoped_identifier_path
  end
  
  private
    def ii_params
      params.require(:identified_item).permit(:identifier, :version, :shortName, :namespace_id)
    end

end
