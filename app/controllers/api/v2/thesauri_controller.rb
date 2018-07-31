class Api::V2::ThesauriController < Api::V2::BaseController
  
  C_CLASS_NAME = "Api::V2::ThesauriController"

  def show
    uri = UriV2.new(uri: id_to_uri(params[:id]))
    item = Thesaurus.find(uri.id, uri.namespace)
    if !item.id.empty?
      render json: item.to_json, status: 200
    else
      item = Thesaurus.new
      item.errors.add(:base, "Failed to find Thesaurus #{uri}")
      render json: {errors: item.errors.full_messages}, status: 404
    end
  end

end