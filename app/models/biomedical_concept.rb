require "uri"

class BiomedicalConcept < IsoManaged
  
  attr_accessor :items
  
  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConcept"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "BiomedicalConceptInstance"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
 
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      object.items = BiomedicalConcept::Item.findForParent(object, ns)
    end
    return object 
  end

  def flatten
    #ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = Hash.new
    items.each do |iKey, item|
      more = item.flatten
      more.each do |rKey, result|
        results[rKey] = result
      end
    end
    return results
  end

  def self.findOld(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY*****")
    object = super(id, ns)
    query = UriManagement.buildNs(ns, ["cbc", "mdrItems", "isoI"]) +
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
      #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      dtnSet = node.xpath("binding[@name='datatypeN']/uri")
      dtRef = ModelUtility.getValue('datatypeRef', true, node)
      pnSet = node.xpath("binding[@name='propertyN']/uri")
      propertyNode = ModelUtility.getValue('propertyN', true, node)
      sdtNode = ModelUtility.getValue('simpleDatatypeN', true, node)
      aliasName = ModelUtility.getValue('alias', false, node)
      name = ModelUtility.getValue('name', false, node)
      pText = ModelUtility.getValue('pText', false, node)
      qText = ModelUtility.getValue('qText', false, node)
      enabled = ModelUtility.getValue('enabled', false, node)
      collect = ModelUtility.getValue('collect', false, node)
      vNode = ModelUtility.getValue('valueN', true, node)
      value = ModelUtility.getValue('value', true, node)
      bridg = ModelUtility.getValue('bridg', false, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","sdtNode=" + sdtNode)  
      if sdtNode != ""
        ConsoleLogger::log(C_CLASS_NAME,"find","Found")
        if object.items != nil
          items = object.items          
        else
          items = Hash.new
          object.items = items
          ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id)
        end
        itemCid = ModelUtility.extractCid(propertyNode)
        if items.has_key?(itemCid)
          item = items[itemCid]
          values = item[:Values]
        else
          item = Hash.new
          values = Array.new
        end  
        items[itemCid] = item
        if value != ""
          cli = ThesaurusConcept.find(ModelUtility.extractCid(value),ModelUtility.extractNs(value))
          if cli != nil
            clHash = {
              :id => ModelUtility.extractCid(vNode), 
              :namespace => ns,
              :cCode => cli.notation, 
              :cli => cli
            }
            values.push(clHash)
          else
            ConsoleLogger::log(C_CLASS_NAME,"find","Failed to find CLI, uri=" + value)
          end
        end
        item[:id] = itemCid
        item[:namespace] = ns
        item[:Alias] = aliasName
        item[:Name] = name
        item[:Collect] = ModelUtility.toBoolean(collect)
        item[:Enabled] = ModelUtility.toBoolean(enabled)
        item[:QuestionText] = qText
        item[:PromptText] = pText
        item[:Datatype] = getDatatype(dtRef,values.length)
        item[:Values] = values
        item[:Format] = getFormat(item[:Datatype])
        item[:bridgPath] = bridg
      end
    end
    return object  
  end

  def self.findByReference(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"findByReference","*****ENTRY*****")
    query = UriManagement.buildNs(ns, ["bo", "cbc"]) +
      "SELECT ?bc WHERE\n" + 
      "{ \n" + 
      " :" + id + " bo:hasBiomedicalConcept ?bc . \n" +
      " ?bc rdf:type cbc:BiomedicalConceptInstance . \n" +
      "}\n"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    results = xmlDoc.xpath("//result")
    #ConsoleLogger::log(C_CLASS_NAME,"findByReference","Results=" + results.to_s)
    if results.length == 1 
      node = results[0]
      #ConsoleLogger::log(C_CLASS_NAME,"findByReference","Node=" + node.to_s)
      uri = ModelUtility.getValue('bc', true, node)
      bcId = ModelUtility.extractCid(uri)
      bcNs = ModelUtility.extractNs(uri)
      #ConsoleLogger::log(C_CLASS_NAME,"findByReference","BC id=" + bcId + ", ns=" + bcNs)
      object = self.find(bcId, bcNs)
    else
      object = nil
    end  
    return object
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    ConsoleLogger::log(C_CLASS_NAME,"unique","ns=" + C_SCHEMA_NS)
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.list
    ConsoleLogger::log(C_CLASS_NAME,"list","ns=" + C_SCHEMA_NS)
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(identifier)
    results = super(C_RDF_TYPE, identifier, C_SCHEMA_NS)
    return results
  end

  def self.create(params, ns=nil)
    
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"create","Params=" + params.to_s)
    
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
      #ConsoleLogger::log(C_CLASS_NAME,"create","A=" + templateAndNs + ", B=" + templateIdentifier + ", C=" + templateNs)
    
      # Create the managed item for the thesaurus. The namespace id is a shortcut for the moment.
      if exists?(identifier, IsoRegistrationAuthority.owner()) 

        # Item already exists
        object.errors.add(:biomedical_concept, "already exists. Need to create with a different identifier.")

      else

        # Create the managed item
        object = super(C_CID_PREFIX, params, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS)
        id = object.id
        useNs = object.namespace
        
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
          ConsoleLogger::log(C_CLASS_NAME,"create","Line(1)=" + line)
          ConsoleLogger::log(C_CLASS_NAME,"create","Parts(1)=" + parts.to_s)
          # Separate subject from predicate and object so lines are consistent
          if line.start_with?(":") && parts.length > 1
            bc2 << parts[0]
            parts[0] = ""
            bc2 << parts.join(" ")
          else
            bc2 << line
          end
        end
        ConsoleLogger::log(C_CLASS_NAME,"create","BC Split=" + bc.to_s)
          
        # Build hash to map Property and PropertyValues reiples to alias values to allow the data
        # being saved to be keyed and matched
        preceedingSubject = ""
        aliasPropertyValueHash = Hash.new
        aliasPropertyHash = Hash.new
        aliasKey = ""
        inProperty = false
        simpleUri = ""
        bc2.each do |line|
          ConsoleLogger::log(C_CLASS_NAME,"create","Line(2A)=" + line)
          line1 = line
          line2 = line
          parts = line2.split(/\s+/)
          ConsoleLogger::log(C_CLASS_NAME,"create","Parts(2)=" + parts.to_s)
          #ConsoleLogger::log(C_CLASS_NAME,"create","Candidate. Parts=" + parts.to_s)
          if line.start_with?(":")
            preceedingSubject = line
            ConsoleLogger::log(C_CLASS_NAME,"create","Setting preceedingSubject=" + preceedingSubject.to_s)
          elsif line.length == 0 && inProperty
            aliasPropertyHash[toKey(preceedingSubject.dup)] = aliasKey
            aliasPropertyValueHash[toKey(simpleUri.dup)] = aliasKey
            ConsoleLogger::log(C_CLASS_NAME,"create","Setting Alias. Subject=" + preceedingSubject.to_s + ", URI=" + simpleUri.to_s + ", Alias=" + aliasKey.to_s)
            inProperty = false
            preceedingSubject = ""
            simpleUri = ""
            aliasKey = ""
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
              ConsoleLogger::log(C_CLASS_NAME,"create","Alias. Parts=" + aParts.to_s)
              if aParts.length == 3 
                aliasKey = aParts[1]
              end     
            end 
          end
          ConsoleLogger::log(C_CLASS_NAME,"create","Line(2B)=" + line)
        end
        ConsoleLogger::log(C_CLASS_NAME,"create","aliasPropertyValueHash=" + aliasPropertyValueHash.to_s)
        ConsoleLogger::log(C_CLASS_NAME,"create","aliasPropertyHash=" + aliasPropertyHash.to_s)
        
        # Parse each line of the template. Remove any prefix statements
        #supprendSubjectEnd = false
        header = true
        bc3 = []
        bc2.each do |line|
          ConsoleLogger::log(C_CLASS_NAME,"create","Line(3)=" + line)
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
            ConsoleLogger::log(C_CLASS_NAME,"create","Parts(4)=" + parts.to_s)
            if parts.length == 4 
              if parts[1].start_with?("isoI:hasIdentifier")
                # This will be replaced with a new Managed Instance
                ignore = true
              elsif parts[2].start_with?("cbc:PropertyValue")
                # Values hook
                aliasKey = aliasPropertyValueHash[preceedingSubject]
                child = findChild(children, aliasKey)
                if child != nil
                  ConsoleLogger::log(C_CLASS_NAME,"create","Child=" + child.to_s)
                  if child.has_key?(:cli)
                    cliSet = child[:cli]
                    cliSet.each_with_index do |(key, cli), index|
                      ConsoleLogger::log(C_CLASS_NAME,"create","Key=" + key + ", index=" + index.to_s + ", cli" + cli.to_s)
                      if index > 0
                        text = text + updateCidIndex(preceedingSubject, itemType, index, version) + "\n"
                      end
                      text = text + predicateObject('a','cbc:PropertyValue') + "\n"
                      text = text + predicateObject('cbc:value',uri(cli[:namespace],cli[:id])) + "\n"
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
                ConsoleLogger::log(C_CLASS_NAME,"create","Text=" + text)
              elsif parts[2].start_with?("cbc:Property")
                # Values hook
                aliasKey = aliasPropertyHash[preceedingSubject]
                child = findChild(children, aliasKey)
                if child != nil
                  text = line + "\n"
                  text = text + predicateObject("cbc:name",'"' + child[:name] + '"^^xsd:string') + "\n"
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
                text = text + predicateObject("isoI:hasIdentifier","mdrItems:" + object.scopedIdentifier.id) + "\n"
                text = text + predicateObject("cbc:basedOn","mdrBcts:" + templateIdentifier) 
              elsif parts[2].start_with?(":")
                # Predicate object, update the object URI.
                parts[2] = updateCid(parts[2], itemType, version)
                text = predicateObject(parts[1],parts[2])
              else
                text = predicateObject(parts[1],parts[2])
              end
            elsif parts[1].start_with?("cbc:hasItem") || parts[1].start_with?("cbc:hasProperty")
              ConsoleLogger::log(C_CLASS_NAME,"create","Has Item=" + parts.to_s)
              (2..(parts.length-1)).each do |i|
                #ConsoleLogger::log(C_CLASS_NAME,"create","Item=" + parts[i].to_s)
                if parts[i] == "," 
                  text = text + predicateObject(parts[1],updateCid(parts[i-1], itemType, version)) + "\n"
                elsif parts[i] == ";" 
                  text = text + predicateObject(parts[1],updateCid(parts[i-1], itemType, version))
                end
                ConsoleLogger::log(C_CLASS_NAME,"create","Text=" + text)
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
        update = UriManagement.buildNs(useNs,["isoI", "cbc","mdrIso21090","mdrBridg","mdrBcts","mdrItems"]) +
          "INSERT DATA \n" +
          "{ \n"
        bc3.each do |triple|
          update = update + triple.to_s + "\n"
        end
        update = update + "}"
        
        # Send the request, wait the resonse
        #ConsoleLogger::log(C_CLASS_NAME,"create","Update query=" + update)
        response = CRUD.update(update)
        
        # Response
        if response.success?
          object.items = Hash.new
          ConsoleLogger::log(C_CLASS_NAME,"create","Object created, id=" + id)
        else
          ConsoleLogger::log(C_CLASS_NAME,"create","Object not created!")
          object.errors.add(:biomedical_concept, "was not created, something went wrong communicating with the database.")
        end
      end 
    end

    # Return
    return object

  end

  def self.impact(params)
  
    id = params[:id]
    namespace = params[:namespace]
    results = Hash.new

    # Build the query. Note the full namespace reference, doesnt seem to work with a default namespace. Needs checking.
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["cbc"])  +
      "SELECT DISTINCT ?bc WHERE \n" +
      "{ \n " +
      "  ?bc rdf:type cbc:BiomedicalConceptInstance . \n " +
      "  ?bc (cbc:hasItem|cbc:hasDatatype|cbc:hasProperty|cbc:hasComplexDatatype|cbc:hasValue|cbc:nextValue)%2B ?o . \n " +
      "  ?o cbc:value " + ModelUtility.buildUri(namespace, id) + " . \n " +"
      "  "}\n"

    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      bc = ModelUtility.getValue('bc', true, node)
      if bc != ""
        id = ModelUtility.extractCid(bc)
        namespace = ModelUtility.extractNs(bc)
        results[id] = find(id, namespace)
        ConsoleLogger::log(C_CLASS_NAME,"impact","Object found, id=" + id)        
      end
    end

    return results
  end

private

  def self.process(object, query)
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      dtnSet = node.xpath("binding[@name='datatypeN']/uri")
      dtRef = ModelUtility.getValue('datatypeRef', true, node)
      pnSet = node.xpath("binding[@name='propertyN']/uri")
      propertyNode = ModelUtility.getValue('propertyN', true, node)
      sdtNode = ModelUtility.getValue('simpleDatatypeN', true, node)
      aliasName = ModelUtility.getValue('alias', false, node)
      name = ModelUtility.getValue('name', false, node)
      pText = ModelUtility.getValue('pText', false, node)
      qText = ModelUtility.getValue('qText', false, node)
      enabled = ModelUtility.getValue('enabled', false, node)
      collect = ModelUtility.getValue('collect', false, node)
      vNode = ModelUtility.getValue('valueN', true, node)
      value = ModelUtility.getValue('value', true, node)
      bridg = ModelUtility.getValue('bridg', false, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","sdtNode=" + sdtNode)  
      if sdtNode != ""
        ConsoleLogger::log(C_CLASS_NAME,"find","Found")
        if object.items != nil
          items = object.items          
        else
          items = Hash.new
          object.items = items
          ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id)
        end
        itemCid = ModelUtility.extractCid(propertyNode)
        if items.has_key?(itemCid)
          item = items[itemCid]
          values = item[:Values]
        else
          item = Hash.new
          values = Array.new
        end  
        items[itemCid] = item
        if value != ""
          cli = ThesaurusConcept.find(ModelUtility.extractCid(value),ModelUtility.extractNs(value))
          if cli != nil
            clHash = {
              :id => ModelUtility.extractCid(vNode), 
              :namespace => ns,
              :cCode => cli.notation, 
              :cli => cli
            }
            values.push(clHash)
          else
            ConsoleLogger::log(C_CLASS_NAME,"find","Failed to find CLI, uri=" + value)
          end
        end
        item[:id] = itemCid
        item[:namespace] = ns
        item[:Alias] = aliasName
        item[:Name] = name
        item[:Collect] = ModelUtility.toBoolean(collect)
        item[:Enabled] = ModelUtility.toBoolean(enabled)
        item[:QuestionText] = qText
        item[:PromptText] = pText
        item[:Datatype] = getDatatype(dtRef,values.length)
        item[:Values] = values
        item[:Format] = getFormat(item[:Datatype])
        item[:bridgPath] = bridg
      end
    end
    return object  
  end

  def self.subject(subjectUri)
      text = ':' + subjectUri 
      return text
  end

  def self.uri(ns, uri)
      text = '<' + ns + '#' + uri + '>'
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
