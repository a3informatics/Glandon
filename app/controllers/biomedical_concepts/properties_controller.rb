class BiomedicalConcepts::PropertiesController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = self.class.name

  def show 
    authorize BiomedicalConceptCore::Property
    @property = BiomedicalConceptCore::Property.find(params[:id], the_params[:namespace])
    respond_to do |format|
      # format.html Not needed yet
      format.json do
        render json: @property.to_json
      end
    end
  end
  
  def update
    authorize BiomedicalConceptCore::Property
    property = BiomedicalConceptCore::Property.find(params[:id], the_params[:namespace])
    bc = get_bc(property)
    token = Token.find_token(bc, current_user)
    if !token.nil?
      property.update(the_params)
      if property.errors.empty?
        AuditTrail.update_item_event(current_user, bc, "Biomedical Concept updated.") if token.refresh == 1
        render :json => {:data => [ property.to_json_with_references ]}, :status => 200
      else
        errors = []
        property.errors.each do |name, msg|
          errors << {name: name, status: msg}
        end
        render :json => {:fieldErrors => errors}, :status => 200
      end
    else
      flash[:error] = "The edit lock has timed out."
      render :json => {:data => [], :link => history_biomedical_concepts_path( :biomedical_concept => { identifier: bc.identifier, scope_id: bc.owner_id })}, 
        :status => 422
    end
  end

  def add
    authorize BiomedicalConceptCore::Property, :update?
    property = BiomedicalConceptCore::Property.find(params[:id], the_params[:namespace])
    bc = get_bc(property)
    token = Token.find_token(bc, current_user)
    if !token.nil?
      property.remove
      property.add(the_params)
      if property.errors.empty?
        AuditTrail.update_item_event(current_user, bc, "Biomedical Concept updated.") if token.refresh == 1
        property = BiomedicalConceptCore::Property.find(params[:id], the_params[:namespace])
        render :json => {:data => [ property.to_json_with_references ]}, :status => 200
      else
        errors = []
        property.errors.each do |name, msg|
          errors << {name: name, status: msg}
        end
        render :json => {:fieldErrors => errors}, :status => 200
      end
    else
      flash[:error] = "The edit lock has timed out."
      render :json => {:data => [], :link => history_biomedical_concepts_path( :biomedical_concept => { identifier: bc.identifier, scope_id: bc.owner_id })}, 
        :status => 422
    end
  end

  def remove
    authorize BiomedicalConceptCore::Property, :update?
    property = BiomedicalConceptCore::Property.find(params[:id], the_params[:namespace])
    bc = get_bc(property)
    token = Token.find_token(bc, current_user)
    if !token.nil?
      property.remove
      AuditTrail.update_item_event(current_user, bc, "Biomedical Concept updated.") if token.refresh == 1
      property = BiomedicalConceptCore::Property.find(params[:id], the_params[:namespace])
      render :json => {:data => [ property.to_json_with_references ]}, :status => 200
    else
      flash[:error] = "The edit lock has timed out."
      render :json => {:data => [], :link => history_biomedical_concepts_path( :biomedical_concept => { identifier: bc.identifier, scope_id: bc.owner_id })}, 
        :status => 422
    end
  end

private

  def get_bc(property)
    info = IsoManaged.find_managed(property.id, property.namespace)
    bc = BiomedicalConcept.find(info[:uri].id, info[:uri].namespace)
    return bc
  end

  def the_params
    params.require(:property).permit(:namespace, :question_text, :prompt_text, :enabled, :collect, :format, 
      tc_refs: [ :ordinal, :subject_ref => [ :id, :namespace]])
  end

end
