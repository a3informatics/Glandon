class ThesaurusConceptsController < ApplicationController
 
  before_action :authenticate_user!
  
  def new
    @thesaurusConcept = ThesaurusConcept.new
  end
  
  def create
    if !ThesaurusConcept.exists?(param[:identifier])
      @thesaurusConcept = ThesaurusConcept.create(the_params)
    end
    redirect_to thesaurus_concepts_path
  end

  def impact
    id = params[:id]
    namespace = params[:namespace]
    @thesaurusConcept = ThesaurusConcept.find(id, namespace)
    @bcs = BiomedicalConcept.impact(params)
  end

  def destroy
     @thesaurusConcept = ThesaurusConcept.find(params[:id])
     @thesaurusConcept.destroy
     redirect_to thesaurus_concepts_path
  end

  def show
    id = params[:id]
    namespace = params[:namespace]
    @thesaurusConcept = ThesaurusConcept.find(id, namespace)
  end
  
  def showD3
    id = params[:id]
    namespace = params[:namespace]
    thesaurusConcept = ThesaurusConcept.find(id, namespace)
    @thesaurusConcept = thesaurusConcept.to_D3
    render json: @thesaurusConcept
  end

  private
    def the_params
      params.require(:thesaurus_concept).permit(:identifier, :notation, :synonym, :extensible, :definition, :preferredTerm, :namespace)
    end
    
end
