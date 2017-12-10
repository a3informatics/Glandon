class Api::V2::BaseController < ActionController::Base
  
  http_basic_authenticate_with name: ENV["api_username"], password: ENV["api_password"] 
  
private 

  def id_to_uri(id)
    return Base64.strict_decode64(id)
  end

  def uri_to_id(uri)
    return Base64.strict_encode64(uri)
  end

end