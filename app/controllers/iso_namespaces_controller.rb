class IsoNamespacesController < ApplicationController

  before_action :authenticate_and_authorized
  
  C_CLASS_NAME = self.name

  def index
    @namespaces = IsoNamespace.all
  end
  
  def new
    @namespace = IsoNamespace.new
  end
  
  def create
    @namespace = IsoNamespace.create(this_params)
    if @namespace.errors.empty?
      redirect_to iso_namespaces_path
    else
      flash[:error] = @namespace.errors.full_messages.to_sentence
      redirect_to new_iso_namespace_path
    end
  end

  def destroy
    namespace = IsoNamespace.find(params[:id])
    namespace.delete if namespace.not_used?
    redirect_to iso_namespaces_path
  end

private

  def this_params
    params.require(:iso_namespace).permit(:name, :short_name, :authority)
  end
   
  def authenticate_and_authorized
    authenticate_user!
    authorize IsoNamespace
  end

end