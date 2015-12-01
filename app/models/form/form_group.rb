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
   
    id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, 1)
    item = Form::FormItem.create_placeholder(id, ns, 1, freeText)
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
      object.name = "Placeholder"
      object.optional = false
      object.repeating = false
      object.note = ""
      object.ordinal = ordinal
      object.items = Hash.new
      object.items[item.id] = item
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Failed")
    end

    return object
  
  end

  def self.create_bc_normal (formId, ns, ordinal, bc)
   
    id = ModelUtility.cidSwapPrefix(formId, C_CID_PREFIX)
    id = ModelUtility.cidAddSuffix(id, ordinal)
    insertSparql = ""
    items = Hash.new
    itemOrdinal = 1
    bc.properties.each do |property_id, property|
      ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Add item for Group=" + property_id)
      if property[:Enabled]
        item = Form::FormItem.create_bc_normal(id, ns, itemOrdinal, bc, property_id)
        itemOrdinal += 1
        items[item.id] = item
        insertSparql = insertSparql + " :" + id + " bf:hasItem :" + item.id + " . \n"
      end
    end
      

    update = UriManagement.buildNs(ns, ["bf"]) +
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
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      object.name = bc.label
      object.optional = false
      object.repeating = false
      object.note = ""
      object.ordinal = ordinal
      object.items = items
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Failed")
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
