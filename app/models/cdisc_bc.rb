require "uri"

class CdiscBc
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :managedItem, :properties, :namespace, :errors
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

  def persisted?
    id.present?
  end

  def initialize()
    @errors = ActiveModel::Errors.new(self)
  end

  def baseNs
    return @baseNs
  end
  
  def self.find(id, cdiscTerm)
    
    object = nil
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["cbc", "mdrItems", "isoI"]) +
      "SELECT ?bcName ?bcDtNode ?bcPropertyNode ?bcPropertyValueNode ?datatype ?propertyValue ?propertyAlias ?pt ?qt ?enabled ?collect WHERE\n" + 
      "{ \n" + 
      " :" + id + " rdf:type cbc:BiomedicalConceptInstance . \n" +
      " :" + id + " (cbc:hasItem | cbc:hasDatatype )%2B ?bcDtNode .\n" + 
      " OPTIONAL {\n" + 
      "   ?bcDtNode cbc:hasDatatypeRef ?datatype . \n" + 
      "   ?bcDtNode (cbc:hasProperty | cbc:hasComplexDatatype )%2B ?bcPropertyNode . \n" + 
      "   OPTIONAL { \n" + 
      "     ?bcPropertyNode (cbc:hasSimpleDatatype | cbc:nextValue)%2B ?bcPropertyValueNode .\n" + 
      "     ?bcPropertyValueNode rdf:type cbc:PropertyValue .\n" + 
      "     ?bcPropertyValueNode cbc:value ?propertyValue .\n" + 
      "     ?bcPropertyNode cbc:alias ?propertyAlias . \n" + 
      "     OPTIONAL { \n" + 
      "       ?bcPropertyNode cbc:pText ?pt . \n" + 
      "       ?bcPropertyNode cbc:qText ?qt . \n" + 
      "       ?bcPropertyNode cbc:enabled ?enabled . \n" + 
      "       ?bcPropertyNode cbc:collect ?collect . \n" + 
      "     }\n" + 
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
      bcSet = node.xpath("binding[@name='bcPropertyNode']/uri")
      valueSet = node.xpath("binding[@name='propertyValue']/literal")
      aliasSet = node.xpath("binding[@name='propertyAlias']/literal")
      dtSet = node.xpath("binding[@name='datatype']/uri")
      pText = ModelUtility.getValue('pt', false, node)
      qText = ModelUtility.getValue('pt', false, node)
      enabled = ModelUtility.getValue('enabled', false, node)
      collect = ModelUtility.getValue('collect', false, node)
      if bcSet.length == 1 && valueSet.length == 1 && aliasSet.length == 1 && dtSet.length == 1
        ConsoleLogger::log(C_CLASS_NAME,"find","Found")
        if object != nil
          properties = object.properties          
        else
          object = self.new 
          properties = Hash.new
          object.properties = properties
          object.id = id
          object.managedItem = ManagedItem.find(id, UriManagement.getNs(C_NS_PREFIX))
          ConsoleLogger::log(C_CLASS_NAME,"all","Object created, id=" + id)
        end
        propertyCid = ModelUtility.extractCid(bcSet[0].text)
        aliasName = aliasSet[0].text
        qText = qText
        pText = pText
        enabled = enabled
        collect = collect
        value = valueSet[0].text
        dt = dtSet[0].text
        if properties.has_key?(propertyCid)
          property = properties[propertyCid]
          values = property[:Values]
        else
          property = Hash.new
          values = Array.new
        end  
        properties[propertyCid] = property
        if value != ""
          clHash = {:cCode => value, :clis => CdiscCli.allForCl(value, cdiscTerm)}
          values.push(clHash)
        end
        property[:Alias] = aliasName
        property[:Collect] = collect
        property[:Enabled] = enabled
        property[:QuestionText] = qText
        property[:PromptText] = pText
        property[:Datatype] = getDatatype(dt,values.length)
        property[:Values] = values
        property[:Format] = getFormat(property[:Datatype])
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
        object.managedItem = ManagedItem.find(bcId, ModelUtility.extractNs(uriSet[0].text))
        object.properties = Hash.new
        ConsoleLogger::log(C_CLASS_NAME,"all","Object created, id=" + bcId)
        results[bcId] = object
      end
    end
    return results  
    
  end

  def self.createLocal(params, ns=nil)
    
    ConsoleLogger::log(C_CLASS_NAME,"createLocal","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"createLocal","Params=" + params.to_s)
    
    # Initialise anything necessary
    bc = []
    object = self.new
    
    # Check parameters for errors    
    object.errors.clear
    if validate!(params, object.errors)
    
      # Get the parameters
      itemType = params[:itemType]
      version = "1"
      versionLabel = "0.1"
      identifier = params[:identifier]
      templateAndNs = params[:template]
      children = params[:children]
      
      # Extract the identifier nad namespace
      parts = templateAndNs.split('|')
      templateIdentifier = parts[0]
      templateNs = parts[1]
      ConsoleLogger::log(C_CLASS_NAME,"createLocal","A=" + templateAndNs + ", B=" + templateIdentifier + ", C=" + templateNs)
    
      # Create the required namespace.
      uri = Uri.new
      uri.setUri(@@baseNs)
      uri.extendPath("V" + version.to_s)
      useNs = uri.getNs()
      ConsoleLogger::log(C_CLASS_NAME,"createLocal","useNs=" + useNs)
    
      # Create the id for the biomedical concept
      id = ModelUtility.buildCidVersion(C_CID_PREFIX, itemType, version)

      # Create the managed item for the thesaurus. The namespace id is a shortcut for the moment.
      if ManagedItem.exists?(id, useNs)

        # Item already exists
        object.errors.add(:biomedical_concept, "already exists. Need to create with a different identifier.")

      else

        # Get the named template
        bcTemplate = BiomedicalConceptTemplate.to_ttl
      
        # Do some truely evil processing to amend the template triples
        # This is a global up front change. Other changes may be made later.
        #
        # 1. Change RCTItem to RCItem
        #
        bcStr = bcTemplate.gsub('cbc:RCTItem', 'cbc:RCItem')

        # Build hash to map propertyValues to alias values
        preceedingSubject = ""
        aliasPropertyValueHash = Hash.new
        aliasPropertyHash = Hash.new
        aliasKey = ""
        inProperty = false
        simpleUri = ""
        bcStr.split("\n").each do |line|
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","line=" + line)
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","inProperty=" + inProperty.to_s)
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","preceedingSubject=" + preceedingSubject)
          line1 = line
          line2 = line
          parts = line2.split(/\s+/)
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Candidate. Parts=" + parts.to_s)
          if line.start_with?(":")
            preceedingSubject = line
          elsif line.length == 0 && inProperty
            aliasPropertyHash[removeFirstChar(preceedingSubject)] = aliasKey
            aliasPropertyValueHash[removeFirstChar(simpleUri)] = aliasKey
            inProperty = false
          elsif parts.length == 4 && !inProperty
            if parts[2].start_with?("cbc:PropertyValue")
              # Do nothing, stops confusing Property with PropertyValue
            elsif parts[2].start_with?("cbc:Property")
              inProperty = true
            end
          elsif parts.length >= 4 && inProperty
            if parts[1].start_with?("cbc:hasSimpleDatatype")
              simpleUri = parts[2]
            elsif parts[1].start_with?("cbc:alias")
              aParts = line1.split('"')
              ConsoleLogger::log(C_CLASS_NAME,"createLocal","Alias. Parts=" + aParts.to_s)
              if aParts.length == 3 
                aliasKey = aParts[1]
              end     
            end 
          end
        end
        ConsoleLogger::log(C_CLASS_NAME,"createLocal","aliasPropertyValueHash=" + aliasPropertyValueHash.to_s)
        ConsoleLogger::log(C_CLASS_NAME,"createLocal","aliasPropertyHash=" + aliasPropertyHash.to_s)
          
        # Parse each line of the template. Remove any prefix statements
        #supprendSubjectEnd = false
        header = true
        bcStr.split("\n").each do |line|
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
            # 3. Insert the values for nay cbc:PropertyValue hooks
            header = false
            parts = line.split(/\s+/).map(&:strip)
            ConsoleLogger::log(C_CLASS_NAME,"createLocal","Parts=" + parts.to_s)
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
                        text = text + updateCidIndex(oldUri, itemType, index, version) + "\n"
                      end
                      text = text + predicateObject('a','cbc:PropertyValue') + "\n"
                      text = text + predicateObject('cbc:value','"' + cli[:id] + '"^^xsd:string') 
                      if index < (cliSet.length - 1)
                        text = text + "\n"
                        text = text + predicateObject('cbc:nextValue',updateCidIndex(oldUri, itemType, (index+1), version)) + "\n"
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
                bc[-1] = subject(id)
                text = predicateObject("a","cbc:BiomedicalConceptInstance") + "\n"
                text = text + predicateObject("cbc:basedOn","mdrBcts:" + templateIdentifier) 
              elsif parts[2].start_with?(":")
                # Predicate object, update the object URI.
                parts[2] = updateCid(parts[2], itemType, version)
                text = predicateObject(parts[1],parts[2])
              else
                text = predicateObject(parts[1],parts[2])
              end
            elsif parts[1].start_with?("cbc:hasItem")
              ConsoleLogger::log(C_CLASS_NAME,"createLocal","Has Item=" + parts.to_s)
              (2..(parts.length-1)).each do |i|
                ConsoleLogger::log(C_CLASS_NAME,"createLocal","Item=" + parts[i].to_s)
                if parts[i] == "," 
                  text = text + predicateObject("cbc:hasItem",updateCid(parts[i-1], itemType, version)) + "\n"
                elsif parts[i] == ";" 
                  text = text + predicateObject("cbc:hasItem",updateCid(parts[i-1], itemType, version))
                end
                ConsoleLogger::log(C_CLASS_NAME,"createLocal","Text=" + text)
              end
            else
              text = line   
            end
          end
          if !ignore
            bc << text
          end
          preceedingLine = line
        end 
      
        # Create the managed item
        managedItem = ManagedItem.createLocal(id, {:version => version, :identifier => identifier, :versionLabel => versionLabel, :itemType => itemType, :namespaceId => "NS-ACME"}, useNs)

        # Create the query
        update = UriManagement.buildNs(useNs,["isoI", "cbc","mdrIso21090","mdrBridg","mdrBcts"]) +
          "INSERT DATA \n" +
          "{ \n"
        bc.each do |triple|
          update = update + triple.to_s + "\n"
        end
        update = update + "}"
        
        # Send the request, wait the resonse
        ConsoleLogger::log(C_CLASS_NAME,"createLocal","Update query=" + update)
        response = CRUD.update(update)
        
        # Response
        if response.success?
          object.id = id
          object.namespace = useNs
          object.managedItem = managedItem
          object.properties = Hash.new
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Object created, id=" + id)
        else
          ConsoleLogger::log(C_CLASS_NAME,"createLocal","Object not created!")
          object.errors.add(:biomedical_concept, "was not created, something went wrong communicating with the database")
        end
      end 
    end

    # Return
    return object

  end

  def update
    return nil
  end

  def destroy
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
      text = "\t\t" + predicate + "\t" + object + " ;"
      return text
  end

  def self.removeFirstChar(text)
      text[0] = ''
      return text
  end

  def self.updateCid(line, itemType, version)
      cid = line
      cid[0] = ''
      thisItemType = ModelUtility.extractItemType(cid)
      text = ':' + ModelUtility.buildCidVersion(C_CID_PREFIX, itemType + '_' + thisItemType, version)    
      return text
  end

  def self.updateCidIndex(line, itemType, index, version)
      cid = line
      cid[0] = ''
      thisItemType = ModelUtility.extractItemType(cid)
      text = ':' + ModelUtility.buildCidVersion(C_CID_PREFIX, itemType + '_' + thisItemType + '_' + index.to_s, version)    
      return text
  end

  def self.findChild(children, aliasName)
      children.each do |key, child|
        ConsoleLogger::log(C_CLASS_NAME,"createLocal","Child=" + child[:name] )
        ConsoleLogger::log(C_CLASS_NAME,"createLocal","AliasName=" + aliasName.to_s)
        if child[:name] == aliasName
          return child
        end
      end
      return nil
  end

  def self.validate!(params, errors)
    itemType = params[:itemType]
    identifier = params[:identifier]
    template = params[:template]
    ConsoleLogger::log(C_CLASS_NAME,"validate!","itemType=" + itemType + ", identifier=" + identifier + ", template=" + template)
    errors.add(:identifier, "cannot be empty. Enter the identifier.") if identifier.blank?
    errors.add(:itemType, "cannot be empty. Enter the Item Type.") if itemType.blank?
    errors.add(:template, "cannot be empty. Select a template.") if template.blank?
    if errors.count > 0 
      ConsoleLogger::log(C_CLASS_NAME,"validate!","False")
      return false
    else
      ConsoleLogger::log(C_CLASS_NAME,"validate!","True")
      return true
    end
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
