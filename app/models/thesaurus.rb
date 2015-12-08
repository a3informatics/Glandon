require "nokogiri"
require "uri"

class Thesaurus

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :managedItem, :children
  validates_presence_of :id, :managedItem, :children
 
  # Constants
  C_CLASS_NAME = "Thesaurus"
  C_CID_PREFIX = "TH"
  C_NS_PREFIX = "mdrTh"
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def version
    return self.managedItem.version
  end

  def versionLabel
    return self.managedItem.versionLabel
  end

  def identifier
    return self.managedItem.identifier
  end

  def namespace
    return self.managedItem.namespace
  end

  def persisted?
    id.present?
  end
 
  def initialize()
  end

  def self.baseNs
    return @@baseNs 
  end
  
  def self.find(id, ns=nil)
    
    object = nil
    useNs = ns || @@baseNs
    object = self.new 
    object.id = id
    object.managedItem = ManagedItem.find(id,useNs)
    object.children = ThesaurusConcept.allTopLevel(id,useNs)
    return object
    
  end

  def self.findByNamespaceId(namespaceId)
    
    results = Array.new
    
    query = UriManagement.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a ?b ?c WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      if uriSet.length == 1
        managedItem = ManagedItem.find(ModelUtility.extractCid(uriSet[0].text),ModelUtility.extractNs(uriSet[0].text))
        if (managedItem != nil)
          if (managedItem.scopedIdentifier.namespace.id == namespaceId)
            object = self.new 
            object.id = ModelUtility.extractCid(uriSet[0].text)
            #object.namespace = ModelUtility.extractNs(uriSet[0].text)
            object.managedItem = managedItem
            results.push (object)
            ConsoleLogger::log(C_CLASS_NAME,"findByNamespaceId","Object created id=" + object.id)
          end 
        end
        
      end
    end
    
    return results
    
  end
  
  def self.findWithoutNs(id)
    
    ConsoleLogger::log(C_CLASS_NAME,"findWithoutNs","id=" + id)
    object = nil
    query = UriManagement.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      if uriSet.length == 1 
        tId = ModelUtility.extractCid(uriSet[0].text)
        ConsoleLogger::log(C_CLASS_NAME,"findWithoutNs","tid=" + tId)
        if (tId == id)
          managedItem = ManagedItem.find(ModelUtility.extractCid(uriSet[0].text),ModelUtility.extractNs(uriSet[0].text))
          if (managedItem != nil)
            object = self.new 
            object.id = ModelUtility.extractCid(uriSet[0].text)
            #object.namespace = ModelUtility.extractNs(uriSet[0].text)
            object.managedItem = managedItem
            object.children = ThesaurusConcept.allTopLevel(object.id,object.namespace)
            ConsoleLogger::log(C_CLASS_NAME,"findWithoutNs","Object created id=" + object.id)
          end
        end
      end
    end
    
    return object
    
  end
  
  def self.all
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a ?b ?c WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      if uriSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.managedItem = ManagedItem.find(object.id,ModelUtility.extractNs(uriSet[0].text))
        results.push (object)
        
      end
    end
    
    return results
    
  end

  def self.createLocal(params)
    
    # Get the parameters
    version = params[:version]
    versionLabel = params[:versionLabel]
    identifier = params[:identifier]
    label = params[:label]
    
    # Create the managed item for the thesaurus. 
    managedItem = ManagedItem.create(C_CID_PREFIX, params, @@baseNs)
    id = managedItem.id
    useNs = managedItem.namespace

    # Create the query
    update = UriManagement.buildNs(useNs,["isoI", "iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type iso25964:Thesaurus . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.managedItem = managedItem
      ConsoleLogger::log(C_CLASS_NAME,"createLocal","Object created, id=" + id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"createLocal","Object not created!")
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def self.createImported(params, ns=nil)
    
    # Set the namespaceitemTy
    useNs = ns || @@baseNs

    # Get the parameters
    version = params[:version]
    versionLabel = params[:versionLabel]
    identifier = params[:identifier]
    namespaceId = params[:namespaceId]
    label = params[:label]
    
    ConsoleLogger::log(C_CLASS_NAME,"createImported","*****ENTRY*****")
    ConsoleLogger::log(C_CLASS_NAME,"createImported",
      "namespaceId=" + namespaceId + ", " + 
      "versionLabel=" + versionLabel + ", " + 
      "version=" + version + ", " + 
      "identifier" + identifier + ", " + 
      "itemType=" + itemType )

    # Create the managed item for the thesaurus.
    managedItem = ManagedItem.import(C_CID_PREFIX, params, namespaceId, @@baseNs)
    id = managedItem.id

    # Create the query
    update = UriManagement.buildNs(useNs,["isoI", "iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + id + " rdf:type iso25964:Thesaurus . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.namespace = useNs
      object.managedItem = managedItem
      ConsoleLogger::log(C_CLASS_NAME,"createImported","Object created, id=" + id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"createImported","Object not created!")
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def update(params)

    ConsoleLogger::log(C_CLASS_NAME,"update","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"update","Params=" + params.to_s)

    # Access the data
    data = params[:data]
    if data != nil
      ConsoleLogger::log(C_CLASS_NAME,"update","Delete, data=" + data.to_s)
      deleteItem = data[:deleteItem]
      updateItem = data[:updateItem]
      addItem = data[:addItem]

      # Delete items
      if (deleteItem != nil)
        ConsoleLogger::log(C_CLASS_NAME,"update","Delete, item=" + deleteItem.to_s)
        concept = ThesaurusConcept.find(deleteItem[:id], self.namespace)
        concept.destroy(self.namespace, self.id)
      end

      # Add items
      if (addItem != nil)
        ConsoleLogger::log(C_CLASS_NAME,"update","Insert, item=" + addItem.to_s)
        if (addItem[:parent] == self.id) 
          ThesaurusConcept.createTopLevel(addItem, self.namespace, self.id)
        else
          if !ThesaurusConcept.exists?(addItem[:identifier], self.namespace)
            parentConcept = ThesaurusConcept.find(addItem[:parent], self.namespace)
            newConcept = ThesaurusConcept.create(addItem, self.namespace)
            parentConcept.addChild(newConcept, self.namespace)
          else
            ConsoleLogger::log(C_CLASS_NAME,"update","Update, concept exisits already" + addItem.to_s)
          end
        end
      end

      # Update items
      if (updateItem != nil)
        ConsoleLogger::log(C_CLASS_NAME,"update","Update, item=" + updateItem.to_s)
        concept = ThesaurusConcept.find(updateItem[:id], self.namespace)
        concept.update(updateItem, self.namespace)
      end
    end

  end

  def destroy(ns=nil)
  end
  
  def to_D3

    result = Hash.new
    result[:name] = self.identifier
    result[:namespace] = self.namespace
    result[:id] = self.id
    result[:children] = Array.new

    count = 0
    index = 0
    baseChildId = ""
    self.children.each do |key, child|
      if count == 0
        baseChildId = child.identifier;
        result[:children][index] = Hash.new
        result[:children][index][:name] = child.identifier;
        result[:children][index][:id] = child.id;
        result[:children][index][:expand] = true
        result[:children][index][:expansion] = Array.new        
        result[:children][index][:expansion][count] = Hash.new
        result[:children][index][:expansion][count][:name] = child.identifier + ' [' + child.notation + ']'
        result[:children][index][:expansion][count][:id] = child.id;
        result[:children][index][:expansion][count][:expand] = false
        result[:children][index][:expansion][count][:identifier] = child.identifier;
        result[:children][index][:expansion][count][:notation] = child.notation;
        result[:children][index][:expansion][count][:definition] = child.definition;
        result[:children][index][:expansion][count][:synonym] = child.synonym;
        result[:children][index][:expansion][count][:preferredTerm] = child.preferredTerm;
        count += 1
      elsif count == 9
        result[:children][index][:name] = baseChildId + ' - ' + child.identifier;
        result[:children][index][:expansion][count] = Hash.new
        result[:children][index][:expansion][count][:name] = child.identifier + ' [' + child.notation + ']'
        result[:children][index][:expansion][count][:id] = child.id;
        result[:children][index][:expansion][count][:expand] = false
        result[:children][index][:expansion][count][:identifier] = child.identifier;
        result[:children][index][:expansion][count][:notation] = child.notation;
        result[:children][index][:expansion][count][:definition] = child.definition;
        result[:children][index][:expansion][count][:synonym] = child.synonym;
        result[:children][index][:expansion][count][:preferredTerm] = child.preferredTerm;
        count = 0
        index += 1        
      else
        result[:children][index][:name] = baseChildId + ' - ' + child.identifier;
        result[:children][index][:expansion][count] = Hash.new
        result[:children][index][:expansion][count][:name] = child.identifier + ' [' + child.notation + ']'
        result[:children][index][:expansion][count][:id] = child.id;
        result[:children][index][:expansion][count][:expand] = false
        result[:children][index][:expansion][count][:identifier] = child.identifier;
        result[:children][index][:expansion][count][:notation] = child.notation;
        result[:children][index][:expansion][count][:definition] = child.definition;
        result[:children][index][:expansion][count][:synonym] = child.synonym;
        result[:children][index][:expansion][count][:preferredTerm] = child.preferredTerm;
        count += 1
      end
    end
    ConsoleLogger::log(C_CLASS_NAME,"to_D3","D3=" + result.to_s)
    return result

  end

end