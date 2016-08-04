class Form::Group < IsoConcept
  
  attr_accessor :items, :ordinal, :note, :optional, :completion
  
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Group"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "Group"
  C_CID_SUFFIX = "G"
  
  def initialize(triples=nil, id=nil)
    self.ordinal = 1
    self.note = ""
    self.optional = false
    self.completion = ""
    self.items = Array.new
    if triples.nil?
      super
      # Set the type. Overwrite default.
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)    
    end
  end

  def to_json
    json = super
    json[:ordinal] = self.ordinal
    json[:optional] = self.optional
    json[:completion] = self.completion
    json[:note] = self.note
    json[:children] = Array.new
    self.items.sort_by! {|u| u.ordinal}
    self.items.each do |item|
      json[:children] << item.to_json
    end
    return json
  end

  def self.from_json(json)
    object = super(json)
    object.ordinal = json[:ordinal]
    object.optional = json[:optional]
    object.completion = json[:completion]
    object.note = json[:note]
    if !json[:children].blank?
      json[:children].each do |child|
        if child[:type] == Form::Item::Placeholder::C_RDF_TYPE_URI.to_s
          object.items << Form::Item::Placeholder.from_json(child)
        elsif child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
          object.items << Form::Item::Question.from_json(child)
        elsif child[:type] == Form::Item::BcProperty::C_RDF_TYPE_URI.to_s
          object.items << Form::Item::BcProperty.from_json(child)
        end   
      end
    end
    return object
  end

  def to_sparql(parent_id, sparql)
    self.id = "#{parent_id}#{Uri::C_UID_SECTION_SEPARATOR}#{C_CID_SUFFIX}#{self.ordinal}"
    super(sparql, C_SCHEMA_PREFIX)
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "ordinal", "#{self.ordinal}", "positiveInteger")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "optional", "#{self.optional}", "boolean")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "note", "#{self.note}", "string")
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "completion", "#{self.completion}", "string")
    sparql.triple("", id, C_SCHEMA_PREFIX, "isGroupOf", "", "#{parent_id}")
    self.items.each do |item|
      ref_id = item.to_sparql(id, sparql)
      sparql.triple("", self.id, C_SCHEMA_PREFIX, "hasItem", "", "#{ref_id}")
    end
    return self.id
  end

private

  def self.children_from_triples(object, triples, id)
    links = object.get_links_v2("bf", "hasItem")
    links.each do |link|
      rdf_type = object.get_link_object_type_v2(link)
      if rdf_type == Form::Item::Placeholder::C_RDF_TYPE_URI.to_s
        object.items += Form::Item::Placeholder.find_for_parent(triples, [link.to_s])
      elsif rdf_type == Form::Item::Question::C_RDF_TYPE_URI.to_s
        object.items += Form::Item::Question.find_for_parent(triples, [link.to_s])
      elsif rdf_type == Form::Item::BcProperty::C_RDF_TYPE_URI.to_s
        object.items += Form::Item::BcProperty.find_for_parent(triples, [link.to_s])
      end  
    end
  end

end
