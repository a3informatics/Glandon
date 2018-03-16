class Api::V2::ThesaurusConceptsController < Api::V2::BaseController
  
  C_CLASS_NAME = "Api::V2::ThesaurusConceptsController"

  def index
    results = []
    if the_params.length > 0
      Thesaurus.current_set.each do |uri|
        th = Thesaurus.find(uri.id, uri.namespace, false)
    		thcs = th.find_by_property(the_params)
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
    uri = UriV2.new(uri: id_to_uri(params[:id]))
    item_find_and_render(ThesaurusConcept, uri, "Thesaurus Concept") { |item| item.to_json }
  end

  def parent
    uri = id_to_uri(params[:id])
    result = ThesaurusConcept.find_parent(UriV2.new(uri: uri))
    if !result.nil?
      if (result[:rdf_type] == Thesaurus::C_RDF_TYPE_URI.to_s)
        item_find_and_render(Thesaurus, result[:uri], "Thesaurus Concept") { |item| item.to_json }
      else
        item_find_and_render(ThesaurusConcept, result[:uri], "Thesaurus Concept") { |item| item.to_json }
      end
    else
      render json: {errors: thesaurus_concept_parent_not_found_error(uri)}, status: 404
    end
  end

private 

  def the_params
    params.permit(:notation, :identifier)
  end  

  def thesaurus_concept_not_found_error
		tc = ThesaurusConcept.new
    tc.errors.add(:base, "Failed to find Thesaurus Concept with #{the_params}")
    return tc.errors.full_messages
  end

  def thesaurus_concept_parent_not_found_error(uri)
    tc = ThesaurusConcept.new
    tc.errors.add(:base, "Failed to find parent of Thesaurus Concept #{uri}")
    return tc.errors.full_messages
  end

end