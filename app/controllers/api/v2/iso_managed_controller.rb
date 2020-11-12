class Api::V2::IsoManagedController < Api::V2::BaseController
  
  C_CLASS_NAME = self.name

  def index
    if the_params.length > 0
      results = []
      results = IsoManaged.find_by_property(the_params)
    	if !results.empty?
	    	render json: results, status: 200
  	  else
    		render json: {errors: not_found_error}, status: 404
    	end
    else
    	render json: {errors: not_found_error}, status: 404
    end
  end

private 

  def the_params
    params.permit(:text)
  end  

  def not_found_error
		im = IsoManaged.new
    im.errors.add(:base, "Failed to find any items containing #{the_params}")
    return im.errors.full_messages
  end

end