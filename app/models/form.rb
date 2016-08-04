class Form < IsoManaged
  
  attr_accessor :groups, :completion, :note
  #validates_presence_of :groups
  
  # Constants
  C_SCHEMA_PREFIX = "bf"
  C_INSTANCE_PREFIX = "mdrForms"
  C_CLASS_NAME = "Form"
  C_CID_PREFIX = "F"
  C_RDF_TYPE = "Form"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  #TODO: This should be a query from the domains
  @@domain_map = {
    "AD" => "Analysis Dataset",
    "AE" => "Adverse Events",
    "AG" => "Procedure Agents",
    "AU" => "Autopsy",
    "AX" => "Non-Compliant ADaM Datasets",
    "BE" => "Biospecimen Events",
    "BM" => "Bone Measurements",
    "BR" => "Biopsy",
    "BS" => "Biospecimen",
    "CE" => "Clinical Events",
    "CM" => "Concomitant Meds",
    "CO" => "Comments",
    "CV" => "Cardiovascular System Findings",
    "DA" => "Drug Accountability",
    "DD" => "Death Diagnosis",
    "DE" => "Device Events",
    "DI" => "Device Identifiers",
    "DM" => "Demographics",
    "DO" => "Device Properties",
    "DP" => "Developmental Milestone",
    "DR" => "Device to Subject Relationship",
    "DS" => "Disposition",
    "DT" => "Device Tracking and Disposition",
    "DU" => "Device-In-Use",
    "DV" => "Protocol Deviations",
    "DX" => "Device Exposure",
    "ED" => "Endocrine System Findings",
    "EG" => "Electrocardiogram",
    "EX" => "Exposure",
    "FA" => "Findings About Events or Interventions",
    "FH" => "Family History",
    "FT" => "Functional Tests",
    "GI" => "Gastrointestinal System Findings",
    "HM" => "Hematopoietic System Findings",
    "HO" => "Healthcare Encounters",
    "HU" => "Healthcare Resource Utilization",
    "IE" => "Inclusion/Exclusion",
    "IG" => "Integumentary System Findings",
    "IM" => "Immune System Findings",
    "IS" => "Immunogenicity Specimen Assessments",
    "LB" => "Laboratory Data",
    "MB" => "Microbiology",
    "MH" => "Medical History",
    "MI" => "Microscopic Findings",
    "MK" => "Musculoskeletal Findings, Connective and Soft Tissue Findings",
    "ML" => "Meal Data",
    "MO" => "Morphology Findings",
    "MS" => "Microbiology Susceptibility",
    "NV" => "Nervous System Findings",
    "PB" => "Pharmacogenomics Biomarker",
    "PC" => "Pharmacokinetic Concentration",
    "PE" => "Physical Exam",
    "PF" => "Pharmacogenomics Findings",
    "PG" => "Pharmacogenomics/Genetics Methods and Supporting Information",
    "PP" => "Pharmacokinetic Parameters",
    "PR" => "Procedure",
    "PS" => "Protocol Summary for PGx",
    "PT" => "Pharmacogenomics Trial Characteristics",
    "QS" => "Questionnaires",
    "RE" => "Respiratory System Findings",
    "RP" => "Reproductive System Findings",
    "RS" => "Disease Response",
    "SB" => "Subject Biomarker",
    "SC" => "Subject Characteristics",
    "SE" => "Subject Element",
    "SG" => "Surgery",
    "SK" => "Skin Test",
    "SL" => "Sleep Polysomnography Data",
    "SR" => "Skin Response",
    "SU" => "Substance Use",
    "SV" => "Subject Visits",
    "TA" => "Trial Arms",
    "TE" => "Trial Elements",
    "TF" => "Tumor Findings",
    "TI" => "Trial Inclusion/Exclusion Criteria",
    "TP" => "Trial Paths",
    "TR" => "Tumor Results",
    "TS" => "Trial Summary",
    "TU" => "Tumor Identifier",
    "TV" => "Trial Visits",
    "TX" => "Trial Sets",
    "UR" => "Urinary System Findings",
    "VR" => "Viral Resistance Findings",
    "VS" => "Vital Signs" }

  def initialize(triples=nil, id=nil)
    self.groups = Array.new
    self.label = "New Form"
    self.completion = ""
    self.note = ""
    if triples.nil?
      super
      # Set the type. Overwrite default.
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      object.groups = Form::Group::Normal.find_for_parent(object.triples, object.get_links("bf", "hasGroup"))
    end
    object.triples = ""
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
    if params_valid_placeholder?(params, object)
      object.scopedIdentifier.identifier = params[:identifier]
      object.label = params[:label]
      group = Form::Group::Normal.new
      group.label = "Placeholder Group"
      item = Form::Item::Placeholder.new
      item.label = "Placeholder"
      item.free_text = params[:freeText]
      object.groups << group
      group.items << item
      if exists?(object.identifier, IsoRegistrationAuthority.owner()) 
        object.errors.add(:base, "The identifier is already in use.")
      else  
        object = Form.create({:data => object.to_edit(true)})
      end
    end
    return object
  end
  
  def self.create(params)
    # Get the parameters
    data = params[:data]
    operation = data[:operation]
    managed_item = data[:managed_item]
    # Create blank object for the errors
    object = self.new
    object.errors.clear
    # Set owner ship
    ra = IsoRegistrationAuthority.owner
    if params_valid?(managed_item, object) then
      # Build a full object. 
      object = Form.from_json(data)
      # Can we create?
      if object.create_permitted?(ra)
        # Build sparql
        sparql = object.to_sparql(ra)
        # Send to database
        ConsoleLogger::log(C_CLASS_NAME,"create","Object=#{sparql}")
        response = CRUD.update(sparql.to_s)
        if !response.success?
          object.errors.add(:base, "The Domain was not created in the database.")
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
    #ConsoleLogger::log(C_CLASS_NAME,"update", "managed_item=" + managed_item.to_json.to_s)
    form = Form.find(managed_item[:id], managed_item[:namespace])
    ra = IsoRegistrationAuthority.owner
    object = Form.from_json(data)
    sparql = object.to_sparql(ra)
    form.destroy # Destroys the old entry before the creation of the new item
    ConsoleLogger::log(C_CLASS_NAME,"create","Object=#{sparql}")
    response = CRUD.update(sparql.to_s)
    if response.success?
      object.errors.clear
    else
      object.errors.add(:base, "The Form was not created in the database.")
    end
    return object
  end

  def destroy
    super(self.namespace)
  end

  def to_json
    json = super
    json[:completion] = self.completion
    json[:note] = self.note
    json[:children] = Array.new
    self.groups.each do |child|
      json[:children] << child.to_json
    end
    return json
  end

  def self.from_json(json)
    object = super(json)
    managed_item = json[:managed_item]
    object.completion = managed_item[:completion]
    object.note = managed_item[:note]
    if managed_item.has_key?(:children)
      managed_item[:children].each do |child|
        object.groups << Form::Group::Normal.from_json(child)
      end
    end
    return object
  end

  def to_sparql(ra)
    sparql = SparqlUpdate.new
    uri = super(sparql, ra, C_CID_PREFIX, C_INSTANCE_NS, C_SCHEMA_PREFIX)
    # Set the properties
    sparql.triple_primitive_type("", uri.id, C_SCHEMA_PREFIX, "completion", "#{self.completion}", "string")
    sparql.triple_primitive_type("", uri.id, C_SCHEMA_PREFIX, "note", "#{self.note}", "string")
    # Now deal with the children
    self.groups.each do |group|
      ref_id = group.to_sparql(uri.id, sparql)
      sparql.triple("", uri.id, C_SCHEMA_PREFIX, "hasGroup", "", ref_id)
    end
    ConsoleLogger::log(C_CLASS_NAME,"to_sparql","SPARQL=#{sparql}")
    return sparql
  end

  def self.bc_impact(params)
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

  def self.term_impact(params)
    id = params[:id]
    namespace = params[:namespace]
    results = Hash.new
    # Build the query. Note the full namespace reference, doesnt seem to work with a default namespace. Needs checking.
    query = UriManagement.buildPrefix(C_INSTANCE_PREFIX, ["bf", "bo"])  +
      "SELECT DISTINCT ?form WHERE \n" +
      "{ \n " +
      "  ?form rdf:type bf:Form . \n " +
      "  ?form (bf:hasGroup|bf:hasSubGroup|bf:hasItem|bf:hasThesaurusConcept|bo:hasThesaurusConcept)%2B " + ModelUtility.buildUri(namespace, id) + " . \n " +"
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

  def crf
    form = self.to_api_json
    html = crf_node(form)
    return html
  end

  def acrf
    form = self.to_api_json
    annotations = Array.new
    annotations += bc_annotations
    annotations += question_annotations
    html = crf_node(form, annotations)
    return html
  end

  def report(options, user)
    doc_history = Array.new
    if options[:full]
      history = IsoManaged::history(C_RDF_TYPE, C_SCHEMA_NS, {:identifier => self.identifier, :scope_id => self.owner_id})
      history.each do |item|
        if self.same_version?(item.version) || self.later_version?(item.version)
          doc_history << item.to_api_json
        end
      end
    end
    form = self.to_api_json
    annotations = Array.new
    if options[:annotate]
      annotations += bc_annotations
      annotations += question_annotations
    end
    pdf = Reports::CrfReport.create(form, options, annotations, doc_history, user)
  end

private

  def self.params_valid?(params, object)
    result1 = ModelUtility::validIdentifier?(params[:scoped_identifier][:identifier], object)
    result2 = ModelUtility::validLabel?(params[:label], object)
    return result1 && result2 # && result3 && result4
  end

  def self.params_valid_placeholder?(params, object)
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
        domains = annotations.uniq {|entry| entry[:domain_prefix] }
        domains.each do |domain|
          ConsoleLogger::log(C_CLASS_NAME,"crf_node","domain=" + domain.to_json.to_s)
          suffix = ""
          prefix = domain[:domain_prefix]
          if domain[:domain_long_name] != ""
            suffix = "=" + domain[:domain_long_name]
          end
          html += domain[:domain_prefix].to_s + suffix + '<br/>'
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
      if node[:repeating]
        html += '<tr>'
        html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
        html += '<tr>'
        node[:children].each do |child|
          html += '<th>' + child[:qText] + '</th>'
        end 
        html += '</tr>'
        if annotations != nil
          html += '<tr>'
          node[:children].each do |child|
            html += '<td><font color="red">' + child[:mapping] + '</font></td>'
          end 
          html += '</tr>'
        end
        html += '<tr>'
        node[:children].each do |child|
          html += input_field(child, annotations)
        end 
        html += '</tr>'
        html += '</table></td>'
        html += '</tr>'
      else
        node[:children].each do |child|
          html += crf_node(child, annotations)
        end
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
      html += "<td colspan=\"3\"><p>#{MarkdownEngine::render(node[:free_text])}</p></td>"
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, annotations)
      end
    elsif node[:type] == "Question"
      ConsoleLogger::log(C_CLASS_NAME,"crf_node", "node=" + node.to_json.to_s)
      if node[:optional]
        html += '<tr class="warning">'
      else
        html += '<tr>'
      end
      html += '<td>' + node[:qText].to_s + '</td>'
      if annotations != nil
        html += '<td><font color="red">' + node[:mapping].to_s + '</font></td>'
      else
        html += '<td></td>'
      end
      html += input_field(node, annotations)
      html += '</tr>'
    elsif node[:type] == "BCItem"
      if node[:optional]
        html += '<tr class="warning">'
      else
        html += '<tr>'
      end
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
      value_ref = node[:thesaurus_concept_reference]
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
    elsif node[:datatype] == "D"
      html += '<input type="date" name="date">'
    elsif node[:datatype] == "T"
      html += '<input type="time" name="time">'
    elsif node[:datatype] == "F"
      html += '<input type="number"> . <input type="number">' 
    elsif node[:datatype] == "I"
      html += '<input type="number">' 
    elsif node[:datatype] == "S"
      html += "<input type=\"text\" value=\"S#{node[:format]}\">" 
    else
      html += "Not implemented yet."
    end
    html += '</td>'
    return html
  end

  def bc_annotations()
    ConsoleLogger::log(C_CLASS_NAME,"bc_annotations", "*****Entry*****")
    results = Array.new
    query = UriManagement.buildNs(self.namespace, ["bf", "bo", "mms", "cbc", "bd", "cdisc", "isoI", "iso25964"])  +
      "SELECT ?item ?domain ?sdtmVarName ?sdtmTopicName ?sdtmTopicSub WHERE \n" +
      "{ \n " +
      "  ?topic_var bd:hasProperty ?op_ref3 . \n " +
      "  ?op_ref3 bo:hasProperty ?bc_topic_property . \n " +     
      "  ?bc_topic_property (cbc:isPropertyOf | cbc:isDatatypeOf | cbc:isItemOf)%2B ?bcRoot . \n " +
      "  ?bc_topic_property cbc:hasValue ?valueRef . \n " +
      "  ?valueRef cbc:value ?sdtmTopicValueObj . \n " +     
      "  ?sdtmTopicValueObj iso25964:notation ?sdtmTopicSub . \n " +     
      "  {\n " +
      "    SELECT ?form ?group ?item ?bcProperty ?bcRoot ?bcIdent ?sdtmVarName ?domain ?sdtmTopicName ?topic_var WHERE \n " +
      "    { \n " + 
      "      ?var bd:name ?sdtmVarName . \n " +              
      "      ?dataset bd:includesColumn ?var . \n " +              
      "      ?dataset rdfs:label ?domain . \n " +              
      "      ?dataset bd:includesColumn ?topic_var . \n " +              
      "      ?topic_var bd:classifiedAs <http://www.assero.co.uk/MDRModels/CDISC/V1#M-CDISC_SDTMMODEL_C_TOPIC> . \n " +              
      "      ?topic_var bd:name ?sdtmTopicName . \n " +              
      "      { \n " +
      "        SELECT ?group ?item ?bcProperty ?bcRoot ?bcIdent ?sdtmVarName ?dataset ?var ?gord ?pord WHERE \n " + 
      "        { \n " +    
      "          :" + self.id + " (bf:hasGroup|bf:hasSubGroup|bf:hasCommon)%2B ?group . \n " +     
      "          ?group bf:ordinal ?gord . \n " +      
      "          ?group (bf:hasItem|bf:hasCommonItem)%2B ?item . \n " +        
      "          ?item bf:hasProperty ?op_ref1 . \n " +
      "          ?op_ref1 bo:hasProperty ?bcProperty  . \n " +             
      "          ?op_ref2 bo:hasProperty ?bcProperty . \n " +
      "          ?var bd:hasProperty ?op_ref2 . \n " +
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
      ConsoleLogger::log(C_CLASS_NAME,"bc_annotations", "node=" + node.to_json.to_s)
      item = ModelUtility.getValue('item', true, node)
      domain = ModelUtility.getValue('domain', false, node)
      sdtm_var = ModelUtility.getValue('sdtmVarName', false, node)
      sdtm_topic = ModelUtility.getValue('sdtmTopicName', false, node)
      sdtm_topic_value = ModelUtility.getValue('sdtmTopicSub', false, node)
      domain_long_name = ""
      if item != ""
        #ConsoleLogger::log(C_CLASS_NAME,"bc_annotation","domain=" + domain.to_s)
        if @@domain_map.has_key?(domain)
          domain_long_name = @@domain_map[domain]
          #ConsoleLogger::log(C_CLASS_NAME,"bc_annotation","domain long name(1)=" + domain_long_name.to_s)
        end
        #ConsoleLogger::log(C_CLASS_NAME,"bc_annotation","domain long name(2)=" + domain_long_name.to_s)
        results << {
          :id => ModelUtility.extractCid(item), :namespace => ModelUtility.extractNs(item), 
          :domain_prefix => domain, :domain_long_name => domain_long_name, :sdtm_variable => sdtm_var, :sdtm_topic_variable => sdtm_topic, :sdtm_topic_value => sdtm_topic_value
        }
      end
    end
    ConsoleLogger::log(C_CLASS_NAME,"bc_annotation","results=" + results.to_json.to_s)
    return results
  end

  def question_annotations()
    ConsoleLogger::log(C_CLASS_NAME,"question_annotations", "*****Entry*****")
    results = Array.new
    query = UriManagement.buildNs(self.namespace, ["bf", "bo", "mms", "bd", "cdisc", "isoI", "iso25964"])  +
      "SELECT ?var ?domain ?item WHERE \n" +       
      "{ \n" +         
      "  ?col bd:name ?var .  \n" +        
      "  ?dataset bd:includesColumn ?col . \n" +         
      "  ?dataset rdfs:label ?domain . \n" +         
      "  { \n" +           
      "    SELECT ?group ?item ?var ?gord ?pord WHERE \n" +           
      "    { \n" +             
      "      :" + self.id + " (bf:hasGroup|bf:hasSubGroup)+ ?group . \n" +
      "      ?group bf:ordinal ?gord . \n" +   
      "      ?group (bf:hasItem)+ ?item . \n" +             
      "      ?item bf:mapping ?var . \n" +  
      "      ?item bf:ordinal ?pord \n" + 
      "    } \n" +          
      "  } \n" +       
      "} ORDER BY ?gord ?pord \n"   
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"bc_annotations", "node=" + node.to_json.to_s)
      item = ModelUtility.getValue('item', true, node)
      variable = ModelUtility.getValue('var', false, node)
      domain = ModelUtility.getValue('domain', false, node)
      domain_long_name = ""
      if item != ""
        #ConsoleLogger::log(C_CLASS_NAME,"question_annotation","domain=" + domain.to_s)
        if @@domain_map.has_key?(domain)
          domain_long_name = @@domain_map[domain]
          #ConsoleLogger::log(C_CLASS_NAME,"question_annotation","domain long name(1)=" + domain_long_name.to_s)
        end
        #ConsoleLogger::log(C_CLASS_NAME,"question_annotation","domain long name(2)=" + domain_long_name.to_s)
        results << {
          :id => ModelUtility.extractCid(item), :namespace => ModelUtility.extractNs(item), 
          :domain_prefix => domain, :domain_long_name => domain_long_name, :sdtm_variable => variable, :sdtm_topic_variable => "", :sdtm_topic_value => ""
        }
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"question_annotation","results=" + results.to_json.to_s)
    return results
  end

end
