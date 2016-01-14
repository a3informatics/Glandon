require "typhoeus"

module Rest

  C_CLASS_NAME = "Rest"

  # Send a request to the server 
  def Rest.sendRequest(endpoint, method, user, pwd, data, headers)
    
    hydra = Typhoeus::Hydra.hydra
    if user == "" 
      req = Typhoeus::Request.new(endpoint,
        method: method,
        body: data,
        headers: headers)
    else
      userpwd = user + ":" + pwd
      req = Typhoeus::Request.new(endpoint,
        method: method,
        userpwd: userpwd, 
        body: data,
        headers: headers)
    end
    hydra.queue(req)
    hydra.run
    response = req.response
    #ConsoleLogger::log(C_CLASS_NAME,"sendRequest",response.body)
    return response
    
  end

  # Upload a file to the endpoint
  def Rest.sendFile(endpoint, method, user, pwd, data, file, headers)
    
    hydra = Typhoeus::Hydra.hydra
    if user == "" 
      req = Typhoeus::Request.new(endpoint,
        method: method,
        body: { file: File.open(file,"r") },
        headers: headers)
    else
      userpwd = user + ":" + pwd
      req = Typhoeus::Request.new(endpoint,
        method: method,
        userpwd: userpwd, 
        body: { file: File.open(file,"r") },
        headers: headers)
    end 
    #hydra.queue(req)
    #hydra.run
    req.run
    response = req.response
    #ConsoleLogger::log(C_CLASS_NAME,"sendFile",response.body)
    return response
    
  end
  
end