require "typhoeus"

module Rest

  # Send a request to the server 
  def Rest.sendRequest(endpoint, method, userpwd, data, headers)
    
    hydra = Typhoeus::Hydra.hydra
    req = Typhoeus::Request.new(endpoint,
        method: method,
        userpwd: userpwd, 
        body: data,
        headers: headers)
    hydra.queue(req)
    hydra.run
    response = req.response
    
    p response.body
    
    return response
    
  end

  # Upload a file to the endpoint
  def Rest.sendFile(endpoint, method, userpwd, file, headers)
    
    hydra = Typhoeus::Hydra.hydra
    req = Typhoeus::Request.new(endpoint,
        method: method,
        userpwd: userpwd, 
        file: file,
        headers: headers)
    hydra.queue(req)
    hydra.run
    response = req.response
    
    p response.body
    
    return response
    
  end
  
end