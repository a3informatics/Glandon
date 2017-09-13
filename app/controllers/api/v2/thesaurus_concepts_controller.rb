class Api::V2::ThesaurusConceptsController < ActionController::Base
  
  http_basic_authenticate_with name: ENV["api_username"], password: ENV["api_password"]

	C_CLASS_NAME = "Api::V2::ThesaurusConceptsController"

  def index
    results = []
    ths = Thesaurus.current_set
    if params.length > 0
    	ths.each do |th|
    		thcs = ThesaurusConcept.find_by_property(the_params, th.namespace)
    		thcs.each {|x| results << x.to_json}
    	end	
    	if !results.empty?
	    	render json: results, status: 200
  	  else
    		render json: {errors: thesaurus_not_found_error}, status: 404
    	end
    else
    	render json: {errors: thesaurus_not_found_error}, status: 404
    end
  end

private 

  def the_params
    params.permit(:notation, :identifier)
  end  

  def thesaurus_not_found_error
		th = Thesaurus.new
    th.errors.add(:base, "Failed to find thesaurus concept with #{the_params}")
    return th.errors.full_messages
  end

end