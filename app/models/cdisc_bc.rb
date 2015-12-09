require "uri"

class CdiscBc
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :managedItem, :properties, :namespace
  #validates_presence_of :id, :managedItem, :properties, :namespace
  
  # Constants
  C_CLASS_NAME = "CdiscBc"
  C_NS_PREFIX = "mdrBcs"
  C_CID_PREFIX = "BC"
  
  # BC object
  #
  # object: id, scopeId, identifier, version, namespace, name, properties where properties is
  # properties [:alias => {:id, :alias, :qText, :pText, :format, :values[{:id, :value}]}]
  
  # Base namespace 
  #@@cdiscOrg # CDISC Organization identifier
  
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

  def registrationState
    return self.managedItem.registrationState
  end

  def persisted?
    id.present?
  end

  def initialize()
    @errors = ActiveModel::Errors.new(self)
  end

  def baseNs
    return @baseNs
  end

  def self.count 
    result = ManagedItem.count("cbc", "BiomedicalConceptInstance")
    return result
  end 

  def self.find(id, ns=nil)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"find","id=" + id)
    ConsoleLogger::log(C_CLASS_NAME,"find","ns=" + ns)
    
    object = nil
    useNs = ns || @@baseNs
    
    query = UriManagement.buildNs(useNs, ["cbc", "mdrItems", "isoI"]) +
      "SELECT ?datatypeN ?datatypeRef ?propertyN ?simpleDatatypeN ?alias ?name ?pText ?qText ?enabled ?collect ?bridg ?valueN ?value WHERE\n" + 
      "{ \n" + 
      " :" + id + " rdf:type cbc:BiomedicalConceptInstance . \n" +
      " :" + id + " (cbc:hasItem | cbc:hasDatatype )%2B ?datatypeN .\n" + 
      " OPTIONAL {\n" + 
      "   ?datatypeN cbc:hasDatatypeRef ?datatypeRef . \n" + 
      "   ?datatypeN (cbc:hasProperty | cbc:hasComplexDatatype )%2B ?propertyN . \n" + 
      "   OPTIONAL { \n" + 
      "     ?propertyN cbc:alias ?alias . \n" + 
      "     ?propertyN cbc:name ?name . \n" + 
      "     ?propertyN cbc:hasValue ?simpleDatatypeN .\n" + 
      "     ?propertyN cbc:pText ?pText . \n" + 
      "     ?propertyN cbc:qText ?qText . \n" + 
      "     ?propertyN cbc:enabled ?enabled . \n" + 
      "     ?propertyN cbc:collect ?collect . \n" + 
      "     ?propertyN cbc:bridgPath ?bridg . \n" + 
      "   }\n" + 
      "   OPTIONAL { \n" + 
      "     ?propertyN (cbc:hasValue | cbc:nextValue)%2B ?valueN .\n" + 
      "     ?valueN rdf:type cbc:PropertyValue .\n" + 
      "     ?valueN cbc:value ?value .\n" + 
      "   }\n" + 
      " }\n" + 
      "}\n"

    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      dtnSet = node.xpath("binding[@name='datatypeN']/uri")
      dtRef = ModelUtility.getValue('datatypeRef', true, node)
      pnSet = node.xpath("binding[@name='propertyN']/uri")
      propertyNode = ModelUtility.getValue('propertyN', true, node)
      sdtNode = ModelUtility.getValue('simpleDatatypeN', true, node)
      aliasName = ModelUtility.getValue('alias', false, node)
      name = ModelUtility.getValue('name', false, node)
      pText = ModelUtility.getValue('pText', false, node)
      qText = ModelUtility.getValue('pText', false, node)
      enabled = ModelUtility.getValue('enabled', false, node)
      collect = ModelUtility.getValue('collect', false, node)
      vNode = ModelUtility.getValue('valueN', true, node)
      value = ModelUtility.getValue('value', false, node)
      bridg = ModelUtility.getValue('bridg', false, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","sdtNode=" + sdtNode)  
      if sdtNode != ""
        ConsoleLogger::log(C_CLASS_NAME,"find","Found")
        if object != nil
          properties = object.properties          
        else
          object = self.new 
          properties = Hash.new
          object.properties = properties
          object.id = id
          object.namespace = useNs
          object.managedItem = ManagedItem.find(id, useNs)
          ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id)
        end
        propertyCid = ModelUtility.extractCid(propertyNode)
        if properties.has_key?(propertyCid)
          property = properties[propertyCid]
          values = property[:Values]
        else
          property = Hash.new
          values = Array.new
        end  
        properties[propertyCid] = property
        if value != ""
          clHash = {
            :id => ModelUtility.extractCid(vNode), 
            :namespace => useNs,
            :cCode => value, 
            :clis => ThesaurusConcept.findByIdentifier(value, CdiscTerm.current.id, CdiscTerm.current.namespace)
          }
          values.push(clHash)
        end
        property[:id] = propertyCid
        property[:namespace] = useNs
        property[:Alias] = aliasName
        property[:Name] = name
        property[:Collect] = ModelUtility.toBoolean(collect)
        property[:Enabled] = ModelUtility.toBoolean(enabled)
        property[:QuestionText] = qText
        property[:PromptText] = pText
        property[:Datatype] = getDatatype(dtRef,values.length)
        property[:Values] = values
        property[:Format] = getFormat(property[:Datatype])
        property[:bridgPath] = bridg
      end
    end
    return object  
    
  end

  def self.all()
    
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["cbc", "mdrItems", "isoI"]) +
      "SELECT ?bcRoot WHERE\n" + 
      "{ \n" + 
      " ?bcRoot rdf:type cbc:BiomedicalConceptInstance . \n" +
      "}\n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='bcRoot']/uri")
      ConsoleLogger::log(C_CLASS_NAME,"find","URI=" + uriSet.text)
      if uriSet.length == 1 
        bcId = ModelUtility.extractCid(uriSet[0].text)
        object = self.new 
        object.id = bcId
        object.namespace = ModelUtility.extractNs(uriSet[0].text)
        object.managedItem = ManagedItem.find(bcId, object.namespace)
        object.properties = Hash.new
        ConsoleLogger::log(C_CLASS_NAME,"all","Object created, id=" + bcId)
        results[bcId] = object
      end
    end
    return results  
    
  end

  def self.create(params, ns=nil)
    
    ConsoleLogger::log(C_CLASS_NAME,"createLocal","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"createLocal","Params=" + params.to_s)
    
    # Initialise anything necessary
    bc = []
    object = self.new
    object.errors.clear
    
    # Check parameters for errors    
    if params_valid?(params, object)
    
      # Get the parameters
      version = "1"
      versionLabel = "0.1"
      identifier = params[:identifier]
      templateAndNs = params[:template]
      children = params[:children]
      label = params[:label]
      params[:version] = version
      params[:versionLabel] = versionLabel
      itemType = ModelUtility.createUid(identifier)

      # Extract the identifier nad namespace
      parts = templateAndNs.split('|')
      templateIdentifier = parts[0]
      templateNs = parts[1]
      #ConsoleLogger::log(C_CLASS_NAME,"createLocal","A=" + templateAndNs + ", B=" + templateIdentifier + ", C=" + templateNs)
    
      # Create the managed item for the thesaurus. The namespace id is a shortcut for the moment.
      if ManagedItem.exists?(identifier)

        # Item already exists
        object.errors.add(:biomedical_concept, "already exists. Need to create with a different identifier.")

      else

        # Create the managed item
        managedItem = ManagedItem.create(C_CID_PREFIX, params, @@baseNs)
        id = managedItem.id
        useNs = managedItem.namespace

        # Get the named template. Sort the white space.
        bcTemplate = BiomedicalConceptTemplate.find(templateIdentifier, templateNs)
        ttl = bcTemplate.to_ttl
        bcStr = ttl.gsub(/ +/," ")
        bcStr.gsub!(/\t/, " ")
        
        # Split into lines
        bc1 = bcStr.split("\n")

        # Make sure no query lines have been combined. Want subjects on their own.
        bc2 = []
        bc1.each do |line|
          parts = line.split(/\s+/)
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Line(1)=" + line)
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Parts(1)=" + parts.to_s)
          # Separate subject from predicate and object so lines are consistent
          if line.start_with?(":") && parts.length > 1
            bc2 << parts[0]
            parts[0] = ""
            bc2 << parts.join(" ")
          else
            bc2 << line
          end
        end
        ConsoleLogger::log(C_CLASS_NAME,"createLocal","BC Split=" + bc.to_s)
          
        # Build hash to map Property and PropertyValues reiples to alias values to allow the data
        # being saved to be keyed and matched
        preceedingSubject = ""
        aliasPropertyValueHash = Hash.new
        aliasPropertyHash = Hash.new
        aliasKey = ""
        inProperty = false
        simpleUri = ""
        bc2.each do |line|
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Line(2A)=" + line)
          line1 = line
          line2 = line
          parts = line2.split(/\s+/)
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Parts(2)=" + parts.to_s)
          #ConsoleLogger::log(C_CLASS_NAME,"createLocal","Candidate. Parts=" + parts.to_s)
          if line.start_with?(":")
            preceedingSubject = line
          elsif line.length == 0 && inProperty
            aliasPropertyHash[toKey(preceedingSubject.dup)] = aliasKey
            aliasPropertyValueHash[toKey(simpleUri.dup)] = aliasKey
            inProperty = false
          elsif parts.length == 4 && !inProperty
            if parts[2].start_with?("cbc:PropertyValue")
              # Do nothing, stops confusing Property with PropertyValue
            elsif parts[2].start_with?("cbc:Property")
              inProperty = true
            end
          elsif parts.length >= 4 && inProperty
            if parts[1].start_with?("cbc:hasValue")
              simpleUri = parts[2]
            elsif parts[1].start_with?("cbc:alias")
              aParts = line1.split('"')
              #ConsoleLogger::log(C_CLASS_NAME,"createLocal","Alias. Parts=" + aParts.to_s)
              if aParts.length == 3 
                aliasKey = aParts[1]
              end     
            end 
          end
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Line(2B)=" + line)
        end
        ConsoleLogger::log(C_CLASS_NAME,"createLocal","aliasPropertyValueHash=" + aliasPropertyValueHash.to_s)
        ConsoleLogger::log(C_CLASS_NAME,"createLocal","aliasPropertyHash=" + aliasPropertyHash.to_s)
        
        # Parse each line of the template. Remove any prefix statements
        #supprendSubjectEnd = false
        header = true
        bc3 = []
        bc2.each do |line|
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Line(3)=" + line)
          ignore = false
          text = ""
          if line.start_with?("@prefix") 
            ignore = true
          elsif line.length == 0
            if header
              # Ignore
            else
              text = endSubject() 
            end 
          elsif line.start_with?(":")
            # BC subject, update taking care of prefix and version.
            preceedingSubject = line
            header = false
            text = updateCid(line, itemType, version)
          else
            # Object and Predicate parts. 
            #
            # 1. Amend URIs in default namespace to add the version and prefixes preserving the existing Item Type.
            # 2. Remove any isoI:hasIdentifier triples
            # 3. Insert the values for any cbc:PropertyValue hooks
            header = false
            parts = line.split(/\s+/)
            ConsoleLogger::log(C_CLASS_NAME,"createLocal","Parts(4)=" + parts.to_s)
            if parts.length == 4 
              if parts[1].start_with?("isoI:hasIdentifier")
                # This will be replaced with a new Managed Instance
                ignore = true
              elsif parts[2].start_with?("cbc:PropertyValue")
                # Values hook
                aliasKey = aliasPropertyValueHash[preceedingSubject]
                child = findChild(children, aliasKey)
                if child != nil
                  ConsoleLogger::log(C_CLASS_NAME,"createLocal","Child=" + child.to_s)
                  if child.has_key?(:cli)
                    cliSet = child[:cli]
                    cliSet.each_with_index do |(key, cli), index|
                      ConsoleLogger::log(C_CLASS_NAME,"createLocal","Key=" + key + ", index=" + index.to_s + ", cli" + cli.to_s)
                      if index > 0
                        text = text + updateCidIndex(preceedingSubject, itemType, index, version) + "\n"
                      end
                      text = text + predicateObject('a','cbc:PropertyValue') + "\n"
                      text = text + predicateObject('cbc:value','"' + cli[:id] + '"^^xsd:string') 
                      if index < (cliSet.length - 1)
                        text = text + "\n"
                        text = text + predicateObject('cbc:nextValue',updateCidIndex(preceedingSubject, itemType, (index+1), version)) + "\n"
                        text = text + endSubject() + "\n"
                      end
                    end
                  else
                    text = predicateObject(parts[1],parts[2])
                  end
                else
                  text = predicateObject(parts[1],parts[2])
                end
                ConsoleLogger::log(C_CLASS_NAME,"createLocal","Text=" + text)
              elsif parts[2].start_with?("cbc:Property")
                # Values hook
                aliasKey = aliasPropertyHash[preceedingSubject]
                child = findChild(children, aliasKey)
                if child != nil
                  text = line + "\n"
                  text = text + predicateObject("cbc:pText",'"' + child[:pText] + '"^^xsd:string') + "\n"
                  text = text + predicateObject("cbc:qText",'"' + child[:qText] + '"^^xsd:string') + "\n"
                  text = text + predicateObject("cbc:enabled",'"' + child[:enable] + '"^^xsd:boolean') + "\n"
                  text = text + predicateObject("cbc:collect",'"' + child[:collect] + '"^^xsd:boolean')
                else
                  text = line
                end
              elsif parts[2].start_with?("cbc:BiomedicalConceptTemplate")
                # Make the template an instance. Overwrite the previous URI for the 
                # instance.
                bc3[-1] = subject(id)
                text = predicateObject("a","cbc:BiomedicalConceptInstance") + "\n"
                text = text + predicateObject("cbc:basedOn","mdrBcts:" + templateIdentifier) 
              elsif parts[2].start_with?(":")
                # Predicate object, update the object URI.
                parts[2] = updateCid(parts[2], itemType, version)
                text = predicateObject(parts[1],parts[2])
              else
                text = predicateObject(parts[1],parts[2])
              end
            elsif parts[1].start_with?("cbc:hasItem") || parts[1].start_with?("cbc:hasProperty")
              ConsoleLogger::log(C_CLASS_NAME,"createLocal","Has Item=" + parts.to_s)
              (2..(parts.length-1)).each do |i|
                #ConsoleLogger::log(C_CLASS_NAME,"createLocal","Item=" + parts[i].to_s)
                if parts[i] == "," 
                  text = text + predicateObject(parts[1],updateCid(parts[i-1], itemType, version)) + "\n"
                elsif parts[i] == ";" 
                  text = text + predicateObject(parts[1],updateCid(parts[i-1], itemType, version))
                end
                ConsoleLogger::log(C_CLASS_NAME,"createLocal","Text=" + text)
              end
            else
              text = line   
            end
          end
          if !ignore
            bc3 << text
          end
          preceedingLine = line
        end 
      
        # Create the query
        update = UriManagement.buildNs(useNs,["isoI", "cbc","mdrIso21090","mdrBridg","mdrBcts"]) +
          "INSERT DATA \n" +
          "{ \n"
        bc3.each do |triple|
          update = update + triple.to_s + "\n"
        end
        update = update + "}"
        
        # Send the request, wait the resonse
        #ConsoleLogger::log(C_CLASS_NAME,"createLocal","Update query=" + update)
        response = CRUD.update(update)
        
        # Response
        if response.success?
          object.id = managedItem.id
          object.namespace = useNs
          object.managedItem = managedItem
          object.properties = Hash.new
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Object created, id=" + id)
        else
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Object not created!")
          object.errors.add(:biomedical_concept, "was not created, something went wrong communicating with the database.")
        end
      end 
    end

    # Return
    return object

  end

private

  def self.subject(subjectUri)
      text = ':' + subjectUri 
      return text
  end

  def self.endSubject()
      text = "."
      return text
  end

  def self.predicateObject(predicate, object)
      text = " " + predicate + " " + object + " ;"
      return text
  end

  def self.toKey(text)
      text[0] = ''
      return text
  end

  def self.updateCid(line, uid, version)
      cid = line
      cid[0] = ''
      thisUid = ModelUtility.extractUid(cid)
      text = ':' + ModelUtility.buildCidIdentifier(C_CID_PREFIX, uid + '_' + thisUid)    
      return text
  end

  def self.updateCidIndex(line, uid, index, version)
      cid = line
      cid[0] = ''
      thisUid = ModelUtility.extractUid(cid)
      text = ':' + ModelUtility.buildCidIdentifier(C_CID_PREFIX, uid + '_' + thisUid + '_' + index.to_s)    
      return text
  end

  def self.findChild(children, aliasName)
      if aliasName != nil
        ConsoleLogger::log(C_CLASS_NAME,"findChild","Alias=" + aliasName)
        children.each do |key, child|
          ConsoleLogger::log(C_CLASS_NAME,"findChild","Alias=" + aliasName + ", Child[:name]=" + child.to_s + ", Key=" + key.to_s)
          if child[:name] == aliasName
            return child
          end
        end
      end
      return nil
  end

  def self.params_valid?(params, object)
    
    result1 = ModelUtility::validIdentifier?(params[:identifier], object)
    result2 = ModelUtility::validLabel?(params[:label], object)
    #result3 = validBcs?(params[:bcs], object)
    result3 = true
    return result1 && result2 && result3
    #return true

  end
  
  # Temporary datatype function
  def self.getDatatype (text, count)
    result = ""
    if count > 0 then
      result = "CL"
    else
      parts = text.split("-")
      if parts.size == 2
        if parts[1] == "CD"
          result = "CL"
        elsif parts[1] == "PQR"
          result = "F"
        elsif parts[1] == "BL"
          result = "BL"
        elsif parts[1] == "SC"
          result = "CL"
        elsif parts[1] == "IVL_TS_DATETIME"
          result = "D+T"
        else
          result = ""
        end
      else
        result = ""
      end
    end
    ConsoleLogger::log(C_CLASS_NAME,"getDatatype","Text=" + text + ", Result=" + result + ", Count=" + count.to_s)
    return result 
  end

  # Temporary format function
  def self.getFormat (dt)
    result = ""
    if dt == "CL"
      result = ""
    elsif dt == "F"
      result = "5.1"
    else
      result = ""
    end
    #ConsoleLogger::log(C_CLASS_NAME,"getFormat","Type=" + dt + ", Result=" + result)
    return result
  end
  
end
