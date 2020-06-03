module ControllerHelpers
  
  def check_good_json_response(response)
    expect(response.code).to eq("200")
    expect(response.content_type).to eq("application/json")
    JSON.parse(response.body, symbolize_names: true)  
  end

end