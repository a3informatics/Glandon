require "typhoeus"

# Rest. A simple REST interface module
#
# @author Dave Iberson-Hurst
# @since 0.0.1
module Rest

  # SendRequest. Send a request to the endpoint (URL).
  #
  # @deprecated Use {#send_request} instead.
  # @param [String] endpoint the endpoint URL
  # @param [Symbol] method the method to be used
  # @param [String] username (if required, "" otherwise)
  # @param [String] password (if required, otherwise "")
  # @param [String] data the data
  # @param [Hash] headers the headers needed
  # @return [Response] the HTTP response object
  def Rest.sendRequest(endpoint, method, username, password, data, headers)
    send_request(endpoint, method, username, password, data, headers)
  end

  # Send Request. Send a request to the endpoint (URL).
  #
  # @param [String] endpoint the endpoint URL
  # @param [Symbol] method the method to be used
  # @param [String] username (if required, "" otherwise)
  # @param [String] password (if required, otherwise "")
  # @param [String] data the data
  # @param [Hash] headers the headers needed
  # @return [Response] the HTTP response object
  def Rest.send_request(endpoint, method, username, password, data, headers)
    timeout = APP_CONFIG['rest_timeout']
    hydra = Typhoeus::Hydra.hydra
    if username == "" 
      req = Typhoeus::Request.new(endpoint,
        method: method,
        body: data,
        timeout: timeout,
        headers: headers)
    else
      userpwd = username + ":" + password
      req = Typhoeus::Request.new(endpoint,
        method: method,
        userpwd: userpwd, 
        timeout: timeout,
        body: data,
        headers: headers)
    end
    hydra.queue(req)
    hydra.run
    req.response
  end

  # SendFile. Send a file to the endpoint (URL).
  #
  # @deprecated Use {#send_file} instead.
  # @param [String] endpoint the endpoint URL
  # @param [Symbol] method the method to be used
  # @param [String] username (if required, "" otherwise)
  # @param [String] password (if required, otherwise "")
  # @param [String] data not used
  # @param [String] file the full path
  # @param [Hash] headers the headers needed
  # @return [Response] the HTTP response object
  def Rest.sendFile(endpoint, method, username, password, data, file, headers)
    send_file(endpoint, method, username, password, file, headers)
  end

  # Send File. Send a file to the endpoint (URL).
  #
  # @param [String] endpoint the endpoint URL
  # @param [Symbol] method the method to be used
  # @param [String] username (if required, "" otherwise)
  # @param [String] password (if required, otherwise "")
  # @param [String] file the full path for the file
  # @param [Hash] headers the headers needed
  # @return [Response] the HTTP response object
  def Rest.send_file(endpoint, method, username, password, file, headers)
    #hydra = Typhoeus::Hydra.hydra
    if username == "" 
      req = Typhoeus::Request.new(endpoint,
        method: method,
        body: { file: File.open(file,"r") },
        headers: headers)
    else
      userpwd = username + ":" + password
      req = Typhoeus::Request.new(endpoint,
        method: method,
        userpwd: userpwd, 
        body: { file: File.open(file,"r") },
        headers: headers)
    end 
    req.run
    req.response
  end
  
end