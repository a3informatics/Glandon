require "uri"

class Form
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :managedItem, :groups, :namespace
  validates_presence_of :id, :managedItem, :groups, :namespace
  
  # Constants
  C_NS_PREFIX = "mdrForms"
  C_CLASS_NAME = "Form"
  C_CID_PREFIX = "F"
  
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

  def label
    return self.managedItem.label
  end

  def owner
    return self.managedItem.owner
  end

  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    #return @baseNs
  end
  
  def self.exists?(identifier)
    
    ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")
    result = ManagedItem.exists?(identifier,RegistrationAuthority.owner)
    ConsoleLogger::log(C_CLASS_NAME,"exists?","Result=" + result)
    return result

  end

  def self.find(id, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY******")
    
    object = nil
    useNs = ns || @@baseNs
    
    #query = UriManagement.buildNs(useNs, ["bo","bf"]) +
    #  "SELECT ?a WHERE\n" + 
    #  "{ \n" + 
    #  " :" + id + " rdf:type bf:Form . \n" +
    #  "} \n"
                  
    # Send the request, wait the resonse
    #response = CRUD.query(query)
    
    # Process the response
    #xmlDoc = Nokogiri::XML(response.body)
    #xmlDoc.remove_namespaces!
    #xmlDoc.xpath("//result").each do |node|
    #  nSet = node.xpath("binding[@name='a']/literal")
    #  if nSet.length == 1 
        object = self.new 
        object.id = id
        ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
        object.namespace = useNs
        object.managedItem = ManagedItem.find(id, useNs)
        object.groups = Form::FormGroup.findForForm(id, useNs)
    #  end
    #end
    return object  
    
  end

  def self.all()
    
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bf", "bo"]) 
    query = query +
      "SELECT ?a ?b WHERE\n" + 
      "{ \n" + 
      " ?a rdf:type bf:Form . \n" +
      "} \n"
      
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
        ConsoleLogger::log(C_CLASS_NAME,"find","Form Id=" + object.id)
        object.namespace = ModelUtility.extractNs(uriSet[0].text)
        object.managedItem = ManagedItem.find(object.id, object.namespace)
        results[object.id] = object
      end
    end
    return results  
    
  end

  def self.create_placeholder(params)
    
    ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Entry")
    
    # Create the object
    object = self.new 
    object.errors.clear

    # Check parameters
    if params_valid?(params, object)
      
      # Get the parameters
      identifier = params[:identifier]
      itemType = params[:itemType]
      freeText = params[:freeText]
      bcs = params[:bcs]
      versionLabel = "0.1"
      version = "1"
      
      if ManagedItem.exists?(identifier, RegistrationAuthority.owner) 
    
        # Note the error
        object.errors.add(:base, "The identifier is already in use.")
    
      else  
    
        # Create the required namespace.
        uri = Uri.new
        uri.setUri(@@baseNs)
        uri.extendPath("V" + version.to_s)
        useNs = uri.getNs()
        #ConsoleLogger::log(C_CLASS_NAME,"createLocal","useNs=" + useNs)
        
        # Create the id for the form
        id = ModelUtility.buildCid(C_CID_PREFIX, itemType)

        # Create the managed item for the form. 
        managedItem = ManagedItem.createLocal(id, 
          {:version => version, :identifier => identifier, :versionLabel => versionLabel, 
            :itemType => itemType, :namespaceId => RegistrationAuthority.owner.namespace.id, :label => ""}, 
          useNs)

        # Now create the group (which will create the item). We only need a 
        # single group for a placeholder form.
        group = FormGroup.create_placeholder(id, useNs, itemType, 1, version, freeText)
        
        # Create the query
        update = UriManagement.buildNs(useNs,["bf"]) +
          "INSERT DATA \n" +
          "{ \n" +
          "  :" + id + " rdf:type bf:Form . \n" +
          "  :" + id + " bf:hasGroup :" + group.id + " . \n" +
          "}"
        
        # Send the request, wait the resonse
        response = CRUD.update(update)
        
        # Response
        if response.success?
          object = self.new
          object.id = id
          object.managedItem = managedItem
          object.namespace = useNs
          object.groups = Hash.new
          object.groups[group.id] = group
          ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Object created, id=" + id)
        else
          object = self.new
          #object.assign_errors(data) if response.response_code == 422
          ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Object not created!")
        end
      end
    end
    
    return object

  end

  def self.create_bc_normal(params)
    
    ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Entry")
    
    # Create the object
    object = self.new 
    object.errors.clear

    # Check parameters
    if params_valid?(params, object)
      
      # Get the parameters
      identifier = params[:identifier]
      itemType = params[:itemType]
      bcs = params[:bcs]
      versionLabel = "0.1"
      version = "1"
      ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","BCs=" + bcs.to_s)
        
      if ManagedItem.exists?(identifier, RegistrationAuthority.owner) 
    
        # Note the error
        object.errors.add(:base, "The identifier is already in use.")
    
      else  

        # Create the required namespace.
        uri = Uri.new
        uri.setUri(@@baseNs)
        uri.extendPath("V" + version.to_s)
        useNs = uri.getNs()
        #ConsoleLogger::log(C_CLASS_NAME,"createLocal","useNs=" + useNs)
      
        # Create the id for the form
        id = ModelUtility.buildCid(C_CID_PREFIX, itemType)

        # Create the managed item for the form. 
        managedItem = ManagedItem.createLocal(id, 
          {:version => version, :identifier => identifier, :versionLabel => versionLabel, 
            :itemType => itemType, :namespaceId => RegistrationAuthority.owner.namespace.id, :label => ""}, 
          useNs)

        # Now create the group (which will create the item). We only need a 
        # single group for a placeholder form.
        insertSparql = ""
        groups = Hash.new
        ordinal = 1
        bcs.each do |key|
          ConsoleLogger::log(C_CLASS_NAME,"create_bc_normal","Add group for BC=" + key.to_s )
          parts = key.split("|")
          bcId = parts[0]
          bcNamespace = parts[1]
          bc = CdiscBc.find(bcId, bcNamespace)
          group = FormGroup.create_bc_normal(id, useNs, itemType, ordinal, version, bc)
          ordinal += 1
          insertSparql = insertSparql + "  :" + id + " bf:hasGroup :" + group.id + " . \n"
          groups[group.id] = group
        end

        # Create the query
        update = UriManagement.buildNs(useNs,["bf"]) +
          "INSERT DATA \n" +
          "{ \n" +
          "  :" + id + " rdf:type bf:Form . \n" +
          insertSparql +
          "}"
        
        # Send the request, wait the resonse
        response = CRUD.update(update)
        
        # Response
        if response.success?
          object = self.new
          object.id = id
          object.managedItem = managedItem
          object.groups = groups
        else
          object = nil
          object.assign_errors(data) if response.response_code == 422
        end
      end
    end

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

  def acrf
  
    query = UriManagement.buildNs(self.namespace, ["bf", "mms", "cbc", "bd", "cdisc", "isoI", "iso25964"])  +
      "SELECT ?form ?fName ?group ?gName ?item ?iName ?bcProperty ?bcRoot ?bcIdent ?alias ?qText ?datatype ?cCode ?subValue ?var ?varName ?col ?sdtmTopicName ?cli ?cl ?th WHERE\n" +
      "{ \n" + 
      "  :" + self.id + " bf:hasGroup ?group . \n " +
      "  ?form bf:hasGroup ?group . \n " +
      "  ?form rdfs:label ?fName . \n " +
      "  ?group bf:name ?gName . \n " +
      "  ?group bf:hasNode ?item . \n " +
      "  ?item bf:name ?iName . \n " +
      "  ?item bf:hasProperty ?bcProperty . \n " +
      "  ?item bf:hasBiomedicalConcept ?bcRoot . \n " +
      "  ?bcProperty cbc:alias ?alias . \n " +
      "  ?bcProperty cbc:qText ?qText . \n " +
      # "  ?s bd:hasProperty ?p . \n " +
      "  ?var bd:hasProperty ?bcProperty . \n " +
      "  ?var bd:basedOn ?col . \n " +
      "  ?col mms:dataElementName ?varName . \n " +
      "  ?col mms:context ?domain . \n " +
      "  ?col1 mms:context ?domain . \n " +
      "  ?col1 cdisc:dataElementRole <http://rdf.cdisc.org/std/sdtm-1-2#Classifier.TopicVariable> . \n " +
      "  ?col1 mms:dataElementName ?sdtmTopicName . \n " +
      "  ?bcRoot isoI:hasIdentifier ?si . \n " +
      "  ?si isoI:identifier ?bcIdent . \n " +
      "  OPTIONAL\n " +
      "  {\n " +
      "    ?bcProperty (cbc:hasSimpleDatatype | cbc:nextValue)+ ?bcValue . \n " +
      "    ?bcValue rdf:type cbc:PropertyValue . \n " +
      "    ?bcValue cbc:value ?cCode . \n " +
      "    ?cli iso25964:identifier ?cCode . \n " +
      "    ?cli iso25964:notation ?subValue . \n " +
      "    ?cl skos:narrower ?cli . \n " +
      "    ?cl skos:inScheme ?th . \n " +
      "    FILTER(STRSTARTS(STR(?th), \"http://www.assero.co.uk/MDRThesaurus/CDISC/V42\")) \n" +
      "  } \n" +
      "} \n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    directory = Rails.root.join("public","upload")
    path = File.join(directory, "formExport.xml")
    File.open(path, "wb") do |f|
       xmlDoc.write_xml_to f
    end

    # Transform the files and upload. Note the quotes around the strings parameters.
    Xslt.executeXML(path, "form/export/toODM.xsl", {}, "formODM.xml")
    path = File.join(directory, "formODM.xml")
    # Xslt.executeXML(path, "form/export/toHTML.xsl", {}, "formHTML.htm")
    html = Xslt.executeXML(path, "form/export/toHTML.xsl", {})
    return html

  end

  def to_D3

    result = Hash.new
    result[:name] = self.id
    result[:namespace] = self.namespace
    result[:identifier] = self.id
    result[:nodeType] = "form"
    result[:children] = Array.new

    ig = 0
    self.groups.each do |key, group|
      result[:children][ig] = Hash.new
      result[:children][ig] = group.to_D3
      ig += 1
    end
    result[:expansion] = Array.new
    result[:expansion] = result[:children]
    return result

  end

private

  def self.params_valid?(params, object)
    
    #result1 = ModelUtility::validIdentifier?(params[:identifier], object)
    #result2 = ModelUtility::validItemType?(params[:itemType], object)
    #result3 = validBcs?(params[:bcs], object)
    #return result1 && result2 && result3
    return true

  end

  def self.validBcs?(value, object)
    if value != nil
      return true
    else
      object.errors.add(:biomedical_concepts, ", select one or more concepts.")
      return false
    end
  end

end
