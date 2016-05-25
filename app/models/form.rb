class Form < IsoManagedNew
  
  attr_accessor :groups, :formCompletion, :formNote
  #validates_presence_of :groups
  
  # Constants
  C_SCHEMA_PREFIX = "bf"
  C_INSTANCE_PREFIX = "mdrForms"
  C_CLASS_NAME = "Form"
  C_CID_PREFIX = "F"
  C_RDF_TYPE = "Form"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.groups = Array.new
    self.label = "New Form"
    self.formCompletion = ""
    self.formNote = ""
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      object.groups = Form::Group.find_for_parent(object.triples, object.get_links("bf", "hasGroup"))
    end
    #object.triples = ""
    ConsoleLogger::log(C_CLASS_NAME,"find", "formCompletion=" + object.formCompletion.to_s)
    return object     
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(params)
    results = super(C_RDF_TYPE, C_SCHEMA_NS, params)
    return results
  end

  def self.createPlaceholder(params)
    object = self.new 
    object.errors.clear
    if params_valid?(params, object)
      identifier = params[:identifier]
      freeText = params[:freeText]
      label = params[:label]
      params[:versionLabel] = "0.1"
      params[:version] = "1"
      if exists?(identifier, IsoRegistrationAuthority.owner()) 
        object.errors.add(:base, "The identifier is already in use.")
      else  
        object = IsoManagedNew.create(C_CID_PREFIX, params, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS)
        group = Group.createPlaceholder(object.id, object.namespace, freeText)
        update = UriManagement.buildNs(object.namespace,["bf"]) +
          "INSERT DATA \n" +
          "{ \n" +
          "  :" + object.id + " bf:hasGroup :" + group.id + " . \n" +
          "  :" + object.id + " bf:formCompletion \"\"^^xsd:string . \n" +
          "  :" + object.id + " bf:formNote \"\"^^xsd:string . \n" +
          "}"
        response = CRUD.update(update)
        if !response.success?
          object.errors.add(:base, "The group was not created in the database.")
        end
      end
    end
    return object
  end
  
  def self.create(params)
    object = self.new 
    object.errors.clear
    data = params[:data]
    operation = data[:operation]
    managed_item = data[:managed_item]
    if params_valid?(managed_item, object)
      if create_permitted?(managed_item[:identifier], operation[:new_version].to_i, object) 
        sparql = SparqlUpdate.new
        managed_item[:versionLabel] = "0.1"
        managed_item[:new_version] = operation[:new_version]
        managed_item[:new_state] = operation[:new_state]
        uri = create_sparql(C_CID_PREFIX, managed_item, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS, sparql)
        id = uri.getCid()
        ns = uri.getNs()
        Form.to_sparql(id, sparql, C_SCHEMA_PREFIX, managed_item)
        ConsoleLogger::log(C_CLASS_NAME,"create", "SPARQL=" + sparql.to_s)
        response = CRUD.update(sparql.to_s)
        if response.success?
          object = Form.find(id, ns)
          object.errors.clear
        else
          object.errors.add(:base, "The Form was not created in the database.")
        end
      end
    end
    return object
  end

   def self.update(params)
    object = self.new 
    object.errors.clear
    data = params[:data]
    operation = data[:operation]
    managed_item = data[:managed_item]
    form = Form.find(managed_item[:id], managed_item[:namespace])
    sparql = SparqlUpdate.new
    managed_item[:versionLabel] = "0.1"
    managed_item[:new_version] = operation[:new_version]
    managed_item[:new_state] = operation[:new_state]
    uri = create_sparql(C_CID_PREFIX, managed_item, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS, sparql)
    id = uri.getCid()
    ns = uri.getNs()
    Form.to_sparql(id, sparql, C_SCHEMA_PREFIX, managed_item)
    form.destroy # Destroys the old entry before the creation of the new item
    response = CRUD.update(sparql.to_s)
    if response.success?
      object = Form.find(id, ns)
      object.errors.clear
    else
      object.errors.add(:base, "The Form was not created in the database.")
    end
    return object
  end

  def annotation
    results = Array.new
    query = UriManagement.buildNs(self.namespace, ["bf", "bo", "mms", "cbc", "bd", "cdisc", "isoI", "iso25964"])  +
      "SELECT ?item ?domain ?sdtmVarName ?sdtmTopicName ?sdtmTopicSub WHERE \n" +
      "{ \n " +
      "  ?node1 bd:basedOn ?node2 . \n " +
      "  ?node1 rdf:type bd:Variable . \n " +
      "  ?node2 mms:dataElementName ?sdtmTopicName . \n " +
      "  ?node1 bd:hasProperty ?node4 . \n " +
      "  ?node4 (cbc:isPropertyOf | cbc:isDatatypeOf | cbc:isItemOf)%2B ?bcRoot . \n" +
      "  ?node4 cbc:hasValue ?valueRef . \n " +
      "  ?valueRef cbc:value ?sdtmTopicValueObj . \n " +
      "  ?sdtmTopicValueObj iso25964:identifier ?sdtmTopicValue . \n " +
      "  ?sdtmTopicValueObj iso25964:notation ?sdtmTopicSub . \n " +
      "  {\n " +
      "    SELECT ?form ?group ?item ?bcProperty ?bcRoot ?bcIdent ?sdtmVarName ?domain ?sdtmTopicName WHERE \n " +
      "    { \n " + 
      "      ?var bd:basedOn ?col . \n " +     
      "      ?col mms:dataElementName ?sdtmVarName . \n " +     
      "      ?col mms:context ?dataset . \n " +     
      "      ?dataset mms:contextLabel ?domain . \n " +     
      "      ?node5 mms:context ?dataset . \n " +     
      "      ?node5 cdisc:dataElementRole <http://rdf.cdisc.org/std/sdtm-1-2#Classifier.TopicVariable> . \n " +     
      "      ?node5 mms:dataElementName ?sdtmTopicName . \n " +     
      "      { \n " +
      "        SELECT ?group ?item ?bcProperty ?bcRoot ?bcIdent ?sdtmVarName ?dataset ?var ?gord ?pord WHERE \n " + 
      "        { \n " +    
      "          :" + self.id + " (bf:hasGroup|bf:hasSubGroup|bf:hasCommon)%2B ?group . \n " +     
      "          ?group bf:ordinal ?gord . \n " +      
      "          ?group (bf:hasItem|bf:hasCommonItem)%2B ?item . \n " +        
      "          ?item bf:hasProperty ?x . \n " +             
      "          ?x bo:hasProperty ?bcProperty  . \n " +      
      "          ?var bd:hasProperty ?bcProperty . \n " +     
      "          ?bcProperty (cbc:isPropertyOf | cbc:isDatatypeOf | cbc:isItemOf)%2B ?bcRoot . \n" +
      "          ?bcRoot rdf:type cbc:BiomedicalConceptInstance . \n " +
      "          ?bcProperty cbc:ordinal ?pord . \n " +     
      "          ?bcRoot isoI:hasIdentifier ?si . \n " +     
      "          ?si isoI:identifier ?bcIdent . \n " +     
      "        }  \n " + 
      "      } \n " +
      "    } \n " +
      "  } \n " +
      "} ORDER BY ?gord ?pord \n " 
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      item = ModelUtility.getValue('item', true, node)
      domain = ModelUtility.getValue('domain', false, node)
      sdtm_var = ModelUtility.getValue('sdtmVarName', false, node)
      sdtm_topic = ModelUtility.getValue('sdtmTopicName', false, node)
      sdtm_topic_value = ModelUtility.getValue('sdtmTopicSub', false, node)
      if item != ""
        results << {
          :id => ModelUtility.extractCid(item), :namespace => ModelUtility.extractNs(item), 
          :domain => domain, :sdtm_variable => sdtm_var, :sdtm_topic_variable => sdtm_topic, :sdtm_topic_value => sdtm_topic_value
        }
      end
    end
    return results
  end

  def crf
    form = self.to_api_json
    html = crf_node(form)
    return html
  end

  def acrf
    form = self.to_api_json
    #ConsoleLogger::log(C_CLASS_NAME,"acrf_new","Form=" + form.to_s)       
    annotations = self.annotation
    #ConsoleLogger::log(C_CLASS_NAME,"acrf_new","Annotations=" + annotations.to_json.to_s)       
    html = crf_node(form, annotations)
    return html
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
        results[id] = find(id, namespace, false)
      end
    end
    return results
  end

  def d3
    ig = 0
    result = FormNode.new(self.id, self.namespace, "Form", self.label, self.label, self.identifier, "", "", 0, true)
    self.groups.each do |group|
      result[:children][ig] = group.d3(ig)
      ig += 1
    end
    result[:save] = result[:children]
    return result
  end

  def to_api_json
    result = super
    result[:type] = "Form"
    result[:formCompletion] = self.formCompletion
    result[:formNote] = self.formNote
    self.groups.each do |group|
      result[:children][group.ordinal - 1] = group.to_api_json
    end
    return result
  end

  def self.to_sparql(parent_id, sparql, schema_prefix, json)
    ConsoleLogger::log(C_CLASS_NAME,"to_sparql", "JSON=" + json.to_s)
    id = parent_id 
    #super(id, sparql, schema_prefix, "form", json[:label]) #Inconsistent at the moment. Handled within the SI & RS creation
    ConsoleLogger::log(C_CLASS_NAME,"to_sparql", "formCompletion=" + json[:formCompletion])
    sparql.triple_primitive_type("", id, schema_prefix, "formCompletion", json[:formCompletion], "string")
    sparql.triple_primitive_type("", id, schema_prefix, "formNote", json[:formNote], "string")
    if json.has_key?(:children)
      json[:children].each do |key, group|
        sparql.triple("", id, schema_prefix, "hasGroup", "", id + Uri::C_UID_SECTION_SEPARATOR + 'G' + group[:ordinal].to_s  )
      end
    end
    if json.has_key?(:children)
      json[:children].each do |key, item|
        Form::Group.to_sparql(id, sparql, schema_prefix, item)
      end
    end
  end

  def destroy
    # Create the query
    update = UriManagement.buildNs(self.namespace, [C_SCHEMA_PREFIX, "isoI", "isoR"]) +
      "DELETE \n" +
      "{\n" +
      "  ?s ?p ?o . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  {\n" +
      "    :" + self.id + " (:|!:)* ?s . \n" +  
      "    ?s ?p ?o . \n" +
      "    FILTER(STRSTARTS(STR(?s), \"" + self.namespace + "\"))" +
      "  } UNION {\n" + 
      "    :" + self.id + " isoI:hasIdentifier ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  } UNION {\n" + 
      "    :" + self.id + " isoR:hasState ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  }\n" + 
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

private

  def self.params_valid?(params, object)
    result1 = ModelUtility::validIdentifier?(params[:identifier], object)
    result2 = ModelUtility::validLabel?(params[:label], object)
    return result1 && result2 # && result3 && result4
  end

  def self.validBcs?(value, object)
    if value != nil
      return true
    else
      object.errors.add(:biomedical_concepts, ", select one or more concepts.")
      return false
    end
  end

  def crf_node(node, annotations=nil)
    html = ""
    #ConsoleLogger.log("Mdr", "crfNode", "Node=" + node.to_s)
    if node[:type] == "Form"
      html += '<table class="table table-striped table-bordered table-condensed">'
      html += '<tr>'
      html += '<td colspan="2"><h4>' + node[:label].to_s + '</h4></td>'
      if annotations != nil
        html += '<td><font color="red"><h4>' 
        domains = annotations.uniq {|entry| entry[:domain] }
        domains.each do |domain|
          html += domain[:domain].to_s + '<br/>'
        end
        html += '</h4></font></td>'
      else
        html += '<td></td>'
      end
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, annotations)
      end
      html += '</table>'
    elsif node[:type] == "CommonGroup"
      #ConsoleLogger::log(C_CLASS_NAME,"crf_node","node=" + node.to_json.to_s)
      html += '<tr>'
      html += '<td colspan="3"><h5>' + node[:label].to_s + '</h5></td>'
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, annotations)
      end
    elsif node[:type] == "Group"
      html += '<tr>'
      html += '<td colspan="3"><h5>' + node[:label].to_s + '</h5></td>'
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, annotations)
      end
    elsif node[:type] == "BCGroup"
      html += '<tr>'
      html += '<td colspan="3"><h5>' + node[:label].to_s + '</h5></td>'
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, annotations)
      end
    elsif node[:type] == "Placeholder"
      html += '<tr>'
      html += '<td colspan="3"><h5>Placeholder Text</h5><p><i>' + node[:free_text].to_s + '</i></p></td>'
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, annotations)
      end
    elsif node[:type] == "Question"
      ConsoleLogger::log(C_CLASS_NAME,"crf_node", "node=" + node.to_json.to_s)
      html += '<tr>'
      html += '<td>' + node[:qText].to_s + '</td>'
      if annotations != nil
        html += '<td><font color="red">' + node[:mapping].to_s + '</font></td>'
      else
        html += '<td></td>'
      end
      html += input_field(node, annotations)
      html += '</tr>'
    elsif node[:type] == "BCItem"
      html += '<tr>'
      html += '<td>' + node[:qText].to_s + '</td>'
      html += '<td>'
      first = true
      if annotations != nil
        entries = annotations.select {|item| item[:id] == node[:id]}
        entries.each do |entry|
          if !first
            html += '<br/>'
          end
          html += '<font color="red">' + entry[:sdtm_variable] + ' where ' + entry[:sdtm_topic_variable] + '=' + entry[:sdtm_topic_value] + '</font>'
          first = false
        end
        node[:otherCommon].each do |child|
          entries = annotations.select {|item| item[:id] == child[:id]}
          entries.each do |entry|
            if !first
              html += '<br/>'
            end
            html += '<font color="red">' + entry[:sdtm_variable] + ' where ' + entry[:sdtm_topic_variable] + '=' + entry[:sdtm_topic_value] + '</font>'
            first = false
          end
        end
      end
      html += '</td>'
      html += input_field(node, annotations)
      html += '</tr>'
    elsif node[:type] == "CL"
      #ConsoleLogger::log(C_CLASS_NAME,"crf_node","node=" + node.to_json.to_s)
      value_ref = node[:value_reference]
      #.ConsoleLogger::log(C_CLASS_NAME,"crf_node","value_ref=" + value_ref.to_json.to_s)
      if value_ref[:enabled]
        html += '<p><input type="radio" name="' + node[:identifier].to_s + '" value="' + node[:identifier].to_s + '"></input> ' + node[:label].to_s + '</p>'
      end
    else
      html += '<tr>'
      html += '<td>Not Recognized: ' + node[:type].to_s + '</td>'
      html += '<td></td>'
      html += '<td></td>'
      html += '</tr>'
    end
    return html
  end

  def input_field(node, annotations)
    html = '<td>'
    if node[:datatype] == "CL"
      node[:children].each do |child|
        html += crf_node(child, annotations)
      end
    elsif node[:datatype] == "D+T"
      html += '<input type="date" name="date"> <input type="time" name="time">'
    elsif node[:datatype] == "F"
      html += '<input type="number"> . <input type="number">' 
    elsif node[:datatype] == "I"
      html += '<input type="number">' 
    else
      html += "Not implemented yet."
    end
    html += '</td>'
    return html
  end
end
