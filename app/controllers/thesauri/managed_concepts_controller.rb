class Thesauri::ManagedConceptsController < ApplicationController
 
  before_action :authenticate_user!
  
  C_CLASS_NAME = "ThesaurusConceptsController"
  
  # def edit
  #   authorize ThesaurusConcept
  #   @thesaurus_concept = ThesaurusConcept.find(params[:id], params[:namespace], false)
  #   thesaurus = get_thesaurus(@thesaurus_concept)
  #   @token = Token.find_token(thesaurus, current_user)
  #   @close_path = edit_lock_lost_link(thesaurus)
  #   @referer_path = get_parent_link(@thesaurus_concept)
  #   @tc_identifier_prefix = "#{@thesaurus_concept.identifier}."
  #   if @token.nil?
  #     flash[:error] = "The edit lock has timed out."
  #     redirect_to edit_lock_lost_link(thesaurus)
  #   end
  # end

  # def update
  #   authorize ThesaurusConcept
  #   thesaurus_concept = ThesaurusConcept.find(params[:id], params[:namespace], false)
  #   thesaurus = get_thesaurus(thesaurus_concept)
  #   token = Token.find_token(thesaurus, current_user)
  #   if !token.nil?
  #     thesaurus_concept.update(the_params)
  #     if thesaurus_concept.errors.empty?
  #       AuditTrail.update_item_event(current_user, thesaurus, "Terminology updated.") if token.refresh == 1
  #       results = []
  #       results << thesaurus_concept.to_json
  #       render :json => {:data => results}, :status => 200
  #     else
  #       errors = []
  #       thesaurus_concept.errors.each do |name, msg|
  #         errors << {name: name, status: msg}
  #       end
  #       render :json => {:fieldErrors => errors}, :status => 200
  #     end
  #   else
  #     flash[:error] = "The edit lock has timed out."
  #     render :json => {:data => results, :link => edit_lock_lost_link(thesaurus)}, :status => 422
  #   end
  # end
  
  # def children
  #   authorize Thesaurus, :edit?
  #   results = []
  #   thesaurus_concept = ThesaurusConcept.find(params[:id], params[:namespace])
  #   thesaurus_concept.children.each do |child|
  #     results << child.to_json
  #   end
  #   render :json => { data: results }, :status => 200
  # end

  # def add_child
  #   authorize ThesaurusConcept, :create?
  #   parent_thesaurus_concept = ThesaurusConcept.find(params[:id], params[:namespace], false)
  #   thesaurus = get_thesaurus(parent_thesaurus_concept)
  #   token = Token.find_token(thesaurus, current_user)
  #   if !token.nil?
  #     thesaurus_concept = parent_thesaurus_concept.add_child(the_params)
  #     audit_and_respond(thesaurus, thesaurus_concept, token)
  #   else
  #     render :json => {:errors => ["The changes were not saved as the edit lock timed out."]}, :status => 422
  #   end
  # end

  # def destroy
  #   authorize ThesaurusConcept
  #   thesaurus_concept = ThesaurusConcept.find(params[:id], params[:namespace], false)
  #   thesaurus = get_thesaurus(thesaurus_concept)
  #   token = Token.find_token(thesaurus, current_user)
  #   if !token.nil?
  #     thesaurus_concept.destroy
  #     audit_and_respond(thesaurus, thesaurus_concept, token)
  #   else
  #     render :json => {:errors => ["The changes were not saved as the edit lock timed out."]}, :status => 422
  #   end
  # end

  def show
    authorize Thesaurus
    @tc = Thesaurus::ManagedConcept.find(params[:id])
    respond_to do |format|
      format.html
      format.json do
        children = @tc.children_pagination(params)
        results = children.map{|x| x.to_h.reverse_merge!({show_path: thesauri_unmanaged_concept_path(x)})}
        render json: {data: results, offset: params[:offset], count: results.count}, status: 200
      end
    end
  end
  
  def changes
    authorize Thesaurus, :view?
    @tc = Thesaurus::ManagedConcept.find(params[:id], false)
    respond_to do |format|
      format.html
        @version_count = @tc.changes_count(current_user.max_term_display.to_i)
        link_objects = @tc.forward_backward(1, current_user.max_term_display.to_i)
        @links = {}
        link_objects.each {|k,v| @links[k] = v.nil? ? "" : changes_thesauri_unmanaged_concept_path(v)} # <<< unmanged concept
      format.json do
        clis = @tc.changes(current_user.max_term_display.to_i)
        clis[:items].each do |k,v| 
          v[:changes_path] = changes_thesauri_unmanaged_concept_path(v[:id])
        end
        render json: {data: clis}
      end
    end
  end

  def differences
    authorize Thesaurus, :view?
    @tc = Thesaurus::ManagedConcept.find(params[:id], false)
    respond_to do |format|
      format.json do
        render json: {data: @tc.differences}
      end
    end
  end

# def cross_reference_start
  # 	authorize ThesaurusConcept, :show?
  # 	results = []
  # 	@direction = the_params[:direction].to_sym
  #   refs = ThesaurusConcept.cross_references(params[:id], the_params[:namespace], @direction)
  #   refs.each { |x| results << x[:uri].to_s }
  #   render json: results
  # end

  # def cross_reference_details
  # 	authorize ThesaurusConcept, :show?
  # 	results = []
  # 	direction = the_params[:direction].to_sym
  #   item = ThesaurusConcept.find(params[:id], the_params[:namespace])
  #   item.set_parent
  #   item.parentIdentifier = item.identifier if item.parentIdentifier.empty?
  #   item.cross_reference_details(direction).each do |detail|
  #   	cr_items = []
  #   	detail[:cross_references].each do |uri|
  #   		cr_items << ThesaurusConcept.find(uri.id, uri.namespace).to_json
  #   	end
  #   	results << { item: item.to_json, comments: detail[:comments], cross_references: cr_items }
  #   end
  #   render json: results
  # end

private

  # def edit_lock_lost_link(thesaurus)
  #   return history_thesauri_index_path(identifier: thesaurus.identifier, scope_id: thesaurus.scope.id)
  # end

  # def audit_and_respond(thesaurus, thesaurus_concept, token)
  #   if thesaurus_concept.errors.empty?
  #     AuditTrail.update_item_event(current_user, thesaurus, "Terminology updated.") if token.refresh == 1
  #     results = []
  #     results << thesaurus_concept.to_json
  #     render :json => {:data => results}, :status => 200
  #   else
  #     render :json => {:errors => thesaurus_concept.errors.full_messages}, :status => 422
  #   end
  # end

  # def get_thesaurus(thesaurus_concept)
  #   info = IsoManaged.find_managed(thesaurus_concept.id, thesaurus_concept.namespace)
  #   thesaurus = Thesaurus.find(info[:uri].id, info[:uri].namespace)
  #   return thesaurus
  # end

  # def get_parent_link(thesaurus_concept)
  #   link = ""
  #   info = IsoConcept.find_parent(thesaurus_concept.uri)
  #   if !info.nil?
  #     if info[:rdf_type] == Thesaurus::C_RDF_TYPE_URI.to_s
  #       link = edit_thesauri_path(id: info[:uri].id, namespace: info[:uri].namespace)
  #     else
  #       link = edit_thesaurus_concept_path(id: info[:uri].id, namespace: info[:uri].namespace)        
  #     end
  #   end
  #   return link
  # end

  def the_params
    params.require(:thesaurus_concept).permit(:identifier, :notation, :synonym, :definition, :preferredTerm, :namespace, :label, :type, :direction)
  end
    
end
