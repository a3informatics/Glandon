class ApiController < ApplicationController
  
  http_basic_authenticate_with name: "admin", password: "admin"

  C_CLASS_NAME = "ApiController"

  def pundit_user
    # TODO: Temporary fix to get around pundit authorisation. Need proper API user or someother solution
    User.find(1)
  end

  def index
    authorize Form, :view?
    @forms = Form.all
    respond_to do |format|
      format.json do
        results = {}
        results[:aaData] = []
        @forms.each do |form|
          item = {:id => form.id, :namespace => form.namespace, :identifier => form.identifier, :label => form.label}
          results[:aaData] << item
        end
        render json: results
      end
    end
  end

  def form
    authorize Form, :view?
    id = params[:id]
    ns = params[:namespace]
    @form = Form.find(id, ns)
    respond_to do |format|
      format.json do
        results = @form.to_json
        render json: results
        ConsoleLogger::log(C_CLASS_NAME,"form", "JSON=#{results}")
      end
    end
  end

  def thesaurus_concept
    authorize ThesaurusConcept, :view?
    id = params[:id]
    ns = params[:namespace]
    @item = ThesaurusConcept.find(id, ns)
    respond_to do |format|
      format.json do
        results = @item.to_json
        render json: results
        ConsoleLogger::log(C_CLASS_NAME,"thesaurus_concept", "JSON=#{results}")
      end
    end
  end

  def bc_property
    authorize BiomedicalConcept, :view?
    id = params[:id]
    ns = params[:namespace]
    @item = BiomedicalConceptCore::Property.find(id, ns)
    respond_to do |format|
      format.json do
        results = @item.to_json
        render json: results
        ConsoleLogger::log(C_CLASS_NAME,"bc_property", "JSON=#{results}")
      end
    end
  end
end
