class ThesaurusConceptsController < ApplicationController
 
  before_action :authenticate_user!
  
  def index
    @thesaurusConcepts = ThesaurusConcept.all
  end
  
  def new
    @thesaurusConcept = ThesaurusConcept.new
  end
  
  def create
    @thesaurusConcept = ThesaurusConcept.create(the_params)
    redirect_to thesaurus_concepts_path
  end

  def update
  end

  def edit
  end

  def destroy
     @thesaurusConcept = ThesaurusConcept.find(params[:id])
     @thesaurusConcept.destroy
     redirect_to thesaurus_concepts_path
  end

  def show
    redirect_to thesaurus_concepts_path
  end
  
  private
    def the_params
      params.require(:thesaurus_concept).permit(:identifier, :notation, :synonym, :extensible, :definition, :preferredTerm)
    end
    
end
