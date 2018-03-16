class Api::V2::SdtmIgDomainsController < Api::V2::BaseController
  
  C_CLASS_NAME = "Api::V2::SdtmIgDomainsController"

  def clones
    results = []
    uri = UriV2.new(uri: id_to_uri(params[:id]))
    domain = item_find(SdtmIgDomain, uri, "SDTM IG Domain")
    if domain.errors.empty?
      clones = domain.find_links_from_to(false, true).select { |d| d[:rdf_type] == SdtmUserDomain::C_RDF_TYPE_URI.to_s }
      clones.each { |clone| results << SdtmUserDomain.find(clone[:uri].id, clone[:uri].namespace, false).to_json }
      render json: results, status: 200
    else
      render json: {errors: domain.errors.full_messages}, status: 404
    end
  end

  def show
    uri = UriV2.new(uri: id_to_uri(params[:id]))
    item_find_and_render(SdtmIgDomain, uri, "SDTM IG Domain") do |item|
      json = item.to_json
      json[:children].each do |child|
        child[:variable_ref][:subject_data] = SdtmModelDomain::Variable.find(child[:variable_ref][:subject_ref][:id], 
          child[:variable_ref][:subject_ref][:namespace]).to_json
        t = child[:variable_ref][:subject_data] 
        t[:variable_ref][:subject_data] = SdtmModel::Variable.find(t[:variable_ref][:subject_ref][:id], 
          t[:variable_ref][:subject_ref][:namespace]).to_json
      end
      json
    end
  end

private

  def domain_not_found_error
    uri = UriV2.new(uri: id_to_uri(params[:id]))
    item = SdtmIgDomain.new
    item.errors.add(:base, "Failed to find SDTM IG Domain #{uri}")
    return item.errors.full_messages
  end

end