class BiomedicalConcepts::PropertiesController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = self.class.name

  def show 
    authorize BiomedicalConceptCore::Property
    @property = BiomedicalConceptCore::Property.find(params[:id], params[:namespace])
    respond_to do |format|
      # format.html Not needed yet
      format.json do
        render json: @property.to_json
      end
    end
  end
  
end
