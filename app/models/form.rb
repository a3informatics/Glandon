class Form < IsoManaged
  
  attr_accessor :groups
  validates_presence_of :groups
  
  # Constants
  C_SCHEMA_PREFIX = "bf"
  C_INSTANCE_PREFIX = "mdrForms"
  C_CLASS_NAME = "Form"
  C_CID_PREFIX = "F"
  C_RDF_TYPE = "Form"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def self.find(id, ns, children=true)
    ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY******")
    object = super(id, ns)
    if children
      object.groups = Form::Group.findForForm(object.links, ns)
    end
    return object     
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    #ConsoleLogger::log(C_CLASS_NAME,"unique","ns=" + C_SCHEMA_NS)
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(identifier)
    results = super(C_RDF_TYPE, identifier, C_SCHEMA_NS)
    return results
  end

  def self.createPlaceholder(params)
    ConsoleLogger::log(C_CLASS_NAME,"createPlaceholder","*****Entry*****")
    
    # Create the object
    object = self.new 
    object.errors.clear

    # Check parameters
    if params_valid?(params, object)
      
      # Get the parameters
      identifier = params[:identifier]
      freeText = params[:freeText]
      label = params[:label]
      params[:versionLabel] = "0.1"
      params[:version] = "1"
      ConsoleLogger::log(C_CLASS_NAME,"createPlaceholder","FreeText=" + freeText.to_s)
      if exists?(identifier, IsoRegistrationAuthority.owner()) 
    
        # Note the error
        object.errors.add(:base, "The identifier is already in use.")
    
      else  
    
        # Create the adminstered item for the form. 
        object = create(C_CID_PREFIX, params, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS)
      
        # Now create the group (which will create the item). We only need a 
        # single group for a placeholder form.
        group = Group.createPlaceholder(object.id, object.namespace, freeText)
      
        # Create the update query
        update = UriManagement.buildNs(object.namespace,["bf"]) +
          "INSERT DATA \n" +
          "{ \n" +
          "  :" + object.id + " bf:hasGroup :" + group.id + " . \n" +
          "}"
        
        # Send the request, wait the resonse
        response = CRUD.update(update)
        
        # Response
        if response.success?
          ConsoleLogger::log(C_CLASS_NAME,"createPlaceholder","Object created, id=" + object.id)
        else
          object.errors.add(:base, "The group was not created in the database.")
          ConsoleLogger::log(C_CLASS_NAME,"createPlaceholder","Object not created!")
        end

      end
    end
    
    return object

  end

  def self.createBcNormal(params)
    
    ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","*****Entry*****")
    
    # Create the object
    object = self.new 
    object.errors.clear

    # Check parameters
    if params_valid?(params, object)
      
      # add the version info to the parameters
      identifier = params[:identifier]
      label = params[:label]
      bcs = params[:bcs]
      params[:versionLabel] = "0.1"
      params[:version] = "1"
      ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","BCs=" + bcs.to_s)
        
      if exists?(identifier, IsoRegistrationAuthority.owner) 
    
        # Note the error
        object.errors.add(:base, "The identifier is already in use.")
    
      else  

        # Create the adminstered item for the form. 
        object = create(C_CID_PREFIX, params, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS)
      
        # Now create the groups (which will create the item). We create a 
        # single group for each BC.
        insertSparql = ""
        groups = Hash.new
        ordinal = 1
        bcs.each do |key|
          ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Add group for BC=" + key.to_s )
          parts = key.split("|")
          bcId = parts[0]
          bcNamespace = parts[1]
          bc = BiomedicalConcept.find(bcId, bcNamespace)
          group = Group.createBcNormal(object.id, object.namespace, ordinal, bc)
          ordinal += 1
          insertSparql = insertSparql + "  :" + object.id + " bf:hasGroup :" + group.id + " . \n"
        end

        # Create the update query
        update = UriManagement.buildNs(object.namespace,["bf"]) +
          "INSERT DATA \n" +
          "{ \n" +
          insertSparql +
          "}"
        
        # Send the request, wait the resonse
        response = CRUD.update(update)
        
        # Response
        if response.success?
          ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Object created, id=" + object.id)
        else
          object.errors.add(:base, "The namespace was not created in the database.")
          ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Object not created!")
        end
      end
    end

    return object

  end
  
  def self.createFull(params)
    
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    
    # Create the object
    object = self.new 
    object.errors.clear

    # Check parameters
    if params_valid?(params, object)
      
      # add the version info to the parameters
      identifier = params[:identifier]
      label = params[:label]
      params[:versionLabel] = "0.1"
      params[:version] = "1"
      children = params[:children]
      ConsoleLogger::log(C_CLASS_NAME,"create","Children=" + children.to_s)
       
      # Check the form does not exist 
      #ex = true
      #if !ex
      if exists?(identifier, IsoRegistrationAuthority.owner) 
    
        # Note the error
        object.errors.add(:base, "The identifier is already in use.")
    
      else  

        # Create the adminstered item for the form. 
        object = create(C_CID_PREFIX, params, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS)
      
        # Now create the groups (which will create the item). We create a 
        # single group for each BC.
        insertSparql = ""
        groups = Hash.new
        ordinal = 1
        children.each do |key, child|
          ConsoleLogger::log(C_CLASS_NAME,"create","Child=" + child.to_s )
          group = addGroup(object.id, object.namespace, ordinal, child)
          ordinal += 1
          insertSparql = insertSparql + "  :" + object.id + " bf:hasGroup :" + group.id + " . \n"
        end

        # Create the update query
        update = UriManagement.buildNs(object.namespace,["bf"]) +
          "INSERT DATA \n" +
          "{ \n" +
          insertSparql +
          "}"
        
        # Send the request, wait the resonse
        response = CRUD.update(update)
        
        # Response
        if response.success?
          ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Object created, id=" + object.id)
        else
          object.errors.add(:base, "The namespace was not created in the database.")
          ConsoleLogger::log(C_CLASS_NAME,"createBcNormal","Object not created!")
        end
      end
    end

    return object

  end

  def acrf
  
    query = UriManagement.buildNs(self.namespace, ["bf", "bo", "mms", "cbc", "bd", "cdisc", "isoI", "iso25964"])  +
      "SELECT ?form ?fName ?group ?gName ?item ?iName ?bcProperty ?bcRoot ?bcIdent ?alias ?qText ?datatype ?cCode ?subValue ?sdtmVarName ?domain ?sdtmTopicName ?sdtmTopicValue ?sdtmTopicSub WHERE \n" +
      "{ \n " +
      "{ \n " +
      "  ?node1 bd:basedOn ?node2 . \n " +
      "  ?node1 rdf:type bd:Variable . \n " +
      "  ?node2 mms:dataElementName ?sdtmTopicName . \n " +
      "  ?node1 bd:hasProperty ?node4 . \n " +
      "  ?node4 (cbc:isPropertyOf | cbc:isDatatypeOf | cbc:isItemOf)%2B ?bcRoot . \n" +
      "  ?node4 cbc:hasValue ?valueRef . \n " +
      # "  ?valueRef cbc:value ?sdtmTopicValue . \n " +
      "  ?valueRef cbc:value ?sdtmTopicValueObj . \n " +
      "  ?sdtmTopicValueObj iso25964:identifier ?sdtmTopicValue . \n " +
      "  ?sdtmTopicValueObj iso25964:notation ?sdtmTopicSub . \n " +
      # "  ?node3 rdf:type iso25964:ThesaurusConcept . \n " +
      # "  ?node3 iso25964:identifier ?sdtmTopicValue . \n " +
      # "  ?node3 iso25964:notation ?x . \n " +
      # "  ?node3 iso25964:notation ?sdtmTopicSub . \n " +
      # "  FILTER(STRSTARTS(STR(?node3), \"http://www.assero.co.uk/MDRThesaurus/CDISC/V42\")) .  \n " +
      # "  FILTER(STR(?sdtmTopicSub) = UCASE(?x)) .  \n " +
      "  {\n " +
      "    SELECT ?form ?fName ?group ?gName ?item ?iName ?bcProperty ?bcRoot ?bcIdent ?alias ?qText ?datatype ?cCode ?subValue ?sdtmVarName ?domain ?sdtmTopicName WHERE \n " +
      "    { \n " + 
      "      ?var bd:basedOn ?col . \n " +     
      "      ?col mms:dataElementName ?sdtmVarName . \n " +     
      "      ?col mms:context ?dataset . \n " +     
      "      ?dataset mms:contextLabel ?domain . \n " +     
      "      ?node5 mms:context ?dataset . \n " +     
      "      ?node5 cdisc:dataElementRole <http://rdf.cdisc.org/std/sdtm-1-2#Classifier.TopicVariable> . \n " +     
      "      ?node5 mms:dataElementName ?sdtmTopicName . \n " +     
      "      { \n " +
      "        SELECT ?form ?fName ?group ?gName ?item ?iName ?bcProperty ?bcRoot ?bcIdent ?alias ?qText ?datatype ?cCode ?subValue ?sdtmVarName ?dataset ?domain ?var WHERE \n " + 
      "        { \n " +    
      "          :" + self.id + " bf:hasGroup ?groupM . \n " +     
      "          ?form bf:hasGroup ?groupM . \n " +     
      "          ?form rdfs:label ?fName . \n " +
      "          ?groupM bf:hasSubGroup ?group . \n " +
      "          ?group rdfs:label ?gName . \n " +
      "          ?group bf:hasItem ?item . \n " +
      "          ?item rdfs:label ?iName . \n " +
      "          ?item bf:hasProperty ?x . \n " +             
      "          ?x bo:hasProperty ?bcProperty  . \n " +      
      "          ?var bd:hasProperty ?bcProperty . \n " +     
      "          ?bcProperty (cbc:isPropertyOf | cbc:isDatatypeOf | cbc:isItemOf)%2B ?bcRoot . \n" +
      "          ?bcRoot rdf:type cbc:BiomedicalConceptInstance . \n " +
      "          ?bcProperty cbc:alias ?alias . \n " +     
      "          ?bcProperty cbc:qText ?qText . \n " +     
      "          ?bcProperty cbc:simpleDatatype ?datatype . \n " +     
      "          ?bcRoot isoI:hasIdentifier ?si . \n " +     
      "          ?si isoI:identifier ?bcIdent . \n " +     
      "          OPTIONAL \n " +    
      "          { \n " +      
      # "            ?bcProperty (cbc:hasValue | cbc:nextValue)%2B  ?bcValue . \n " +       
      # "            ?bcValue rdf:type cbc:PropertyValue . \n " +       
      "            ?item bf:hasValue ?y . \n " +             
      "            ?y bo:hasValue ?bcValue  . \n " +      
      "            ?y bo:enabled ?enabled  . \n " +      
      # "            ?bcValue cbc:value ?cCode . \n " +       
      "            ?bcValue cbc:value ?cli . \n " +       
      "            ?cli iso25964:identifier ?cCode . \n " +       
      "            ?cli iso25964:notation ?subValue . \n " +       
      # "            ?cl skos:narrower ?cli . \n " +       
      # "            ?cl skos:inScheme ?th . \n " +       
      "            FILTER(?enabled=true) . \n " +    
      "          } \n " +  
      "        }  \n " + 
      "      } \n " +
      "    } \n " +
      "  } \n " +
      "} UNION { \n " +
      "SELECT ?form ?fName ?group ?gName ?item ?iName ?bcProperty ?bcRoot ?bcIdent ?alias ?qText ?datatype ?cCode ?subValue ?sdtmVarName ?dataset ?domain ?var WHERE \n " + 
      "        { \n " +    
      "          :" + self.id + " bf:hasGroup ?groupM . \n " +     
      "          ?form bf:hasGroup ?groupM . \n " +     
      "          ?form rdfs:label ?fName . \n " +
      "          ?groupM bf:hasSubGroup ?group . \n " +
      "          ?group rdfs:label ?gName . \n " +
      "          ?group bf:hasItem ?item . \n " +
      "          ?item rdfs:label ?iName . \n " +
      "          ?item bf:hasProperty ?x . \n " +             
      "          ?x bo:hasProperty ?bcProperty  . \n " +      
      # "          ?var bd:hasProperty ?bcProperty . \n " +     
      "          ?bcProperty (cbc:isPropertyOf | cbc:isDatatypeOf | cbc:isItemOf)%2B ?bcRoot . \n" +
      "          ?bcRoot rdf:type cbc:BiomedicalConceptInstance . \n " +
      "          ?bcProperty cbc:alias ?alias . \n " +     
      "          ?bcProperty cbc:qText ?qText . \n " +     
      "          ?bcProperty cbc:simpleDatatype ?datatype . \n " +     
      "          ?bcRoot isoI:hasIdentifier ?si . \n " +     
      "          ?si isoI:identifier ?bcIdent . \n " + 
      "          FILTER NOT EXISTS { ?var bd:hasProperty ?bcProperty } \n " + 
      "          OPTIONAL \n " +    
      "          { \n " +      
      # "            ?bcProperty (cbc:hasValue | cbc:nextValue)%2B  ?bcValue . \n " +       
      # "            ?bcValue rdf:type cbc:PropertyValue . \n " +       
      "            ?item bf:hasValue ?y . \n " +             
      "            ?y bo:hasValue ?bcValue  . \n " +      
      "            ?y bo:enabled ?enabled  . \n " +      
      # "            ?bcValue cbc:value ?cCode . \n " +       
      "            ?bcValue cbc:value ?cli . \n " +       
      "            ?cli iso25964:identifier ?cCode . \n " +       
      "            ?cli iso25964:notation ?subValue . \n " +       
      # "            ?cl skos:narrower ?cli . \n " +       
      # "            ?cl skos:inScheme ?th . \n " +       
      "            FILTER(?enabled=true) . \n " +    
      "          } \n " +  
      "        }  \n " + 
      "      } \n " +
      "      } \n " 
      
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
    html = Xslt.executeXML(path, "form/export/toHTML.xsl", {})
    return html

  end

  def crf
  
    query = UriManagement.buildNs(self.namespace, ["bf", "bo", "mms", "cbc", "bd", "cdisc", "isoI", "iso25964"])  +
      "SELECT DISTINCT ?form ?fName ?group ?gName ?item ?iName ?bcProperty ?bcRoot ?bcIdent ?alias ?qText ?datatype ?cCode ?subValue WHERE \n" +
      "{ \n " +
      "  :" + self.id + " bf:hasGroup ?groupM . \n " +     
      "  ?form bf:hasGroup ?groupM . \n " +     
      "  ?form rdfs:label ?fName . \n " +
      "  ?groupM bf:hasSubGroup ?group . \n " +
      "  ?group rdfs:label ?gName . \n " +
      "  ?group bf:hasItem ?item . \n " +
      "  ?item rdfs:label ?iName . \n " +
      "  ?item bf:hasProperty ?x . \n " +             
      "  ?x bo:hasProperty ?bcProperty  . \n " +      
      "  ?bcProperty (cbc:isPropertyOf | cbc:isDatatypeOf | cbc:isItemOf)%2B ?bcRoot . \n" +
      "  ?bcRoot rdf:type cbc:BiomedicalConceptInstance . \n " +
      "  ?bcProperty cbc:alias ?alias . \n " +     
      "  ?bcProperty cbc:qText ?qText . \n " +     
      "  ?bcProperty cbc:simpleDatatype ?datatype . \n " +     
      "  ?bcRoot isoI:hasIdentifier ?si . \n " +     
      "  ?si isoI:identifier ?bcIdent . \n " +     
      "  OPTIONAL \n " +    
      "  { \n " +      
      # "    ?bcProperty (cbc:hasValue | cbc:nextValue)%2B  ?bcValue . \n " +       
      # "    ?bcValue rdf:type cbc:PropertyValue . \n " +       
      "    ?item bf:hasValue ?y . \n " +             
      "    ?y bo:hasValue ?bcValue  . \n " +      
      "    ?y bo:enabled ?enabled  . \n " +      
      # "    ?bcValue cbc:value ?cCode . \n " +       
      "    ?bcValue cbc:value ?cli . \n " +       
      "    ?cli iso25964:identifier ?cCode . \n " +       
      "    ?cli iso25964:notation ?subValue . \n " +       
      # "    ?cl skos:narrower ?cli . \n " +       
      # "    ?cl skos:inScheme ?th . \n " +       
      "    FILTER(?enabled=true) . \n " +    
      "  } \n " +  
      "}\n"

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
    html = Xslt.executeXML(path, "form/export/toHTML.xsl", {})
    return html

  end

  def d3
    ig = 0
    result = FormNode.new(self.id, self.namespace, "Form", self.label, self.label, self.identifier, "", "", 0, true)
    self.groups.each do |key, group|
      result[:children][ig] = group.d3(ig)
      ig += 1
    end
    result[:save] = result[:children]
    return result
  end

  def self.impact(params)
  
    id = params[:id]
    namespace = params[:namespace]
    results = Hash.new

    # Build the query. Note the full namespace reference, doesnt seem to work with a default namespace. Needs checking.
    query = UriManagement.buildPrefix(C_INSTANCE_PREFIX, ["bf", "bo"])  +
      "SELECT DISTINCT ?form WHERE \n" +
      "{ \n " +
      "  ?form rdf:type bf:Form . \n " +
      "  ?form (bf:hasGroup|bf:hasSubGroup|bf:hasBiomedicalConcept|bo:hasBiomedicalConcept)%2B " + ModelUtility.buildUri(namespace, id) + " . \n " +"
      "  "}\n"

    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"create","Node=" + node.to_s)
      form = ModelUtility.getValue('form', true, node)
      if form != ""
        id = ModelUtility.extractCid(form)
        namespace = ModelUtility.extractNs(form)
        results[id] = find(id, namespace)
        ConsoleLogger::log(C_CLASS_NAME,"impact","Object found, id=" + id)        
      end
    end

    return results
  end

  def self.empty
    text = {:name => "Form", :identifier => "New Form", :label => "Form", :type => "Form", :key => "1", :id => "Not set", :nextKeyId => "3"}
    text[:children] = []
    text[:children][0] = {:name => "Group", :identifier => "New Group", :label => "Group", :type => "Group", :key => "2", :id => "Not set"}
    return text
  end

private

  def self.params_valid?(params, object)
    
    result1 = ModelUtility::validIdentifier?(params[:identifier], object)
    result2 = ModelUtility::validLabel?(params[:label], object)
    if params.has_key?(:bcs)
      result3 = validBcs?(params[:bcs], object)
    else
      result3 = true
    end 
    if params.has_key?(:freeText)
      result4 = ModelUtility::validFreeText?(:free_text,params[:freeText], object)
    else
      result4 = true
    end 
    return result1 && result2 && result3 && result4

  end

  def self.validBcs?(value, object)
    if value != nil
      return true
    else
      object.errors.add(:biomedical_concepts, ", select one or more concepts.")
      return false
    end
  end

  def self.addGroup(formId, namespace, ordinal, params)
    
    ConsoleLogger::log(C_CLASS_NAME,"addGroup","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"addGroup","Params=" + params.to_s)
    
    if params[:type] == "Group"
      ConsoleLogger::log(C_CLASS_NAME,"addGroup","Group")
      group = Group.createBlank(formId, namespace, ordinal, params)
      if params.has_key?(:children)
        ConsoleLogger::log(C_CLASS_NAME,"addGroup","Child")
        innerOrdinal = 1
        insertSparql = ""
        children = params[:children]
        children.each do |key, child|
          if child[:type] == "Question"
            ConsoleLogger::log(C_CLASS_NAME,"addGroup","Question detected")
            ConsoleLogger::log(C_CLASS_NAME,"addGroup","Child=" + child.to_s)
            qText = child[:freeText]
            format = child[:freeText]
            datatype = child[:freeText]
            mapping = child[:freeText]
            item = Form::Item.createQuestion(group.id, namespace, qText, datatype, format, mapping)
            innerOrdinal += 1;
            insertSparql = insertSparql + "  :" + group.id + " bf:hasItem :" + item.id + " . \n"
          elsif child[:type] == "Placeholder"
            ConsoleLogger::log(C_CLASS_NAME,"addGroup","Placeholder detected")
            freeText = child[:freeText]
            item = Form::Item.createPlaceholder(group.id, namespace, freeText)
            innerOrdinal += 1;
            insertSparql = insertSparql + "  :" + group.id + " bf:hasItem :" + item.id + " . \n"
          else
            ConsoleLogger::log(C_CLASS_NAME,"addGroup","Subgroup detected")
            subGroup = addGroup(group.id, namespace, innerOrdinal, child)
            innerOrdinal += 1;
            insertSparql = insertSparql + "  :" + group.id + " bf:hasSubGroup :" + subGroup.id + " . \n"
          end
        end
      
        # Create the update query
        update = UriManagement.buildNs(namespace,["bf"]) +
          "INSERT DATA \n" +
          "{ \n" +
          insertSparql +
          "}"
        
        # Send the request, wait the resonse
        response = CRUD.update(update)
        
        # Response
        if response.success?
          ConsoleLogger::log(C_CLASS_NAME,"addGroup","Updated group, id=" + group.id)
        else
          object.errors.add(:base, "The group was not updated in the database.")
          ConsoleLogger::log(C_CLASS_NAME,"addGroup","Object not updated!")
        end
      end

    elsif params[:type] == "CommonGroup"
      group = Group.createCommon(formId, namespace, ordinal, params)
    elsif params[:type] == "BCGroup"
      group = Group.createBcEdit(formId, namespace, ordinal, params)
    end

    return group      
  
  end

end
