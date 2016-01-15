class ApiController < ApplicationController
  
  http_basic_authenticate_with name: "admin", password: "admin"

  C_CLASS_NAME = "ApiController"

  def index
    @forms = Form.all
    respond_to do |format|
      format.json do
        results = {}
        results[:aaData] = []
        @forms.each do |key, form|
          item = {:id => form.id, :namespace => form.namespace, :identifier => form.identifier, :label => form.label}
          results[:aaData] << item
        end
        render json: results
      end
    end
  end

  def form
    id = params[:id]
    ns = params[:namespace]
    @form = Form.find(id, ns)
    respond_to do |format|
      format.json do
        results = @form.d3
        render json: results
      end
    end
  end

end
