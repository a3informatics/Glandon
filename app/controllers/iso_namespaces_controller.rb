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
      redirect_to iso_namespaces_path
    end
  end

  def destroy
    begin
      namespace = IsoNamespace.find(params[:id])
      if namespace.not_used?
        namespace.delete
        render :json => {}
      else
        render :json => { errors: [ "Scope Namespace is in use and cannot be deleted." ] }, status: 422
      end
    rescue => e
      render :json => { errors: [ "Unable to delete Scope Namespace." ] }, status: 422
    end
  end

private

  def this_params
    params.require(:iso_namespace).permit(:name, :short_name, :authority)
  end

  def model_klass
    IsoNamespace
  end

end
