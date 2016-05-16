require "rest"
require "json"

module CRUD

    # Constants
    C_CLASS_NAME = "CRUD"
    
    # Method sends the sparql query to the configured triple store endpoint.
    # Results are returned in XML format.
    #
    # * *Args*    :
    #   - +sparql+ -> The sparql query
    # * *Returns* :
    #   - The HTTP response object
    def CRUD.query (sparql)
        db = SEMANTIC_DB_CONFIG['dbType']
        key = SEMANTIC_DB_CONFIG['apiKey'] 
        secret = SEMANTIC_DB_CONFIG['secret']
        endpoint = SEMANTIC_DB_CONFIG['queryEndpoint']
        headers = {"Accept" => "application/sparql-results+xml", "Content-type" => "application/x-www-form-urlencoded"}
        data = "query=" + sparql
        response = Rest.sendRequest(endpoint,:post,key,secret,data,headers)
    end

    # Method sends the sparql update query to the configured triple store endpoint.
    # Results are returned in XML format.
    #
    # * *Args*    :
    #   - +sparql+ -> The sparql query
    # * *Returns* :
    #   - The HTTP response object
    def CRUD.update (sparql)
        db = SEMANTIC_DB_CONFIG['dbType']
        key = SEMANTIC_DB_CONFIG['apiKey'] 
        secret = SEMANTIC_DB_CONFIG['secret']
        endpoint = SEMANTIC_DB_CONFIG['updateEndpoint']
        headers = {"Content-type" => "application/x-www-form-urlencoded"}
        data = "update=" + sparql
        response = Rest.sendRequest(endpoint,:post,key,secret,data,headers)
    end
  
    # Method sends the file to the configured triple store endpoint.
    #
    # * *Args*    :
    #   - +sparql+ -> The sparql query
    # * *Returns* :
    #   - The HTTP response object
    def CRUD.file (file)
        db = SEMANTIC_DB_CONFIG['dbType']
        key = SEMANTIC_DB_CONFIG['apiKey'] 
        secret = SEMANTIC_DB_CONFIG['secret']
        endpoint = SEMANTIC_DB_CONFIG['fileEndpoint']
        headers = {"Content-type" => "multipart/form-data"}
        data = { "filename" => file}
        jsonData = data.to_json
        response = Rest.sendFile(endpoint,:post,key,secret,jsonData,file,headers)
    end
  
end

    