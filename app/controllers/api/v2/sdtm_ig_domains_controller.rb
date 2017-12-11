class Api::V2::SdtmIgDomainsController < Api::V2::BaseController
  
  C_CLASS_NAME = "Api::V2::SdtmIgDomainsController"

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

end