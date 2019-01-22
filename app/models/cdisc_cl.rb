# CDISC Code List
#
# @attribute [Boolean] extensible the code list extensibel flag
# @author Dave Iberson-Hurst
# @since 0.0.1
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
    #current_index = Hash[current.children.map{|x| [x.identifier, x]}]
    previous_index = Hash[previous.children.map{|x| [x.identifier, x]}]
    current.children.each do |current|
      return true if CdiscCli.diff?(previous_index[current.identifier], current)
    end
    return false
  end
  
  # Different? Are two code lists different. New version.
  #
  # @previous [Object] The previous object being compared
  # @current [Object] The current object being compared
  # @return [boolean] True if different, false otherwise.
  def self.new_diff?(previous, current)
    return true if ThesaurusConcept.diff?(previous, current)
    previous_identifiers = self.child_identifiers(previous)
    current_identifiers = self.child_identifiers(current)
    return true if current_identifiers - previous_identifiers != [] || previous_identifiers - current_identifiers != []
    query = UriManagement.buildPrefix("", ["iso25964"]) +
      "SELECT DISTINCT ?cli1 ?cli2 WHERE \n" +
      "  {\n" +
      "    ?cl1 iso25964:hasChild ?cli1 . \n" +
      "    ?cl1 iso25964:identifier \"#{current.identifier}\" . \n" +
      "    ?cl1 iso25964:identifier ?id . \n" +
      "    FILTER(STRSTARTS(STR(?cl1), \"#{previous.namespace}\")) . \n" + 
      "    ?cl2 iso25964:identifier ?id . \n" +
      "    ?cl2 iso25964:hasChild ?cli2 . \n" +   
      "    FILTER(STRSTARTS(STR(?cl2), \"#{current.namespace}\")) . \n" +  
      "    ?cli1 iso25964:identifier ?id1 . \n" +   
      "    ?cli1 iso25964:notation ?n1 . \n" +   
      "    ?cli1 iso25964:preferredTerm ?pt1 . \n" +   
      "    ?cli1 iso25964:definition ?d1 . \n" +   
      "    ?cli1 iso25964:synonym ?s1 . \n" +   
      "    ?cli2 iso25964:identifier ?id1 . \n" +   
      "    ?cli2 iso25964:notation ?n2 . \n" +   
      "    ?cli2 iso25964:preferredTerm ?pt2 . \n" +   
      "    ?cli2 iso25964:definition ?d2 . \n" +   
      "    ?cli2 iso25964:synonym ?s2 . \n" +   
      "    FILTER(?n1 != ?n2 || ?pt1 != ?pt2 || ?d1 != ?d2 || ?s1 != ?s2) . \n" +   
      "  }"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    return true if xmlDoc.xpath("//result").count > 0
    return false
  end
  
  # Child Identifiers. Get list of child identifiers.
  #
  # @param cl [String] the code list
  # @return [array] Array of identifiers
  def self.child_identifiers(cl)
    results = Array.new
    query = UriManagement.buildPrefix("", ["iso25964"]) +
      "SELECT ?id WHERE \n" +
      "{ \n" +
      "  ?cl iso25964:identifier \"#{cl.identifier}\" . \n" +
      "  FILTER(STRSTARTS(STR(?cl), \"#{cl.namespace}\")) . \n" + 
      "  ?cl iso25964:hasChild ?cli . \n" +   
      "  ?cli iso25964:identifier ?id . \n" +   
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      results << ModelUtility.getValue('id', false, node)
    end
    return results
  end

  # Find child. Based on a parent and child identifier find the equivalent item in another namespace
  #
  # @param [String] parent_identifier the parent identifier
  # @param [String] child_identifier the child identifier
  # @param [String] namespace the mamespace
  # @return [CdiscCl] the object found or nil
  def self.find_child(parent_identifier, child_identifier, namespace)
    results = []
    query = UriManagement.buildPrefix("", ["iso25964"]) +
      "SELECT ?cli WHERE \n" +
      "{ \n" +
      "  ?cl iso25964:identifier \"#{parent_identifier}\" . \n" +
      "  FILTER(STRSTARTS(STR(?cl), \"#{namespace}\")) . \n" + 
      "  ?cl iso25964:hasChild ?cli . \n" +   
      "  ?cli iso25964:identifier \"#{child_identifier}\" . \n" +   
      "}"
    query_and_result(query).each {|node| results << ModelUtility.getValue('cli', true, node)}
    return nil if results.empty?
    uri = UriV3.new(uri: results.first)
    return CdiscCli.find(uri.fragment, uri.namespace)
  end

  # Find by identifier
  #
  # @param [String] identifier the required identifier
  # @param [String] namespace the mamespace
  # @return [CdiscCl] the object found or nil
  def self.find_by_identifier(identifier, namespace)
    results = []
    query = UriManagement.buildPrefix("", ["iso25964"]) +
      "SELECT ?cl WHERE \n" +
      "{ \n" +
      "  ?cl iso25964:identifier \"#{identifier}\" . \n" +
      "  FILTER(STRSTARTS(STR(?cl), \"#{namespace}\")) . \n" + 
      "  ?cl iso25964:hasChild ?cli . \n" +   
      "}"
    query_and_result(query).each {|node| results << ModelUtility.getValue('cl', true, node)}
    return nil if results.empty?
    uri = UriV3.new(uri: results.first)
    return CdiscCl.find(uri.fragment, uri.namespace)
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
        children[CdiscTermUtility.cli_key(current.identifier, child.identifier)] = { status: :created, identifier: child.identifier, preferred_term: child.preferredTerm, notation: child.notation, id: child.id, namespace: child.namespace}
      end
    elsif current.nil?
      previous.children.each do |child|
        children[CdiscTermUtility.cli_key(previous.identifier, child.identifier)] = { status: :deleted, identifier: child.identifier, preferred_term: child.preferredTerm, notation: child.notation, id: child.id, namespace: child.namespace}
      end
    else
      deleted = current.deleted_set(previous, "children", "identifier" )
      current_index = Hash[current.children.map{|x| [x.identifier, x]}]
      previous_index = Hash[previous.children.map{|x| [x.identifier, x]}]
      current.children.each do |child|
        diff = self.diff?(previous_index[child.identifier], child) 
        if diff && previous_index[child.identifier].nil? 
          status = :created
        elsif diff
          status = :updated
        else
          status = :no_change
        end
        children[CdiscTermUtility.cli_key(current.identifier, child.identifier)] = { status: status, identifier: child.identifier, preferred_term: child.preferredTerm, notation: child.notation, id: child.id, namespace: child.namespace}
      end
      deleted.each do |deleted|
        item = previous_index[deleted]
        children[CdiscTermUtility.cli_key(previous.identifier, deleted)] = { status: :deleted, identifier: item.identifier, preferred_term: item.preferredTerm, notation: item.notation, id: item.id, namespace: item.namespace}
      end
    end
    results[:children] = children
    return results
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:extensible] = self.extensible
    return json
  end

  alias :to_hash :to_json

  # From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [CdiscCli] the object
  def self.from_json(json)
    object = super(json)
    object.extensible = json[:extensible].to_bool
    return object
  end

  class << self
    alias :from_hash :from_json
  end

  # To SPARQL
  #
  # @return [object] The SPARQL object created.
  def to_sparql_v2(parent_uri, sparql)
    super(parent_uri, sparql)
    subject = {:uri => self.uri}
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "extensible"}, {:literal => "#{self.extensible}", :primitive_type => "boolean"})
    return self.uri
  end

end
