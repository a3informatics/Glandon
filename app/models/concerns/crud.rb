require "Rest"

module CRUD

  def CRUD.query (sparql)
    
    key = SEMANTIC_DB_CONFIG['apiKey'] 
    secret = SEMANTIC_DB_CONFIG['secret']
    endpoint = SEMANTIC_DB_CONFIG['queryEndpoint']
    headers = {'Accept' => "application/sparql-results+xml",
            'Content-type'=> "application/x-www-form-urlencoded"}
    
    data = "query=" + sparql
    p "Find(query):" + data
            
    # Send the request, wait the resonse
    response = Rest.sendRequest(endpoint,:post,key + ":" + secret,data,headers)
    
  end

  def CRUD.update (sparql)
  
    key = SEMANTIC_DB_CONFIG['apiKey'] 
    secret = SEMANTIC_DB_CONFIG['secret']
    endpoint = SEMANTIC_DB_CONFIG['updateEndpoint']
    headers = {'Content-type'=> "application/x-www-form-urlencoded"}

    data = "update=" + sparql
    p "Create(update):" + data
    
    # Send the request, wait the resonse
    response = Rest.sendRequest(endpoint,:post,key + ":" + secret,data,headers)
      
  end
  
end

    