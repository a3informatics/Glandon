class ApiController < ApplicationController
  
  http_basic_authenticate_with name: "admin", password: "admin"

  C_CLASS_NAME = "ApiController"

  def pundit_user
    # TODO: Temporary fix to get around pundit authorisation. Need proper API user or someother solution
    User.find(1)
  end

  def index
    authorize ManagedItem, :view?
    @items = Array.new
    case params[:type]
      when "Form"
        @items = Form.all
      when "Domain"
        @items = SdtmUserDomain.all?
      else
    end
    results = Array.new
    respond_to do |format|
      format.json do
        @items.each do |item|
          results << item.to_json
        end
        ConsoleLogger::log(C_CLASS_NAME,"index", "JSON for #{params[:type]}=#{results}")
        render json: results
      end
    end
  end

  def list
    authorize IsoManaged, :view?
    @items = Array.new
    case params[:type]
      when "form"
        @items = Form.list
      when "domain"
        @items = SdtmUserDomain.list
      else
        ConsoleLogger::log(C_CLASS_NAME,"list", "Type=#{params[:type]}")
    end
    results = Array.new
    respond_to do |format|
      format.json do
        @items.each do |item|
          results << item.to_json
        end
        ConsoleLogger::log(C_CLASS_NAME,"list", "JSON for #{params[:type]}=#{results}")
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

  def form_annotations
    authorize Form, :view?
    id = params[:id]
    ns = params[:namespace]
    @form = Form.find(id, ns)
    respond_to do |format|
      format.json do
        results = @form.annotations.to_json
        render json: results
        ConsoleLogger::log(C_CLASS_NAME,"form_annotations", "JSON=#{results}")
      end
    end
  end

  def domain
    authorize SdtmUserDomain, :view?
    id = params[:id]
    ns = params[:namespace]
    @domain = SdtmUserDomain.find(id, ns)
    respond_to do |format|
      format.json do
        results = @domain.to_json
        render json: results
        ConsoleLogger::log(C_CLASS_NAME,"Domain", "JSON=#{results}")
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
