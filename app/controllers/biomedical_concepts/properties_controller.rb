class BiomedicalConcepts::PropertiesController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = self.class.name

  def show 
    # TODO: Sub policy notloading, cannot see why. Use parent policy which works
    #authorize BiomedicalConcept::Property
    authorize BiomedicalConcept
    property = BiomedicalConceptCore::Property.find(params[:id], params[:namespace])
    respond_to do |format|
      format.html 
      format.json do
        render json: property.to_json
      end
    end
  end
  
end
