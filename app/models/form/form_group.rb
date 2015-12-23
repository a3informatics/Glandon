require "uri"

class Form::FormGroup < IsoConceptInstance
  
  attr_accessor :items
  validates_presence_of :items
  
  # Constants
  C_NS_PREFIX = "mdrForms"
  C_CLASS_NAME = "FormGroup"
  C_CID_PREFIX = "FG"
  #C_ID_SEPARATOR = "_"
  
  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    #return @baseNs
  end
  
  def self.find(id, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY******")
    
    object = super(id, ns)
    object.items = Form::FormItem.findForGroup(object.links, ns)
    return object  
    
  end

  def self.findForForm(links, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"findForForm","*****ENTRY******")
    #ConsoleLogger::log(C_CLASS_NAME,"findForForm","Id=" + formId)
    ConsoleLogger::log(C_CLASS_NAME,"findForForm","namespace=" + ns)
    
    results = Hash.new
    links.each do |link|
      ConsoleLogger::log(C_CLASS_NAME,"findForForm","Id=" + link.range)
      if link.range == UriManagement.getNs("bf") + "#" + "Group"
        object = find(ModelUtility.extractCid(link.objectUri), ns)
        results[object.id] = object
      end 
    end
    return results
    
  end
  
  def self.all()
    return nil
  end

  def self.createPlaceholder (formId, ns, freeText)
   
    ordinal = 1
    id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    item = Form::FormItem.createPlaceholder(id, ns, freeText)
    update = UriManagement.buildNs(ns, ["bf"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"Placeholder\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:hasItem :" + item.id + " . \n" +
      " :" + id + " bf:isGroupOf :" + formId + " . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"createPlaceholder","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createPlaceholder","Failed")
    end

    return object
  
  end

  def self.createBcNormal (formId, ns, ordinal, bc)
   
    id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    refId = ModelUtility.cidAddSuffix(id, "BCRef")
    
    # Add the properties. Only add if Enabled and Collected (i.e. ignore test codes etc, we only
    # want the visibale stuff on the form).
    insertSparql = ""
    items = Hash.new
    itemOrdinal = 1
    bc.properties.each do |propertyId, property|
      ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Add item for Group=" + propertyId)
      if property[:Enabled] && property[:Collect]
        item = Form::FormItem.createBcNormal(id, ns, itemOrdinal, bc, propertyId, property[:Values])
        itemOrdinal += 1
        insertSparql = insertSparql + " :" + id + " bf:hasItem :" + item.id + " . \n"
      end
    end
      
    # Build the query
    update = UriManagement.buildNs(ns, ["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"" + bc.label + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      insertSparql + 
      " :" + id + " bf:isGroupOf :" + formId + " . \n" +
      " :" + id + " bf:hasBiomedicalConcept :" + refId + " . \n" +
      " :" + refId + " rdf:type bo:BcReference . \n" +
      " :" + refId + " bo:hasBiomedicalConcept " + ModelUtility.buildUri(bc.namespace, bc.id) + " . \n" +
      " :" + refId + " bo:enabled \"true\"^^xsd:boolean . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Failed")
    end

    return object
  
  end

  def self.createBcEdit (formId, ns, ordinal, params)
   
    id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    refId = ModelUtility.cidAddSuffix(id, "BCRef")
    
    # Add the properties. Only add if Enabled and Collected (i.e. ignore test codes etc, we only
    # want the visibale stuff on the form).
    insertSparql = ""
    items = Hash.new
    itemOrdinal = 1
    children = params[:children]
    children.each do |key, child|
      ConsoleLogger::log(C_CLASS_NAME,"createBcEdit","Add item for Group=" + child.to_s)
      #if child[:enabled] 
        item = Form::FormItem.createBcEdit(id, ns, itemOrdinal, child)
        itemOrdinal += 1
        insertSparql = insertSparql + " :" + id + " bf:hasItem :" + item.id + " . \n"
      #end
    end
      
    # Build the query
    update = UriManagement.buildNs(ns, ["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"" + params[:label] + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      insertSparql + 
      " :" + id + " bf:isGroupOf :" + formId + " . \n" +
      " :" + id + " bf:hasBiomedicalConcept :" + refId + " . \n" +
      " :" + refId + " rdf:type bo:BcReference . \n" +
      " :" + refId + " bo:enabled \"true\"^^xsd:boolean . \n" +
      " :" + refId + " bo:hasBiomedicalConcept " + ModelUtility.buildUri(params[:namespace], params[:id]) + " . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Failed")
    end

    return object
  
  end

  def self.createCommon (formId, ns, ordinal, params)
   
    id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    refId = ModelUtility.cidAddSuffix(id, "BCRef")
    
    # Add the properties. Only add if Enabled and Collected (i.e. ignore test codes etc, we only
    # want the visibale stuff on the form).
    insertSparql = ""
    items = Hash.new
    itemOrdinal = 1
    children = params[:children]
    children.each do |key, child|
      ConsoleLogger::log(C_CLASS_NAME,"createBcEdit","Add item for Group=" + child.to_s)
      #if child[:enabled] 
        item = Form::FormItem.createBcEdit(id, ns, itemOrdinal, child)
        itemOrdinal += 1
        insertSparql = insertSparql + " :" + id + " bf:hasItem :" + item.id + " . \n"
      #end
    end
      
    # Build the query
    update = UriManagement.buildNs(ns, ["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"" + params[:label] + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      insertSparql + 
      " :" + id + " bf:isGroupOf :" + formId + " . \n" +
      # " :" + id + " bf:hasBiomedicalConcept :" + refId + " . \n" +
      # " :" + refId + " rdf:type bo:BcReference . \n" +
      # " :" + refId + " bo:enabled \"true\"^^xsd:boolean . \n" +
      # " :" + refId + " bo:hasBiomedicalConcept " + ModelUtility.buildUri(params[:namespace], params[:id]) + " . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Failed")
    end

    return object
  
  end

  def self.createBlank (parentId, ns, ordinal, params)
   
    ConsoleLogger::log(C_CLASS_NAME,"createBcBlank","*****Blank*****")
    id = ModelUtility.cidSwapPrefix(parentId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    
    # Build the query
    update = UriManagement.buildNs(ns, ["bf", "bo"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + id + " rdf:type bf:Group . \n" +
      " :" + id + " bf:repeating \"false\"^^xsd:boolean . \n" +
      " :" + id + " bf:optional \"false\"^^xsd:boolean . \n" +
      " :" + id + " rdfs:label \"" + params[:label] + "\"^^xsd:string . \n" +
      " :" + id + " bf:note \"\"^^xsd:string . \n" +
      " :" + id + " bf:ordinal \"" + ordinal.to_s + "\"^^xsd:integer . \n" +
      " :" + id + " bf:isGroupOf :" + parentId + " . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      ConsoleLogger::log(C_CLASS_NAME,"createBcBlank","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createBcBlank","Failed")
    end

    return object
  
  end
  def update
    return nil
  end

  def destroy
  end
 
  def to_D3

    result = Hash.new
    result[:name] = self.label
    result[:identifier] = self.id
    result[:group] = self.to_json
    result[:nodeType] = "group"
    result[:children] = Array.new

    ii = 0
    self.items.each do |key, item|
      result[:children][ii] = Hash.new
      result[:children][ii] = item.to_D3
      ii += 1
    end
    result[:expansion] = Array.new
    result[:expansion] = result[:children]
    return result

  end

end
