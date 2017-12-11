class Api::V2::SdtmUserDomainsController < Api::V2::BaseController
  
  C_CLASS_NAME = "Api::V2::SdtmUserDomainsController"

  def show
    uri = UriV2.new(uri: id_to_uri(params[:id]))
    item_find_and_render(SdtmUserDomain, uri, "Sponsor Domain") do |item|
      json = item.to_json
      json[:children].each do |child|
        child[:variable_ref][:subject_data] = child[:variable_ref].blank? ? SdtmIgDomain::Variable.new.to_json : 
          SdtmIgDomain::Variable.find(child[:variable_ref][:subject_ref][:id], child[:variable_ref][:subject_ref][:namespace]).to_json
      end
      json
    end
  end

end