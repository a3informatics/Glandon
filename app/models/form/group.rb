class Form::Group < IsoConcept
  
  attr_accessor :children, :ordinal, :note, :optional, :completion
  
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Group"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "Group"
  C_CID_SUFFIX = "G"
  
  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.ordinal = 1
    self.note = ""
    self.optional = false
    self.completion = ""
    self.children = Array.new
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)    
    end
  end

  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:ordinal] = self.ordinal
    json[:optional] = self.optional
    json[:completion] = self.completion
    json[:note] = self.note
    json[:children] = Array.new
    self.children.sort_by! {|u| u.ordinal}
    self.children.each do |item|
      json[:children] << item.to_json
    end
    return json
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.ordinal = json[:ordinal]
    object.optional = json[:optional]
    object.completion = json[:completion]
    object.note = json[:note]
    if !json[:children].blank?
      json[:children].each do |child|
        if child[:type] == Form::Item::Placeholder::C_RDF_TYPE_URI.to_s
          object.children << Form::Item::Placeholder.from_json(child)
        elsif child[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s
          object.children << Form::Item::TextLabel.from_json(child)
        elsif child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
          object.children << Form::Item::Question.from_json(child)
        elsif child[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
          object.children << Form::Item::Mapping.from_json(child)
        elsif child[:type] == Form::Item::BcProperty::C_RDF_TYPE_URI.to_s
          object.children << Form::Item::BcProperty.from_json(child)
        end   
      end
    end
    return object
  end

  # To SPARQL
  #
  # @param parent_uri [object] URI object
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2(parent_uri, sparql)
    self.namespace = parent_uri.namespace
    self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{C_CID_SUFFIX}#{self.ordinal}"
    uri = super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "ordinal"}, {:literal => "#{self.ordinal}", :primitive_type => "positiveInteger"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "optional"}, {:literal => "#{self.optional}", :primitive_type => "boolean"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "note"}, {:literal => "#{self.note}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "completion"}, {:literal => "#{self.completion}", :primitive_type => "string"})
    self.children.each do |item|
      ref_uri = item.to_sparql_v2(uri, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasItem"}, {:uri => ref_uri})
    end
    ConsoleLogger::log(C_CLASS_NAME, "to_sparql_v2", "URI=#{self.uri}.")
    return uri
  end

  # To XML
  #
  # @param metadata_version [object] 
  # @param form_def [object] 
  # @param item_group_def [object]
  def to_xml(metadata_version, form_def)
    form_def.add_item_group_ref("#{self.id}", "#{self.ordinal}", "No", "")
    item_group_def = metadata_version.add_item_group_def("#{self.id}", "#{self.label}", "No", "", "", "", "", "", "")
    self.children.each do |item|
      item.to_xml(metadata_version, form_def, item_group_def)
    end
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    result = super
    result = result &&
      FieldValidation::valid_markdown?(:completion, self.completion, self) &&
      FieldValidation::valid_markdown?(:note, self.note, self)
    return result
  end

private

  def self.children_from_triples(object, triples, id)
    links = object.get_links_v2("bf", "hasItem")
    links.each do |link|
      rdf_type = object.get_link_object_type_v2(link)
      if rdf_type == Form::Item::Placeholder::C_RDF_TYPE_URI.to_s
        object.children += Form::Item::Placeholder.find_for_parent(triples, [link])
      elsif rdf_type == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s
        object.children += Form::Item::TextLabel.find_for_parent(triples, [link])
      elsif rdf_type == Form::Item::Question::C_RDF_TYPE_URI.to_s
        object.children += Form::Item::Question.find_for_parent(triples, [link])
      elsif rdf_type == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
        object.children += Form::Item::Mapping.find_for_parent(triples, [link])
      elsif rdf_type == Form::Item::BcProperty::C_RDF_TYPE_URI.to_s
        object.children += Form::Item::BcProperty.find_for_parent(triples, [link])
      end  
    end
  end

end
