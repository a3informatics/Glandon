class ApiController < ApplicationController
  
  http_basic_authenticate_with name: "admin", password: "admin"

  C_CLASS_NAME = "ApiController"

  C_FORM = "Form"
  C_SDTM_UD = "SDTM Sponsor Domain"
  C_SDTM_IGD = "SDTM IG Domain"
  C_SDTM_MD = "SDTM Model Domain" 
  C_SDTM_MODEL = "SDTM Model"
  C_SDTM_IG = "SDTM Implementation Guide"
  C_BC = "Biomedical Concept"
  C_BCT = "Biomedical Concept Template"
  C_TH = "Thesaurus"
  
  C_FORM_TYPE = UriV2.new({:namespace => Form::C_SCHEMA_NS, :id => Form::C_RDF_TYPE})
  C_SDTM_UD_TYPE = UriV2.new({:namespace => SdtmUserDomain::C_SCHEMA_NS, :id => SdtmUserDomain::C_RDF_TYPE})
  C_SDTM_IGD_TYPE = UriV2.new({:namespace => SdtmIgDomain::C_SCHEMA_NS, :id => SdtmIgDomain::C_RDF_TYPE})
  C_SDTM_MD_TYPE =  UriV2.new({:namespace => SdtmModelDomain::C_SCHEMA_NS, :id => SdtmModelDomain::C_RDF_TYPE}) 
  C_SDTM_MODEL_TYPE = UriV2.new({:namespace => SdtmModel::C_SCHEMA_NS, :id => SdtmModel::C_RDF_TYPE})
  C_SDTM_IG_TYPE = UriV2.new({:namespace => SdtmIg::C_SCHEMA_NS, :id => SdtmIg::C_RDF_TYPE})
  C_BC_TYPE = UriV2.new({:namespace => BiomedicalConcept::C_SCHEMA_NS, :id => BiomedicalConcept::C_RDF_TYPE}) 
  C_BCT_TYPE = UriV2.new({:namespace => BiomedicalConceptTemplate::C_SCHEMA_NS, :id => BiomedicalConceptTemplate::C_RDF_TYPE}) 
  C_TH_TYPE = UriV2.new({:namespace => Thesaurus::C_SCHEMA_NS, :id => Thesaurus::C_RDF_TYPE})
  C_THC_TYPE = UriV2.new({:namespace => ThesaurusConcept::C_SCHEMA_NS, :id => ThesaurusConcept::C_RDF_TYPE})
  C_BCP_TYPE = UriV2.new({:namespace => BiomedicalConceptCore::Property::C_SCHEMA_NS, :id => BiomedicalConceptCore::Property::C_RDF_TYPE})
  C_SDTM_UDV_TYPE = UriV2.new({:namespace => SdtmUserDomain::Variable::C_SCHEMA_NS, :id => SdtmUserDomain::Variable::C_RDF_TYPE})
  C_SDTM_IGDV_TYPE = UriV2.new({:namespace => SdtmIgDomain::Variable::C_SCHEMA_NS, :id => SdtmIgDomain::Variable::C_RDF_TYPE})
  C_SDTM_MDV_TYPE =  UriV2.new({:namespace => SdtmModelDomain::Variable::C_SCHEMA_NS, :id => SdtmModelDomain::Variable::C_RDF_TYPE}) 
  C_SDTM_MV_TYPE =  UriV2.new({:namespace => SdtmModel::Variable::C_SCHEMA_NS, :id => SdtmModel::Variable::C_RDF_TYPE}) 
  
  # Types
  # TODO This could be improved. May be a single startup query.
  @@discoverable_labels =
    {
      C_FORM => { 
        :label => C_FORM, 
        :class => "Form"
      },
      C_SDTM_UD => { 
        :label => C_SDTM_UD, 
        :class => "SdtmUserDomain"
      },
      C_SDTM_IGD => { 
        :label => C_SDTM_IGD, 
        :class => "SdtmIgDomain"
      },
      C_SDTM_MD => { 
        :label => C_SDTM_MD, 
        :class => "SdtmModelDomain"
      },
      C_SDTM_MODEL => { 
        :label => C_SDTM_MODEL, 
        :class => "SdtmModel"
      },
      C_SDTM_IG => { 
        :label => C_SDTM_IG, 
        :class => "SdtmIg"
      },
      C_BC => { 
        :label => C_BC, 
        :class => "BiomedicalConcept"
      },
      C_BCT => { 
        :label => C_BCT, 
        :class => "BiomedicalConceptTemplate"
      },
      C_TH => { 
        :label => C_TH, 
        :class => "Thesaurus"
      }
    }

  @@find_types =
    {
      C_FORM_TYPE.to_s => { 
        :rdf_type => C_FORM_TYPE, 
        :class => "Form"
      },
      C_SDTM_UD_TYPE.to_s => { 
        :rdf_type => C_SDTM_UD_TYPE, 
        :class => "SdtmUserDomain"
      },
      C_SDTM_IGD_TYPE.to_s => { 
        :rdf_type => C_SDTM_IGD_TYPE, 
        :class => "SdtmIgDomain"
      },
      C_SDTM_MD_TYPE.to_s => { 
        :rdf_type => C_SDTM_MD_TYPE, 
        :class => "SdtmModelDomain"
      },
      C_SDTM_MODEL_TYPE.to_s => { 
        :rdf_type => C_SDTM_MODEL_TYPE, 
        :class => "SdtmModel"
      },
      C_SDTM_IG_TYPE.to_s => { 
        :rdf_type => C_SDTM_IG_TYPE, 
        :class => "SdtmIg"
      },
      C_BC_TYPE.to_s => { 
        :rdf_type => C_BC_TYPE, 
        :class => "BiomedicalConcept"
      },
      C_BCT_TYPE.to_s => { 
        :rdf_type => C_BCT_TYPE, 
        :class => "BiomedicalConceptTemplate"
      },
      C_TH_TYPE.to_s => { 
        :rdf_type => C_TH_TYPE, 
        :class => "Thesaurus"
      },
      C_THC_TYPE.to_s => { 
        :rdf_type => C_THC_TYPE, 
        :class => "ThesaurusConcept"
      },
      C_BCP_TYPE.to_s => { 
        :rdf_type => C_BCP_TYPE, 
        :class => "BiomedicalConceptCore::Property"
      },
      C_SDTM_UDV_TYPE.to_s => { 
        :rdf_type => C_SDTM_UDV_TYPE, 
        :class => "SdtmUserDomain::Variable"
      }, 
      C_SDTM_IGDV_TYPE.to_s => { 
        :rdf_type => C_SDTM_IGDV_TYPE, 
        :class => "SdtmIgDomain::Variable"
      }, 
      C_SDTM_MDV_TYPE.to_s => { 
        :rdf_type => C_SDTM_MDV_TYPE, 
        :class => "SdtmModelDomain::Variable"
      },
      C_SDTM_MV_TYPE.to_s => { 
        :rdf_type => C_SDTM_MV_TYPE, 
        :class => "SdtmModel::Variable"
      }
    }
  
  def pundit_user
    # TODO: Temporary fix to get around pundit authorisation. Need proper API user or someother solution
    User.find(1)
  end

  def discover
    authorize IsoManaged, :view?
    results = @@discoverable_labels.map{|key, value| value[:label]}
    #ConsoleLogger::log(C_CLASS_NAME,"types", "Results=#{results}")
    respond_to do |format|
      format.json do
        render json: results
      end
    end
  end

  # Get all items of a given types
  def index
    authorize IsoManaged, :view?
    #ConsoleLogger::log(C_CLASS_NAME,"index", "API Types=#{@@discoverable_labels}")
    if @@discoverable_labels.has_key?(params[:label])
      info = @@discoverable_labels[params[:label]]
      object = info[:class].constantize
      items = object.all
      results = Array.new
      respond_to do |format|
        format.json do
          items.each do |item|
            results << item.to_json
          end
          #ConsoleLogger::log(C_CLASS_NAME,"index", "JSON for #{params[:label]}=#{results}")
          render json: results
        end
      end
    else
      render :json => {:errors => ["The label #{params[:label]} was not recognized."]}, :status => 422
    end
  end

  # Get all released items of a given type
  def list
    authorize IsoManaged, :view?
    #ConsoleLogger::log(C_CLASS_NAME,"index", "API Types=#{@@discoverable_labels}")
    if @@discoverable_labels.has_key?(params[:label])
      info = @@discoverable_labels[params[:label]]
      object = info[:class].constantize
      items = object.list
      results = Array.new
      respond_to do |format|
        format.json do
          items.each do |item|
            results << item.to_json
          end
          #ConsoleLogger::log(C_CLASS_NAME,"list", "JSON for #{params[:label]}=#{results}")
          render json: results
        end
      end
    else
      render :json => {:errors => ["The label #{params[:label]} was not recognized."]}, :status => 422
    end
  end

  def show
    authorize IsoManaged, :view?
    rdf_type = IsoConcept.get_type(params[:id], params[:namespace])
    #ConsoleLogger::log(C_CLASS_NAME,"show", "RDF Type=#{rdf_type}")
    if !rdf_type.nil?
      if @@find_types.has_key?(rdf_type.to_s)
        info = @@find_types[rdf_type.to_s]
        object = info[:class].constantize
        item = object.find(params[:id], params[:namespace])
        respond_to do |format|
          format.json do
            #ConsoleLogger::log(C_CLASS_NAME,"show", "Item=#{item.to_json}")
            render json: item.to_json
          end
        end
      else
        render :json => {:errors => ["The URI did not refer to a supported class."]}, :status => 422
      end
    else
      render :json => {:errors => ["The URI did not refer to a supported type."]}, :status => 422
    end
  end

  # Deprecated, use show
  def form
    authorize Form, :view?
    id = params[:id]
    ns = params[:namespace]
    @form = Form.find(id, ns)
    respond_to do |format|
      format.json do
        results = @form.to_json
        render json: results
        #ConsoleLogger::log(C_CLASS_NAME,"form", "JSON=#{results}")
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
        #ConsoleLogger::log(C_CLASS_NAME,"form_annotations", "JSON=#{results}")
      end
    end
  end

  # Deprecated, use show
  def domain
    authorize SdtmUserDomain, :view?
    id = params[:id]
    ns = params[:namespace]
    @domain = SdtmUserDomain.find(id, ns)
    respond_to do |format|
      format.json do
        results = @domain.to_json
        render json: results
        #ConsoleLogger::log(C_CLASS_NAME,"Domain", "JSON=#{results}")
      end
    end
  end

  # Deprecated, use show
  def thesaurus_concept
    authorize ThesaurusConcept, :view?
    id = params[:id]
    ns = params[:namespace]
    @item = ThesaurusConcept.find(id, ns)
    respond_to do |format|
      format.json do
        results = @item.to_json
        render json: results
        #ConsoleLogger::log(C_CLASS_NAME,"thesaurus_concept", "JSON=#{results}")
      end
    end
  end

  # Deprecated, use show
  def bc_property
    authorize BiomedicalConcept, :view?
    id = params[:id]
    ns = params[:namespace]
    @item = BiomedicalConceptCore::Property.find(id, ns)
    respond_to do |format|
      format.json do
        results = @item.to_json
        render json: results
        #ConsoleLogger::log(C_CLASS_NAME,"bc_property", "JSON=#{results}")
      end
    end
  end
end
