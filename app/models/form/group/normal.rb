class Form::Group::Normal < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#NormalGroup",
            uri_suffix: "NG",
            uri_property: :ordinal

  data_property :repeating

  object_property :has_common, cardinality: :many, model_class: "Form::Group::Common"
  object_property :has_sub_group, cardinality: :many, model_class: "Form::Group::Normal"
  object_property :has_biomedical_concept, cardinality: :many, model_class: "OperationalReferenceV3"


  validates_with Validator::Field, attribute: :repeating, method: :valid_boolean?


  
  # attr_accessor :repeating, :groups, :bc_ref
  
  # # Constants
  # # Constants
  # C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  # C_CLASS_NAME = "Form::Group::Normal"
  # C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  # C_RDF_TYPE = "NormalGroup"
  # C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # # Initialize
  # #
  # # @param triples [hash] The raw triples keyed by subject
  # # @param id [string] The identifier for the concept being built from the triples
  # # @return [object] The new object
  # def initialize(triples=nil, id=nil)
  #   self.groups = Array.new
  #   self.bc_ref = nil
  #   self.repeating = false
  #   if triples.nil?
  #     super
  #     self.rdf_type = C_RDF_TYPE_URI.to_s
  #   else
  #     super(triples, id)    
  #   end
  # end

  # # Find the object
  # #
  # # @param id [string] The id of the item to be found
  # # @param ns [string] The namespace of the item to be found
  # # @return [object] The new object
  # def self.find(id, ns, children=true)
  #   object = super(id, ns)
  #   if children
  #     children_from_triples(object, object.triples, id)
  #   end
  #   return object
  # end

  # # Find an object from triples
  # #
  # # @param triples [hash] The raw triples keyed by subject
  # # @param id [string] The id of the item to be found
  # # @return [object] The new object
  # def self.find_from_triples(triples, id)
  #   object = new(triples, id)
  #   children_from_triples(object, triples, id)
  #   return object
  # end

  # # To JSON
  # #
  # # @return [hash] The object hash 
  # def to_json
  #   json = super
  #   json[:repeating] = self.repeating
  #   json[:bc_ref] = self.bc_ref.nil? ? {} : self.bc_ref.to_json
  #   self.groups.sort_by! {|u| u.ordinal}
  #   self.groups.each do |group|
  #     json[:children] << group.to_json
  #   end
  #   json[:children] = json[:children].sort_by { |k| k[:ordinal] }
  #   return json
  # end

  # # From JSON
  # #
  # # @param json [hash] The hash of values for the object 
  # # @return [object] The object
  # def self.from_json(json)
  #   object = super(json)
  #   object.repeating = json[:repeating]
  #   if json.has_key?(:bc_ref)
  #     ref = json[:bc_ref]
  #     if !ref.empty?
  #       object.bc_ref = OperationalReferenceV2.from_json(json[:bc_ref])
  #     end
  #   end
  #   if !json[:children].blank?
  #     json[:children].each do |child|
  #       if child[:type] == Form::Group::Normal::C_RDF_TYPE_URI.to_s
  #         object.groups << Form::Group::Normal.from_json(child)
  #       elsif child[:type] == Form::Group::Common::C_RDF_TYPE_URI.to_s
  #         object.groups << Form::Group::Common.from_json(child)
  #       end   
  #     end
  #   end
  #   return object
  # end

  # # To SPARQL
  # #
  # # @param parent_uri [object] URI object
  # # @param sparql [object] The SPARQL object
  # # @return [object] The URI
  # def to_sparql_v2(parent_uri, sparql)
  #   uri = super(parent_uri, sparql)
  #   subject = {:uri => uri}
  #   sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "repeating"}, {:literal => "#{self.repeating}", :primitive_type => "boolean"})
  #   if !self.bc_ref.nil? 
  #     ref_uri = self.bc_ref.to_sparql_v2(uri, "hasBiomedicalConcept", 'BCR', 1, sparql)
  #     sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasBiomedicalConcept"}, {:uri => ref_uri})
  #   end
  #   self.groups.sort_by! {|u| u.ordinal}
  #   self.groups.each do |child|
  #     if child.rdf_type == Form::Group::Common::C_RDF_TYPE_URI.to_s
  #       ref_uri = child.to_sparql_v2(uri, sparql)
  #       sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id =>  "hasCommon"}, {:uri => ref_uri})
  #     else
  #       ref_uri = child.to_sparql_v2(uri, sparql)
  #       sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id =>  "hasSubGroup"}, {:uri => ref_uri})
  #     end    
  #   end
  #   return uri
  # end

  # To XML
  #
  # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
  # @param [Nokogiri::Node] form_def the ODM FormDef node
  # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
  # @return [void]
  # def to_xml(metadata_version, form_def)
  #   if self.groups.length > 0
  #     self.groups.sort_by! {|u| u.ordinal}
  #     self.groups.each { |group| group.to_xml(metadata_version, form_def) }
  #   end      
  #   super(metadata_version, form_def)
  # end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
#   def valid?
#     result = super
#     self.groups.each do |group|
#       if !group.valid?
#         self.copy_errors(group, "Group, ordinal=#{group.ordinal}, error:")
#         result = false
#       end
#     end
#     result = result &&
#       FieldValidation::valid_boolean?(:repeating, self.repeating, self)
#     return result
#   end

# private

#   def self.children_from_triples(object, triples, id)
#     super(object, triples, id)
#     # Subgroups first
#     object.groups = Form::Group::Normal.find_for_parent(triples, object.get_links("bf", "hasSubGroup"))
#     common_groups = Form::Group::Common.find_for_parent(triples, object.get_links("bf", "hasCommon"))
#     object.groups += common_groups
#     # BC if we have one
#     bc_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "hasBiomedicalConcept"))
#     if bc_refs.length > 0
#       object.bc_ref = bc_refs[0]
#     end
#   end

end
