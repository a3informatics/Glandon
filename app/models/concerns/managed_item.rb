require "nokogiri"
require "uri"

class ManagedItem

  include CRUD
  include ModelUtility
      
  attr_accessor :id, :type, :registrationState, :scopedIdentifier, :origin, :changeDescription, :creationDate, :lastChangedDate, :explanoratoryComment
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CLASS_NAME = "ManagedItem"
  C_AI = 1
  C_II = 2
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  # Note: The id is the identifier for the enclosing managed object.
  def self.find(id, ns="")
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    object = nil
    useNs = ns || @@baseNs
    ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
    
    # Create the query
    query = UriManagement.buildPrefix(useNs, ["isoI", "isoT"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g WHERE \n" +
      "{ \n" +
      "  :" + id + " isoI:hasIdentifier ?a . \n" +
      "  OPTIONAL { \n" +
      "    :" + id + " isoI:hasState ?b . \n" +
      "    :" + id + " isoT:origin ?c . \n" +
      "    :" + id + " isoT:changeDescription ?d . \n" +
      "    :" + id + " isoT:creationDate ?e . \n" +
      "    :" + id + " isoT:lastChangedDate  ?f . \n" +
      "    :" + id + " isoT:explanoratoryComment ?g . \n" +
      "  } \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      iiSet = node.xpath("binding[@name='a']/uri")
      rsSet = node.xpath("binding[@name='b']/uri")
      oSet = node.xpath("binding[@name='c']/literal")
      descSet = node.xpath("binding[@name='d']/literal")
      dateSet = node.xpath("binding[@name='e']/literal")
      lastSet = node.xpath("binding[@name='f']/literal")
      commentSet = node.xpath("binding[@name='g']/literal")
      if iiSet.length == 1 
        object = self.new
        object.id = id
        object.scopedIdentifier = ScopedIdentifier.find(ModelUtility.extractCid(iiSet[0].text))
        if rsSet.length == 1
          object.registrationState = RegistrationState.find(ModelUtility.extractCid(rsSet[0].text))
          object.origin = oSet[0].text
          object.changeDescription = descSet[0].text
          object.creationDate = dateSet[0].text
          object.lastChangedDate = lastSet[0].text
          object.explanoratoryComment = commentSet[0].text
          object.type = C_AI
        else
          object.RegistrationState = nil
          object.origin = ""
          object.changeDescription = ""
          object.creationDate = ""
          object.lastChangedDate = ""
          object.explanoratoryComment = ""
          object.type = C_II
        end
      end
    end
    
    # Return
    return object
    
  end

  def self.create_imported(id, params, ns="")
  
    useNs = ns || @@baseNs

    object = self.new
    object.id = id
    object.scopedIdentifier = ScopedIdentifier.create(params)
    object.administeredItem = nil
    object.type = C_II
    object.origin = ""
    object.changeDescription = ""
    object.creationDate = ""
    object.lastChangedDate = ""
    object.explanoratoryComment = ""

    update = UriManagement.buildPrefix(ns, ["isoI"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " isoI:hasIdentifier :" + object.scopedIdentifier.id + " . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create_imported","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create_imported","Failed")
    end
    return object
  
  end

  def self.create_local(id, params, ns="")

    useNs = ns || @@baseNs
    timestamp = Time.now
  
    object = self.new
    object.id = id
    object.scopedIdentifier = ScopedIdentifier.create(params)
    object.registrationState = RegistrationState.create(params)
    object.type = C_AI
    object.origin = ""
    object.changeDescription = "Creation"
    object.creationDate = timestamp
    object.lastChangedDate = ""
    object.explanoratoryComment = ""
  
    update = UriManagement.buildPrefix(ns, ["isoT", "isoI"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " isoI:hasIdentifier :" + object.scopedIdentifier.id + " . \n" +
      " :" + id + " isoI:hasState :" + object.registrationState.id + " . \n" +
      " :" + id + " isoT:origin \"\"^^xsd:string . \n" +
      " :" + id + " isoT:changeDescription \"Creation\"^^xsd:string . \n" +
      " :" + id + " isoT:creationDate \"" + timestamp.to_s + "\"^^xsd:string . \n" +
      " :" + id + " isoT:lastChangedDate \"\"^^xsd:string . \n" +
      " :" + id + " isoT:explanoratoryComment \"\"^^xsd:string . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create_local","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create_local","Failed")
    end

    return object

  end 

  def update(id)
    return nil
  end

  def destroy
    return nil
  end

end