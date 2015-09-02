require "typhoeus"

module Rest

  def Rest.sendRequest(endpoint, method, userpwd, data, headers)
    
    hydra = Typhoeus::Hydra.hydra
    req = Typhoeus::Request.new(endpoint,
        method: :post,
        userpwd: userpwd, 
        body: data,
        headers: headers)
    hydra.queue(req)
    hydra.run
    response = req.response
    
    p response.body
    
    return response
    
  end

end