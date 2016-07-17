class SdtmIgDomains::VariablesController < ApplicationController
  
  before_action :authenticate_user!
  
  def show 
    authorize SdtmIgDomains::Variables
    #@class_domain = SdtmModel::ClassDomain.find(params[:id], params[:namespace])
  end
  
end
