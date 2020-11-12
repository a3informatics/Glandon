module ControllerHelpers
  
  def check_good_json_response(response)
    check_json_response("200")
  end

  def check_error_json_response(response)
    check_json_response("422")
  end

  def check_json_response(code)
    expect(response.code).to eq(code)
    expect(response.content_type).to eq("application/json")
    JSON.parse(response.body, symbolize_names: true)  
  end

end