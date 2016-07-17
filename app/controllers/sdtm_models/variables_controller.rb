class SdtmModels::VariablesController < ApplicationController
  
  before_action :authenticate_user!
  
  def show 
    authorize SdtmModel::Variable
    @variable = SdtmModel::Variable.find(params[:id], params[:namespace])
  end
  
end
