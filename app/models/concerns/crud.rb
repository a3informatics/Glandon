# CRUD. CRUD operations for the semantic database
#
# @author Dave Iberson-Hurst
# @since 0.0.1

require "rest"
require "json"

module CRUD

  # Query. Sends the sparql query to the configured triple store endpoint.
  #
  # @param [String] sparql the sparql query
  # @return [Object] The HTTP response object in XML
  def CRUD.query (sparql)
    headers = {"Accept" => "application/sparql-results+xml", "Content-type" => "application/x-www-form-urlencoded"}
    response = Rest.sendRequest(endpoint(:query), :post, api_key, api_secret, "query=#{sparql}", headers)
  end

  # Update. Sends the sparql update to the configured triple store endpoint.
  #
  # @param [String] sparql the sparql query
  # @return [Object] The HTTP response object in XML
  def CRUD.update (sparql)
    headers = {"Content-type" => "application/x-www-form-urlencoded"}
    response = Rest.sendRequest(endpoint(:update), :post, api_key, api_secret, "update=#{sparql}", headers)
  end

  # Method 
  # File. Uploads the file to the configured triple store endpoint.
  #
  # @param [String] sparql the sparql query
  # @return [Object] The HTTP response object in XML
  def CRUD.file (file)
    headers = {"Content-type" => "multipart/form-data"}
    response = Rest.sendFile(endpoint(:upload), :post, api_key, api_secret, {"filename" => file}.to_json, file, headers)
  end

private

  # Get the end point
  def self.endpoint(type)
    # protocol :// host_name : port_name / dataset / endpoint_type
    return "#{ENV["SEMANTIC_DB_PROTOCOL"]}://#{ENV["SEMANTIC_DB_HOST"]}:#{ENV["SEMANTIC_DB_PORT"]}/#{ENV["SEMANTIC_DB_DATASET"]}/#{type}"
  end

  # Get the API key
  def self.api_key
    return ENV["SEMANTIC_DB_API_KEY"]
  end

  # Het the API password
  def self.api_secret
    return ENV["SEMANTIC_DB_API_SECRET"]
  end
   
end

    