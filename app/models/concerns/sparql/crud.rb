require "rest"

# CRUD. CRUD operations for the semantic database
#
# @author Dave Iberson-Hurst
# @since 2.22.0
module Sparql

  module CRUD

    # Query. Sends the sparql query to the configured triple store endpoint.
    #
    # @param [String] sparql the sparql query
    # @return [Object] The HTTP response object in XML
    def send_query (sparql)
      headers = {"Accept" => "application/sparql-results+xml", "Content-type" => "application/x-www-form-urlencoded"}
      response = Rest.sendRequest(api_endpoint(:query), :post, api_key, api_secret, api_encode("query", sparql), headers)
    end

    # Update. Sends the sparql update to the configured triple store endpoint.
    #
    # @param [String] sparql the sparql query
    # @return [Object] The HTTP response object in XML
    def send_update (sparql)
      headers = {"Content-type" => "application/x-www-form-urlencoded"}
      response = Rest.sendRequest(api_endpoint(:update), :post, api_key, api_secret, api_encode("update", sparql), headers)
    end

    # Method 
    # File. Uploads the file to the configured triple store endpoint.
    #
    # @param [String] sparql the sparql query
    # @return [Object] The HTTP response object in XML
    def send_file (file)
      headers = {"Content-type" => "multipart/form-data"}
      response = Rest.sendFile(api_endpoint(:upload), :post, api_key, api_secret, {"filename" => file}.to_json, file, headers)
    end

  private

    def api_encode(param, value)
      result = URI.encode_www_form([["#{param}", "#{value}"]])
      result
    end

    # Get the end point
    def api_endpoint(type)
      # protocol :// host_name : port_name / dataset / endpoint_type
      return "#{ENV["SEMANTIC_DB_PROTOCOL"]}://#{ENV["SEMANTIC_DB_HOST"]}:#{ENV["SEMANTIC_DB_PORT"]}/#{ENV["SEMANTIC_DB_DATASET"]}/#{type}"
    end

    # Get the API key
    def api_key
      return ENV["SEMANTIC_DB_API_KEY"]
    end

    # Het the API password
    def api_secret
      return ENV["SEMANTIC_DB_API_SECRET"]
    end
     
  end

end

    