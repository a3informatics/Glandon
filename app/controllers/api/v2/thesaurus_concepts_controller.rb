class Api::V2::ThesaurusConceptsController < Api::V2::BaseController
  
  C_CLASS_NAME = "Api::V2::ThesaurusConceptsController"

  def index
    results = []
    ths = Thesaurus.current_set
    if params.length > 0
    	ths.each do |th|
    		thcs = ThesaurusConcept.find_by_property(the_params, th.namespace)
    		thcs.each do |tc|
    			tc.set_parent
    			results << tc.to_json
    		end
    	end	
    	if !results.empty?
	    	render json: results, status: 200
  	  else
    		render json: {errors: thesaurus_concept_not_found_error}, status: 404
    	end
    else
    	render json: {errors: thesaurus_concept_not_found_error}, status: 404
    end
  end

  def show
    tc_find_and_render(UriV2.new(uri: id_to_uri(params[:id])))
  end

  def parent
    uri = id_to_uri(params[:id])
    result = ThesaurusConcept.find_parent(UriV2.new(uri: uri))
    if !result.nil?
      if (result[:rdf_type] == Thesaurus::C_RDF_TYPE_URI.to_s)
        th_find_and_render(result[:uri])
      else
        tc_find_and_render(result[:uri])
      end
    else
      render json: {errors: thesaurus_concept_parent_not_found_error(uri)}, status: 404
    end
  end

private 

  def tc_find_and_render(uri)
    tc = tc_find(uri)
    if tc.errors.empty?
      render json: tc.to_json, status: 200
    else
      render json: {errors: tc.errors.full_messages}, status: 404
    end
  end

  def th_find_and_render(uri)
    th = th_find(uri)
    if th.errors.empty?
      render json: th.to_json, status: 200
    else
      render json: {errors: th.errors.full_messages}, status: 404
    end
  end

  def tc_find(uri)
    return ThesaurusConcept.find(uri.id, uri.namespace)
  rescue => e
    tc = ThesaurusConcept.new
    tc.errors.add(:base, "Failed to find thesaurus concept #{uri}")
    return tc
  end

  def th_find(uri)
    return Thesaurus.find(uri.id, uri.namespace)
  rescue => e
    th = Thesaurus.new
    th.errors.add(:base, "Failed to find thesaurus #{uri}")
    return th
  end

  def the_params
    params.permit(:notation, :identifier)
  end  

  def thesaurus_concept_not_found_error
		tc = ThesaurusConcept.new
    tc.errors.add(:base, "Failed to find thesaurus concept with #{the_params}")
    return tc.errors.full_messages
  end

  def thesaurus_concept_parent_not_found_error(uri)
    tc = ThesaurusConcept.new
    tc.errors.add(:base, "Failed to find parent of thesaurus concept #{uri}")
    return tc.errors.full_messages
  end

end