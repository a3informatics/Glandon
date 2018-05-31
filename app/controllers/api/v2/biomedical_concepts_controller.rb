class Api::V2::BiomedicalConceptsController < Api::V2::BaseController
  
  C_CLASS_NAME = self.name

  def domains
    uri = UriV2.new(uri: id_to_uri(params[:id]))
    bc = item_find(BiomedicalConcept, uri, "Biomedical Concept")
    if bc.errors.empty?
      results = []
      bc.domains.each {|x| results << x.to_s}
      render json: results, status: 200
    else
      render json: {errors: bc.errors.full_messages}, status: 404
    end
  end

end