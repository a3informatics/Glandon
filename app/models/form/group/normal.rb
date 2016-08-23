class Form::Group::Normal < Form::Group
  
  attr_accessor :repeating, :groups, :bc_ref
  
  # Constants
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Group::Normal"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "NormalGroup"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  def initialize(triples=nil, id=nil)
    self.groups = Array.new
    self.bc_ref = nil
    self.repeating = false
    if triples.nil?
      super
      # Set the type. Overwrite default.
      self.rdf_type = C_RDF_TYPE_URI.to_s
    else
      super(triples, id)    
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    children_from_triples(object, triples, id)
    return object
  end

  def to_json
    json = super
    json[:repeating] = self.repeating
    if self.bc_ref != nil
      json[:bc_ref] = self.bc_ref.to_json
    else
      json[:bc_ref] = {}
    end
    self.groups.sort_by! {|u| u.ordinal}
    self.groups.each do |group|
      json[:children] << group.to_json
    end
    return json
  end

  def self.from_json(json)
    object = super(json)
    object.repeating = json[:repeating]
    if json.has_key?(:bc_ref)
      ref = json[:bc_ref]
      if !ref.empty?
        object.bc_ref = OperationalReferenceV2.from_json(json[:bc_ref])
      end
    end
    if !json[:children].blank?
      json[:children].each do |child|
        if child[:type] == Form::Group::Normal::C_RDF_TYPE_URI.to_s
          object.groups << Form::Group::Normal.from_json(child)
        elsif child[:type] == Form::Group::Common::C_RDF_TYPE_URI.to_s
          object.groups << Form::Group::Common.from_json(child)
        end   
      end
    end
    return object
  end

  def to_sparql(parent_id, sparql)
    super(parent_id, sparql)
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "repeating", "#{self.repeating}", "boolean")
    sparql.triple("", id, C_SCHEMA_PREFIX, "isGroupOf", "", "#{parent_id}")
    if !self.bc_ref.nil? 
      ref_id = self.bc_ref.to_sparql(id, "hasBiomedicalConcept", 'BCR', 1, sparql)
      sparql.triple("", self.id, C_SCHEMA_PREFIX, "hasBiomedicalConcept", "", "#{ref_id}")
    end
    self.groups.each do |child|
      if child.rdf_type == Form::Group::Common::C_RDF_TYPE_URI.to_s
        ref_id = child.to_sparql(self.id, sparql)
        sparql.triple("", self.id, C_SCHEMA_PREFIX, "hasCommon", "", ref_id)
      else
        ref_id = child.to_sparql(self.id, sparql)
        sparql.triple("", self.id, C_SCHEMA_PREFIX, "hasSubGroup", "", ref_id)
      end    
    end
    return self.id
  end

  def to_xml(metadata_version, form_def)
    ConsoleLogger::log(C_CLASS_NAME,"to_xml","Entry")
    if self.groups.length > 0
      self.groups.each do |group|
        ConsoleLogger::log(C_CLASS_NAME,"to_xml","Group=#{group.to_json}")
        group.to_xml(metadata_version, form_def)
      end
    else      
      super(metadata_version, form_def)
    end
  end

private

  def self.children_from_triples(object, triples, id)
    super(object, triples, id)
    # Subgroups first
    object.groups = Form::Group::Normal.find_for_parent(triples, object.get_links("bf", "hasSubGroup"))
    common_groups = Form::Group::Common.find_for_parent(triples, object.get_links("bf", "hasCommon"))
    object.groups += common_groups
    # BC if we have one
    bc_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "hasBiomedicalConcept"))
    if bc_refs.length > 0
      object.bc_ref = bc_refs[0]
    end
  end

end
