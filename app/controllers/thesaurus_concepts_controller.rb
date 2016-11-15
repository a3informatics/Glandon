class ThesaurusConceptsController < ApplicationController
 
  before_action :authenticate_user!
  
  C_CLASS_NAME = "ThesaurusConceptsController"
  
  #def new
  #  authorize ThesaurusConcept
  #  @thesaurusConcept = ThesaurusConcept.new
  #end
  
  def edit
    authorize ThesaurusConcept
    @thesaurus_concept = ThesaurusConcept.find(params[:id], params[:namespace])
  end

  def update
    authorize ThesaurusConcept
    thesaurus_concept = ThesaurusConcept.find(params[:children][0][:id], params[:children][0][:namespace])
    thesaurus_concept.update(params[:children][0])
    if thesaurus_concept.errors.empty?
      render :json => {}, :status => 200
    else
      render :json => {:errors => thesaurus_concept.errors.full_messages}, :status => 422
    end
  end
  
  def add_child
    authorize ThesaurusConcept, :create?
    thesaurus = ThesaurusConcept.find(params[:id], params[:namespace], false)
    thesaurus_concept = thesaurus.add_child(params[:children][0])
    if thesaurus_concept.errors.empty?
      render :json => thesaurus_concept.to_json, :status => 200
    else
      render :json => {:errors => thesaurus_concept.errors.full_messages}, :status => 422
    end
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
    thesaurus_concept = ThesaurusConcept.find(params[:id], params[:namespace])
    thesaurus_concept.destroy
    if thesaurus_concept.errors.empty?
      render :json => {}, :status => 200
    else
      render :json => {:errors => thesaurus_concept.errors.full_messages}, :status => 422
    end
  end

  def show
    authorize ThesaurusConcept
    @thesaurusConcept = ThesaurusConcept.find(params[:id], params[:namespace])
    respond_to do |format|
      format.html
      format.json do
        render json: @thesaurusConcept.to_json
      end
    end
  end
  
private

  def the_params
    params.require(:thesaurus_concept).permit(:identifier, :notation, :synonym, :definition, :preferredTerm, :namespace)
  end
    
end
