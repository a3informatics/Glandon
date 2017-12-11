class Api::V2::BaseController < ActionController::Base
  
  http_basic_authenticate_with name: ENV["api_username"], password: ENV["api_password"] 
  
private 

  def id_to_uri(id)
    return Base64.strict_decode64(id)
  end

  def uri_to_id(uri)
    return Base64.strict_encode64(uri)
  end

  def item_find_and_render(klass, uri, error_text)
    item = item_find(klass, uri, error_text)
    if item.errors.empty?
      response = yield(item)
      render json: response, status: 200
    else
      render json: {errors: item.errors.full_messages}, status: 404
    end
  rescue => e
  end

  def item_find(klass, uri, error_text)
    return klass.find(uri.id, uri.namespace)
  rescue => e
    item = klass.new
    item.errors.add(:base, "Failed to find #{error_text} #{uri}")
    return item
  end

end