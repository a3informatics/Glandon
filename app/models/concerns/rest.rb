require "typhoeus"

module Rest

  C_CLASS_NAME = "Rest"

  # Send a request to the endpoint (URL).
  #
  # * *Args*    :
  #   - +endpoint+ -> The endpoint URL
  #   - +method+ -> The method to be used
  #   - +user+ -> Username (if required, "" otherwise)
  #   - +pwd+ -> password (if required, otherwise "")
  #   - +data+ -> The data
  #   - +headers+ -> The headers
  # * *Returns* :
  #   - The HTTP response object
  def Rest.sendRequest(endpoint, method, user, pwd, data, headers)
    timeout = APP_CONFIG['rest_timeout']
    #ConsoleLogger::log(C_CLASS_NAME,"sendRequest","Timeout=" + timeout.to_s)
    hydra = Typhoeus::Hydra.hydra
    if user == "" 
      req = Typhoeus::Request.new(endpoint,
        method: method,
        body: data,
        timeout: timeout,
        headers: headers)
    else
      userpwd = user + ":" + pwd
      req = Typhoeus::Request.new(endpoint,
        method: method,
        userpwd: userpwd, 
        timeout: timeout,
        body: data,
        headers: headers)
    end
    hydra.queue(req)
    hydra.run
    response = req.response
    #ConsoleLogger::log(C_CLASS_NAME,"sendRequest","Response=" + response.body.to_s)
    return response
  end

  # Upload a file to the endpoint
  #
  # * *Args*    :
  #   - +endpoint+ -> The endpoint URL
  #   - +method+ -> The method to be used
  #   - +user+ -> Username (if required, "" otherwise)
  #   - +pwd+ -> password (if required, otherwise "")
  #   - +file+ -> The file (full path)
  #   - +headers+ -> The headers
  # * *Returns* :
  #   - The HTTP response object
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