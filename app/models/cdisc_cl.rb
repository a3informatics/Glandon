require "diffy"

class CdiscCl < ThesaurusConcept
  
  attr_accessor :extensible
  
  # Constants
  C_CLASS_PREFIX = "THC"
  C_SCHEMA_PREFIX = "iso25964"
  C_INSTANCE_PREFIX = "mdrTh"
  C_CLASS_NAME = "CdiscCl"
  C_RDF_TYPE = "ThesaurusConcept"

  # Base namespace 
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  # Initialize the object
  #
  # @param triples [hash] The raw triples keyed by id
  # @param id [string] The id of the form
  # @return [object] The form object
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
      self.extensible = false
    else
      super(triples, id)
    end
  end

  # Find a given code list
  #
  # @param id [string] The id of the form.
  # @param namespace [hash] The raw triples keyed by id.
  # @param children [boolean] Find all child objects. Defaults to true.
  # @return [object] The CDISC CL object.
  def self.find(id, ns, children=true)
    object = super(id, ns, children)
    object.extensible = object.get_extension_value("extensible")
    return object
  rescue Exceptions::NotFoundError => e
    return nil
  end

  # Find From Triples
  #
  # @param triples [hash] The triples hash.
  # @param id [string] The cid for the object to the found.
  # @return [object] The CDISC CL object.
  def self.find_from_triples(triples, id)
    object = new(triples, id)
    object.extensible = object.get_extension_value("extensible")
    object.triples = ""
    return object
  end

  # Different? Are two code lists different
  #
  # @previous [Object] The previous object being compared
  # @current [Object] The current object being compared
  # @return [boolean] True if different, false otherwise.
  def self.diff?(previous, current)
    return true if super(previous, current)
    return true if !current.child_match?(previous, "children", "identifier")
    current_index = Hash[current.children.map{|x| [x.identifier, x]}]
    previous_index = Hash[previous.children.map{|x| [x.identifier, x]}]
    current.children.each do |current|
      return true if self.diff?(previous_index[current.identifier], current)
    end
    return false
  end
  
  # Differences between this and another code list. Details for the code lists
  # and a staus on the children.
  #
  # @previous [Object] The previous object being compared
  # @current [Object] The current object being compared
  # @return [Hash] The differenc hash
  def self.difference(previous, current)
    results = super(previous, current)
    children = {}
    if previous.nil? && current.nil?
      children = {}
    elsif previous.nil?
      current.children.each do |child|
        children[child.identifier.to_sym] = { status: :created, preferred_term: child.preferredTerm, notation: child.notation, id: child.id, namespace: child.namespace}
      end
    elsif current.nil?
      previous.children.each do |child|
        children[child.identifier.to_sym] = { status: :deleted, preferred_term: child.preferredTerm, notation: child.notation, id: child.id, namespace: child.namespace}
      end
    else
      deleted = current.deleted_set(previous, "children", "identifier" )
      current_index = Hash[current.children.map{|x| [x.identifier, x]}]
      previous_index = Hash[previous.children.map{|x| [x.identifier, x]}]
      current.children.each do |current|
        diff = self.diff?(previous_index[current.identifier], current) 
        if diff && previous_index[current.identifier].nil? 
          status = :created
        elsif diff
          status = :updated
        else
          status = :no_change
        end
        children[current.identifier.to_sym] = { status: status, preferred_term: current.preferredTerm, notation: current.notation, id: current.id, namespace: current.namespace}
      end
      deleted.each do |deleted|
        item = previous_index[deleted]
        children[deleted.to_sym] = { status: :deleted, preferred_term: item.preferredTerm, notation: item.notation, id: item.id, namespace: item.namespace}
      end
    end
    results[:children] = children
    return results
  end

end
