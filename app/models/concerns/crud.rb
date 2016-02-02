require "rest"
require "json"

module CRUD

    C_CLASS_NAME = "CRUD"
    C_XML = 1
    C_TTL = 2

    def CRUD.TTL
        return C_TTL
    end
    
    def CRUD.query (sparql, response=C_XML)

        db = SEMANTIC_DB_CONFIG['dbType']
        key = SEMANTIC_DB_CONFIG['apiKey'] 
        secret = SEMANTIC_DB_CONFIG['secret']
        endpoint = SEMANTIC_DB_CONFIG['queryEndpoint']
        if response == C_TTL
            headers = {'Content-type'=> "application/x-www-form-urlencoded"}
        else
            headers = {'Accept' => "application/sparql-results+xml",
                    'Content-type'=> "application/x-www-form-urlencoded"}
        end
        data = "query=" + sparql
        #ConsoleLogger::log(C_CLASS_NAME,"query",data)
                
        # Send the request, wait the resonse
        response = Rest.sendRequest(endpoint,:post,key,secret,data,headers)

    end

    def CRUD.update (sparql)
  
        db = SEMANTIC_DB_CONFIG['dbType']
        key = SEMANTIC_DB_CONFIG['apiKey'] 
        secret = SEMANTIC_DB_CONFIG['secret']
        endpoint = SEMANTIC_DB_CONFIG['updateEndpoint']
        headers = {'Content-type'=> "application/x-www-form-urlencoded"}
        data = "update=" + sparql
        #ConsoleLogger::log(C_CLASS_NAME,"update",data)
        
        # Send the request, wait the resonse
        response = Rest.sendRequest(endpoint,:post,key,secret,data,headers)
      
    end
  
    def CRUD.file (file)
  
        db = SEMANTIC_DB_CONFIG['dbType']
        key = SEMANTIC_DB_CONFIG['apiKey'] 
        secret = SEMANTIC_DB_CONFIG['secret']
        endpoint = SEMANTIC_DB_CONFIG['fileEndpoint']
        headers = {'Content-type'=> "multipart/form-data"}
        data = { "filename" => file}
        jsonData = data.to_json
        #ConsoleLogger::log(C_CLASS_NAME,"file",jsonData.to_s)
        
        # Send the file, wait for the response
        response = Rest.sendFile(endpoint,:post,key,secret,jsonData,file,headers)
      
    end
  
end

    