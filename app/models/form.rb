require "uri"

class Form
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :managedItem, :name, :groups
  validates_presence_of :id, :managedItem, :name, :groups
  
  # Constants
  C_NS_PREFIX = "mdrForms"
  C_CLASS_NAME = "Form"
  C_CID_PREFIX = "F"
  
  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    #return @baseNs
  end
  
  def self.find(id, cdiscTerm)
    
    object = nil
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bo","bf"]) +
      "SELECT ?a WHERE\n" + 
      "{ \n" + 
      " :" + id + " rdf:type bf:Form . \n" +
      " :" + id + " bo:name ?a . \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      nSet = node.xpath("binding[@name='a']/literal")
      if nSet.length == 1 
        object = self.new 
        object.id = id
        ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
        object.managedItem = ManagedItem.find(id, C_NS_PREFIX)
        object.name = nSet[0].text
        object.groups = Form::FormGroup.findForForm(id, cdiscTerm)
      end
    end
    return object  
    
  end

  def self.all()
    
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bf", "bo"]) 
    query = query +
      "SELECT ?a ?b WHERE\n" + 
      "{ \n" + 
      " ?a rdf:type bf:Form . \n" +
      " ?a bo:name ?b . \n" +
      "} \n"
      
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      nSet = node.xpath("binding[@name='b']/literal")
      if uriSet.length == 1 && nSet.length == 1 
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        ConsoleLogger::log(C_CLASS_NAME,"find","Form Id=" + object.id)
        object.name = nSet[0].text
        results[object.id] = object
      end
    end
    return results  
    
  end

  def self.create_placeholder(params)
    
    ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Entry")
    object = nil
    
    # Get the parameters
    name = params[:name]
    shortName = params[:shortName]
    freeText = params[:freeText]
    version = "1"

    # Create the id for the form
    id = ModelUtility.buildCidVersion(C_CID_PREFIX, shortName, version)

    # Create the managed item for the form. The namespace id is a shortcut for the moment.
    managedItem = ManagedItem.create_local(id, {:version => version, :identifier => name, :shortName => shortName, :namespace_id => "items:NS-ACME"}, C_NS_PREFIX)

    # Now create the group (which will create the item). We only need a 
    # single group for a placeholder form.
    group = FormGroup.create_placeholder(id, shortName, 1, version, freeText)
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX,["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + id + " rdf:type bf:Form . \n" +
      "  :" + id + " bo:name \"" + name + "\"^^xsd:string . \n" +
      "  :" + id + " bf:hasGroup :" + group.id + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.managedItem = managedItem
      object.name = name
      object.groups = Hash.new
      object.groups[group.id] = group
    else
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Exit")
    return object

  end

  def self.create(params)
    object = nil
    return object
  end

  def update
    return nil
  end

  def destroy
  end
  
end
