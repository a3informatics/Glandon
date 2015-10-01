require "rest"
require "json"

module CRUD

  def CRUD.query (sparql)
    
    db = SEMANTIC_DB_CONFIG['dbType']
    key = SEMANTIC_DB_CONFIG['apiKey'] 
    secret = SEMANTIC_DB_CONFIG['secret']
    endpoint = SEMANTIC_DB_CONFIG['queryEndpoint']
    headers = {'Accept' => "application/sparql-results+xml",
            'Content-type'=> "application/x-www-form-urlencoded"}
    data = "query=" + sparql
    p "Find(query):" + data
            
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
    p "Create(update):" + data
    
    # Send the request, wait the resonse
    response = Rest.sendRequest(endpoint,:post,key,secret,data,headers)
      
  end
  
  def CRUD.file (file)
  
    db = SEMANTIC_DB_CONFIG['dbType']
    key = SEMANTIC_DB_CONFIG['apiKey'] 
    secret = SEMANTIC_DB_CONFIG['secret']
    #endpoint = SEMANTIC_DB_CONFIG['fileEndpoint']
    endpoint = "http://192.168.2.101:3030/mdr/upload"
    headers = {'Content-type'=> "multipart/form-data"}
    #headers = {'Content-Type'=> "application/json"}
    data = { "filename" => file}
    jsonData = data.to_json
    
    p "CRUD::file=" + jsonData.to_s
    
    # Send the file, wait for the response
    response = Rest.sendFile(endpoint,:post,key,secret,jsonData,file,headers)
      
  end
  
end

    