require "uri"

class BiomedicalConceptCore < IsoManaged
  
  attr_accessor :items
  
  C_SCHEMA_PREFIX = "cbc"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_CLASS_NAME = "BiomedicalConceptCore"

  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.items = Array.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  # Find the object
  #
  # @param id [string] The id of the item to be found
  # @param ns [string] The namespace of the item to be found
  # @param children [boolean] Find children object, defaults to true.
  # @return [object] The new object
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      object.items = BiomedicalConceptCore::Item.find_for_parent(object.triples, object.get_links(C_SCHEMA_PREFIX, "hasItem"))
    end
    return object 
  end

  # Find all BCTs.
  #
  # @return [array] Array of objects found.
  def self.all(type, ns)
    super(type, ns)
  end

  def self.unique(type, ns)
    results = super(type, ns)
    return results
  end

  def self.list(type, ns)
    results = super(type, ns)
    return results
  end

  def self.history(type, ns, params)
    results = super(type, ns, params)
    return results
  end

  def destroy
    super(self.namespace)
  end

  # Get Properties
  #
  # @return [array] Array of leaf (property) JSON structures
  def get_properties
    results = Array.new
    self.items.each do |item|
      results += item.get_properties
    end
    managed_item = self.to_json
    managed_item[:children] = []
    managed_item[:children] = results
    return managed_item
  end

  # Set Properties
  #
  # param json [hash] The properties
  def set_properties(json)
    if !json[:children].blank?
      self.items.each do |item|
        item.set_properties(json[:children])
      end
    end
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    if !json[:children].blank?
      json[:children].each do |child|
        object.items << BiomedicalConceptCore::Item.from_json(child)
      end
    end
    return object
  end
  
  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:children] = Array.new
    self.items.each do |item|
      json[:children] << item.to_json
    end 
    json[:children] = json[:children].sort_by {|item| item[:ordinal]}
    return json
  end
  
  # To SPARQL
  #
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2(sparql)
    subject = {:uri => self.uri}
    self.items.each do |item|
      ref_uri = item.to_sparql(uri, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasItem"}, { :uri => uri })
    end
    return uri
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    self.errors.clear
    result = super
    ConsoleLogger::log(C_CLASS_NAME,"valid?","result=#{result}")
    self.items.each do |item|
      if !item.valid?
        self.copy_errors(item, "Item error:")
        result = false
      end
    end
    ConsoleLogger::log(C_CLASS_NAME,"valid?","result=#{result}")
    return result
  end

end
