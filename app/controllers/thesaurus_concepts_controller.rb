class ThesaurusConceptsController < ApplicationController
 
  before_action :authenticate_user!
  
  C_CLASS_NAME = "ThesaurusConceptsController"
  
  def new
    authorize ThesaurusConcept
    @thesaurusConcept = ThesaurusConcept.new
  end
  
  def create
    authorize ThesaurusConcept
    if !ThesaurusConcept.exists?(param[:identifier])
      @thesaurusConcept = ThesaurusConcept.create(the_params)
    end
    redirect_to thesaurus_concepts_path
  end

  def impact
    authorize ThesaurusConcept
    id = params[:id]
    namespace = params[:namespace]
    @thesaurusConcept = ThesaurusConcept.find(id, namespace)
    @bcs = BiomedicalConcept.term_impact(params)
  end

  def destroy
    authorize ThesaurusConcept
    @thesaurusConcept = ThesaurusConcept.find(params[:id])
    @thesaurusConcept.destroy
    redirect_to thesaurus_concepts_path
  end

  def show
    authorize ThesaurusConcept
    @thesaurusConcept = ThesaurusConcept.find(params[:id], params[:namespace])
    respond_to do |format|
      format.html
      format.json do
        render json: @thesaurusConcept.to_json
        ConsoleLogger::log(C_CLASS_NAME, "Thesaurus Concept=", "JSON=#{@thesaurusConcept.to_json}")
      end
    end
  end
  
  def showD3
    authorize ThesaurusConcept, :view?
    id = params[:id]
    namespace = params[:namespace]
    thesaurusConcept = ThesaurusConcept.find(id, namespace)
    @thesaurusConcept = thesaurusConcept.d3
    render json: @thesaurusConcept
  end

  private
    def the_params
      params.require(:thesaurus_concept).permit(:identifier, :notation, :synonym, :extensible, :definition, :preferredTerm, :namespace)
    end
    
end
