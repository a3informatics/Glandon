# CDISC Library API Reader Engine.
#
# @author Dave Iberson-Hurst
# @since 2.27.0
# @attr_reader [Hash] parent_set set of parent items created
# @attr_reader [Tags] classification the classifications found
class CDISCLibraryAPIReader::Engine

  extend ActiveModel::Naming

  attr_reader :parent_set, :tags

  # Initialize. Opens the workbook ready for processing.
  #
  # @param [Object] owner the owning object
  # @return [Void] no return value
  def initialize(owner)
    @owner = owner
    @errors = owner.errors
    @parent_set = {}
    @tags = []
    @api = CDISCLibraryAPI.new
    @classifications = {}
  end

  # Process. Process the api response.
  #
  # @param [String] href partial href to be read and processed
  # @return [Void] no return
  def process(href)
    response = read(href)
    response[:codelists].each do |parent|
      processed_parent = add_parent(parent)
      @parent_set[processed_parent.identifier] = processed_parent
    end
  end

private
  
  # Add code list, the parent
  def add_parent(parent)
    parent[:synonyms] = [] if !parent.key?(:synonyms)
    tc = CdiscCl.new(identifier: parent[:conceptId], label: parent[:name], notation: parent[:submissionValue], 
      definition: parent[:definition], extensible: parent[:extensible].to_bool)
    tc.has_identifier = IsoScopedIdentifierV2.new
    tc.has_identifier.identifier = tc.identifier # Set to the same value
    create_definition(tc, :preferred_term, parent[:preferredTerm])
    parent[:synonyms].each do |synonym|
      create_definition(tc, :synonym, synonym)
    end
    tc.tagged = @tags
    add_children(tc, parent[:terms])
    tc
  end

  # Add children to the parent
  def add_children(parent, children)
    children.each do |child|
      parent.narrower << add_child(parent, child)
    end
  end
      
  # Add a child to teh parent
  def add_child(parent, child)
    child[:synonyms] = [] if !child.key?(:synonyms)
    tc = CdiscCli.new(identifier: child[:conceptId], label: child[:preferredTerm], notation: child[:submissionValue], 
      definition: child[:definition], extensible: false)
    create_definition(tc, :preferred_term, child[:preferredTerm])
    child[:synonyms].each do |synonym|
      create_definition(tc, :synonym, synonym)
    end
    tc.tagged = @tags
    tc
  end

  # Create Definition, either a preferred term or synonym
  def create_definition(parent, property_name, label)
    return if label.blank?
    return if duplicate_label?(parent, property_name, label)
    property = parent.properties.property(property_name.to_sym)
    klass = property.klass
    results = klass.where(label: label)
    object = results.any? ? results.first : object_create(klass, label)
    property.set(object)
  end

  # Check for a duplicate label.
  def duplicate_label?(parent, property, label)
    collection = parent.send(property)
    return false if collection.nil?
    return false if !collection.is_a?(Array)
    !collection.detect{|x| x.label == label}.nil?
  end

    # Find or build an object and set label
  def object_create(klass, value)
    return nil if value.blank?
    @classifications[klass.name] = {} if !@classifications.key?(klass.name)
    return @classifications[klass.name][value] if @classifications[klass.name].key?(value)
    item = klass.new
    item.label = value
    @classifications[klass.name][value] = item
    return item
  end

  # Read the API, get the response
  def read(href)
    response = @api.ct_package(href)
    set_tags(response[:label])
    response
  end 

  # Set the tags.
  def set_tags(title)
    @tags = []
    tags = @api.ct_tags(title)
    return if tags.empty?
    tags.each do |tag|
      @tags << IsoConceptSystem.path(["CDISC"] + [tag])
    end
  end

end    