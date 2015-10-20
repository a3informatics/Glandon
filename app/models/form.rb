require "uri"

class Form
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :scopedIdentifierId, :identifier, :version, :name, :groups
  validates_presence_of :scopedIdentifierId, :identifier, :version, :name, :groups
  
  # Constants
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
    query = UriManagement.buildPrefix("mdrForm", ["bo","bf","cbc", "item", "isoI"]) +
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
        object.groups = Hash.new
        object.id = id
        ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
        #object.scopedIdentifierId = ModelUtility.extractCid(siSet[0].text)
        #si = ScopedIdentifier.find(object.scopedIdentifierId)
        #object.identifier = si.identifier
        #object.version = si.version
        object.name = nSet[0].text
        object.groups = Form::FormGroup.findForForm(id, cdiscTerm)
      end
    end
    return object  
    
  end

  def self.all()
    
    results = Hash.new
    query = UriManagement.buildPrefix("mdrForm", ["bo","bf","cbc", "item", "isoI"]) 
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
        #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        ConsoleLogger::log(C_CLASS_NAME,"find","Form Id=" + object.id)
        object.name = nSet[0].text
        results[object.id] = object
      end
    end
    return results  
    
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
