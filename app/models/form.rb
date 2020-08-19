# require 'odm'
class Form < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Form",
            uri_suffix: "F"

  data_property :note
  data_property :completion

  object_property :has_group, cardinality: :many, model_class: "Form::Group::Normal", children: true

  # Get Items. 
  #
  # @return [Array] Array of hashes, one per group, sub group and item. Ordered by ordinal.
  def get_items
    results = []
    form = self.class.find_full(self.uri)
    form.has_group.sort_by {|x| x.ordinal}.each do |group|
      results += group.get_item
    end
    return results
  end

  def to_crf
    form = self.class.find_full(self.uri)
    html = ""
    html += '<table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    html += '<td colspan="2"><h4>' + form.label + '</h4></td>'
    # if options[:annotate]
    #   html += '<td>' 
    #   domains = annotations.uniq {|entry| entry[:domain_prefix] }
    #   domains.each_with_index do |domain, index|
    #     domain_annotation = domain[:domain_prefix]
    #     if !domain[:domain_long_name].empty?
    #       domain_annotation += "=" + domain[:domain_long_name]
    #     end
    #     class_suffix = index < C_DOMAIN_CLASS_COUNT ? "#{index + 1}" : "other"
    #     class_name = "domain-#{class_suffix}"
    #     html += "<h4 class=\"#{class_name}\">#{domain_annotation}</h4>"
    #     domain[:class] = class_name
    #     @domain_map[domain[:domain_prefix]] = domain
    #   end
    #   html += '</td>'
    # else
    #   html += empty_cell
    # end
    html += '</tr>'
    form.has_group.sort_by {|x| x.ordinal}.each do |group|
      html += group.to_crf
    end
    html += '</table>'
    return html
  end


  # To XML (ODM)
  #
  # @return [object] The ODM XML object created.
  # def to_xml
  #   odm_document = Odm.new("ODM-#{self.id}", "Assero", "Glandon", Version::VERSION)
  #   odm = odm_document.root
  #   study = odm.add_study("S-#{self.id}")
  #   global_variables = study.add_global_variables()
  #   global_variables.add_study_name("Form Export #{self.label} (#{self.identifier})")
  #   global_variables.add_study_description("Not applicable. Single form export.")
  #   global_variables.add_protocol_name("Not applicable. Single form export.")
  #   metadata_version = study.add_metadata_version("MDV-#{self.id}", "Metadata for #{self.label}", "Not applicable. Single form export.")
  #   protocol = metadata_version.add_protocol()
  #   protocol.add_study_event_ref("SE-#{self.id}", "1", "Yes", "")
  #   study_event_def = metadata_version.add_study_event_def("SE-#{self.id}", "Not applicable. Single form export.", "No", "Scheduled", "")
  #   study_event_def.add_form_ref("#{self.id}", "1", "Yes", "")
  #   form_def = metadata_version.add_form_def("#{self.id}", "#{self.label}", "No")
  #   self.children.sort_by! {|u| u.ordinal}
  #   self.children.each do |child|
  #     child.to_xml(metadata_version, form_def)
  #   end
  #   return odm_document.to_xml
  # end

  # Get annotations for the form
  #
  # @return [Hash] Hash containing te annotations
#   def annotations
#     form = self.to_json
#     annotations = Array.new
#     annotations += bc_annotations
#     annotations += question_annotations
#     return annotations
#   end

private
  
  def start_row(optional)
    return '<tr class="warning">' if optional
    return '<tr>'
  end

  def end_row
    return "</tr>"
  end

#   def bc_annotations()
#     results = Array.new
#     #query = UriManagement.buildNs(self.namespace, ["bf", "bo", "cbc", "bd", "isoI", "iso25964"])  +
#     #  "SELECT ?item ?domain ?sdtmVarName ?sdtmTopicName ?sdtmTopicSub WHERE \n" +
#     #  "{ \n " +
#     #  "  ?topic_var bd:hasProperty ?op_ref3 . \n " +
#     #  "  ?op_ref3 bo:hasProperty ?bc_topic_property . \n " +
#     #  "  ?bcRoot (cbc:hasProperty|cbc:hasDatatype|cbc:hasItem|cbc:hasComplexDatatype)%2B ?bc_topic_property . \n " +
#     #  "  ?bc_topic_property cbc:hasThesaurusConcept ?valueRef . \n " +
#     #  "  ?valueRef bo:hasThesaurusConcept ?sdtmTopicValueObj . \n " +
#     #  "  ?sdtmTopicValueObj iso25964:notation ?sdtmTopicSub . \n " +
#     #  "  {\n " +
#     #  "    SELECT ?form ?group ?item ?bcProperty ?bcRoot ?bcIdent ?sdtmVarName ?domain ?sdtmTopicName ?topic_var WHERE \n " +
#     #  "    { \n " +
#     #  "      ?var bd:name ?sdtmVarName . \n " +
#     #  "      ?dataset bd:includesColumn ?var . \n " +
#     #  "      ?dataset bd:prefix ?domain . \n " +
#     #  "      ?dataset bd:includesColumn ?topic_var . \n " +
#     #  "      ?topic_var bd:classifiedAs ?classification . \n " +
#     #  "      ?classification rdfs:label \"Topic\"^^xsd:string . \n " +
#     #  "      ?topic_var bd:name ?sdtmTopicName . \n " +
#     #  "      { \n " +
#     #  "        SELECT ?group ?item ?bcProperty ?bcRoot ?bcIdent ?sdtmVarName ?dataset ?var ?gord ?pord WHERE \n " +
#     #  "        { \n " +
#     #  "          :" + self.id + " (bf:hasGroup|bf:hasSubGroup|bf:hasCommon)%2B ?group . \n " +
#     #  "          ?group bf:ordinal ?gord . \n " +
#     #  "          ?group (bf:hasItem|bf:hasCommonItem)%2B ?item . \n " +
#     #  "          ?item bf:hasProperty ?op_ref1 . \n " +
#     #  "          ?op_ref1 bo:hasProperty ?bcProperty  . \n " +
#     #  "          ?op_ref2 bo:hasProperty ?bcProperty . \n " +
#     #  "          ?var bd:hasProperty ?op_ref2 . \n " +
#     #  "          ?bcRoot (cbc:hasProperty|cbc:hasDatatype|cbc:hasItem|cbc:hasComplexDatatype)%2B ?bcProperty . \n" +
#     #  "          ?bcRoot rdf:type cbc:BiomedicalConceptInstance . \n " +
#     #  "          ?bcProperty cbc:ordinal ?pord . \n " +
#     #  "          ?bcRoot isoI:hasIdentifier ?si . \n " +
#     #  "          ?si isoI:identifier ?bcIdent . \n " +
#     #  "        }  \n " +
#     #  "      } \n " +
#     #  "    } \n " +
#     #  "  } \n " +
#     #  "} ORDER BY ?gord ?pord \n "

#     # New faster query
#     query = %Q(
#       #{query = UriManagement.buildNs(self.namespace, ["bf", "bo", "cbc", "bd", "isoT", "isoI", "th"])}
#       SELECT ?item ?domain ?sdtmVarName ?sdtmTopicName ?sdtmTopicSub WHERE
#       {
#         :#{self.id} (bf:hasGroup|bf:hasSubGroup|bf:hasCommon)%2B ?group .
#         ?group bf:ordinal ?gord .
#         ?group (bf:hasItem|bf:hasCommonItem)%2B ?item .
#         ?item bf:hasProperty ?op_ref1 .
#         ?op_ref1 bo:hasProperty ?bcProperty  .
#         ?op_ref2 bo:hasProperty ?bcProperty .
#         ?var bd:hasProperty ?op_ref2 .
#         ?bcRoot (cbc:hasProperty|cbc:hasDatatype|cbc:hasItem|cbc:hasComplexDatatype)%2B ?bcProperty .
#         ?bcRoot rdf:type cbc:BiomedicalConceptInstance .
#         ?bcProperty cbc:ordinal ?pord .
#         ?bcRoot isoT:hasIdentifier ?si .
#         ?si isoI:identifier ?bcIdent .
#         ?var bd:name ?sdtmVarName .
#         ?dataset bd:includesColumn ?var .
#         ?dataset rdf:type #{SdtmUserDomain::C_RDF_TYPE_URI.to_ref} .
#         ?dataset bd:prefix ?domain .
#         ?dataset bd:includesColumn ?topic_var .
#         ?topic_var bd:classifiedAs ?classification .
#         ?classification rdfs:label "Topic"^^xsd:string .
#         ?topic_var bd:name ?sdtmTopicName .
#         ?topic_var bd:hasProperty ?op_ref3 .
#         ?op_ref3 bo:hasProperty ?bc_topic_property .
#         ?bcRoot (cbc:hasProperty|cbc:hasDatatype|cbc:hasItem|cbc:hasComplexDatatype)%2B ?bc_topic_property .
#         ?bc_topic_property cbc:hasThesaurusConcept ?valueRef .
#         ?valueRef bo:hasThesaurusConcept ?sdtmTopicValueObj .
#         ?sdtmTopicValueObj th:notation ?sdtmTopicSub .
#       } ORDER BY ?domain ?sdtmVarName ?sdtmTopicName ?sdtmTopicSub
#     )
#     response = CRUD.query(query)
#     xmlDoc = Nokogiri::XML(response.body)
#     xmlDoc.remove_namespaces!
#     xmlDoc.xpath("//result").each do |node|
#       item = ModelUtility.getValue('item', true, node)
#       domain = ModelUtility.getValue('domain', false, node)
#       sdtm_var = ModelUtility.getValue('sdtmVarName', false, node)
#       sdtm_topic = ModelUtility.getValue('sdtmTopicName', false, node)
#       sdtm_topic_value = ModelUtility.getValue('sdtmTopicSub', false, node)
#       domain_long_name = ""
#       if item != ""
#         if @@domain_map.has_key?(domain)
#           domain_long_name = @@domain_map[domain]
#         end
#         results << {
#           :id => ModelUtility.extractCid(item), :namespace => ModelUtility.extractNs(item),
#           :domain_prefix => domain, :domain_long_name => domain_long_name, :sdtm_variable => sdtm_var, :sdtm_topic_variable => sdtm_topic, :sdtm_topic_value => sdtm_topic_value
#         }
#       end
#     end
#     return results
#   end

#   def question_annotations()
#     results = Array.new
#     query = UriManagement.buildNs(self.namespace, ["bf", "bo", "bd", "isoI"])  +
#       "SELECT DISTINCT ?var ?domain ?item WHERE \n" +
#       "{ \n" +
#       "  ?col bd:name ?var .  \n" +
#       "  ?dataset bd:includesColumn ?col . \n" +
#       "  ?dataset rdf:type #{SdtmUserDomain::C_RDF_TYPE_URI.to_ref} . \n" +
#       "  ?dataset bd:prefix ?domain . \n " +
#       #"  ?dataset rdfs:label ?domain . \n" +
#       "  { \n" +
#       "    SELECT ?group ?item ?var ?gord ?pord WHERE \n" +
#       "    { \n" +
#       "      :" + self.id + " (bf:hasGroup|bf:hasSubGroup)%2B ?group . \n" +
#       "      ?group bf:ordinal ?gord . \n" +
#       "      ?group (bf:hasItem)+ ?item . \n" +
#       "      ?item bf:mapping ?var . \n" +
#       "      ?item bf:ordinal ?pord \n" +
#       "    } \n" +
#       "  } \n" +
#       "} ORDER BY ?domain ?var \n"
#     # Send the request, wait the resonse
#     response = CRUD.query(query)
#     # Process the response
#     xmlDoc = Nokogiri::XML(response.body)
#     xmlDoc.remove_namespaces!
#     xmlDoc.xpath("//result").each do |node|
#       ConsoleLogger::log(C_CLASS_NAME,"question_annotations", "node=" + node.to_json.to_s)
#       item = ModelUtility.getValue('item', true, node)
#       variable = ModelUtility.getValue('var', false, node)
#       domain = ModelUtility.getValue('domain', false, node)
#       domain_long_name = ""
#       if item != ""
#         if @@domain_map.has_key?(domain)
#           domain_long_name = @@domain_map[domain]
#         end
#         results << {
#           :id => ModelUtility.extractCid(item), :namespace => ModelUtility.extractNs(item),
#           :domain_prefix => domain, :domain_long_name => domain_long_name, :sdtm_variable => variable, :sdtm_topic_variable => "", :sdtm_topic_value => ""
#         }
#       end
#     end
#     return results
#   end

end
