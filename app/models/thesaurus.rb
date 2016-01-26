require "nokogiri"
require "uri"

class Thesaurus < IsoManaged

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :children
  validates_presence_of :children
 
  # Constants
  C_CLASS_NAME = "Thesaurus"
  C_CID_PREFIX = "TH"
  C_SCHEMA_PREFIX = "iso25964"
  C_INSTANCE_PREFIX = "mdrTh"
  C_RDF_TYPE = "Thesaurus"

  # Base namespace 
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def self.find(id, ns, children=true)   
    object = super(id, ns)
    if children
      object.children = ThesaurusConcept.allTopLevel(id, ns)
    end
    return object    
  end
  
  def self.all
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.unique
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(identifier)
    results = super(C_RDF_TYPE, identifier, C_SCHEMA_NS)
    return results
  end

  def self.create(params)
    object = super(C_CID_PREFIX, params, 'Thesaurus', C_SCHEMA_NS, C_INSTANCE_NS)
    return object
  end

  def self.import(params, ownerNamespace)
    object = super(C_CID_PREFIX, params, ownerNamespace, 'Thesaurus', C_SCHEMA_NS, C_INSTANCE_NS)
    return object
  end

  def self.count(searchTerm, ns)
    count = 0
    if searchTerm == ""
      query = UriManagement.buildNs(ns, ["iso25964"]) +
        "SELECT DISTINCT (COUNT(?b) as ?total) WHERE \n" +
        "  {\n" +
        "    ?a iso25964:identifier ?b . \n" +
        "    FILTER(STRSTARTS(STR(?a), \"" + ns + "\"))" +
        "  }"
      response = CRUD.query(query)
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      xmlDoc.xpath("//result").each do |node|
        countSet = node.xpath("binding[@name='total']/literal")
        count = countSet[0].text.to_i
      end
    else
      query = UriManagement.buildNs(ns, ["iso25964"]) + queryString(searchTerm, ns) 
      response = CRUD.query(query)
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      count = xmlDoc.xpath("//result").length
    end
    return count
  end

  def self.search(offset, limit, col, dir, searchTerm, ns)
    results = Array.new
    variable = getOrderVariable(col)
    order = getOrdering(dir)
    query = UriManagement.buildNs(ns, ["iso25964"]) + 
      queryString(searchTerm, ns) + 
      " ORDER BY " + order + "(" + variable + ") OFFSET " + offset.to_s + " LIMIT " + limit.to_s
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      processNode(node, results)
    end
    return results
  end
  
  def update(params)
    ConsoleLogger::log(C_CLASS_NAME,"update","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"update","Params=" + params.to_s)
    self.errors.clear
    
    # Access the data
    data = params[:data]
    if data != nil
      ConsoleLogger::log(C_CLASS_NAME,"update","Delete, data=" + data.to_s)
      deleteItem = data[:deleteItem]
      updateItem = data[:updateItem]
      addItem = data[:addItem]

      # Delete items
      if (deleteItem != nil)
        ConsoleLogger::log(C_CLASS_NAME,"update","Delete, item=" + deleteItem.to_s)
        concept = ThesaurusConcept.find(deleteItem[:id], self.namespace)
        if !concept.destroy(self.namespace, self.id)
          self.errors.add(:base, "The concept deletion failed.")          
        end
      end

      # Add items
      if (addItem != nil)
        ConsoleLogger::log(C_CLASS_NAME,"update","Insert, item=" + addItem.to_s)
        if (addItem[:parent] == self.id) 
          if !ThesaurusConcept.exists?(addItem[:identifier], self.namespace)
            ThesaurusConcept.createTopLevel(addItem, self.namespace, self.id)
          else
            self.errors.add(:base, "The concept identifier already exisits.")
          end
        else
          if !ThesaurusConcept.exists?(addItem[:identifier], self.namespace)
            parentConcept = ThesaurusConcept.find(addItem[:parent], self.namespace)
            newConcept = ThesaurusConcept.create(addItem, self.namespace)
            parentConcept.addChild(newConcept, self.namespace)
          else
            self.errors.add(:base, "The concept identifier already exisits.")
          end
        end
      end

      # Update items
      if (updateItem != nil)
        ConsoleLogger::log(C_CLASS_NAME,"update","Update, item=" + updateItem.to_s)
        concept = ThesaurusConcept.find(updateItem[:id], self.namespace)
        if !concept.update(updateItem, self.namespace)
          self.errors.add(:base, "The concept update failed.")        
        end
      end
    end
  end
  
  def d3

    result = Hash.new
    result[:name] = self.identifier
    result[:namespace] = self.namespace
    result[:id] = self.id
    result[:label] = "";
    result[:identifier] = "";
    result[:notation] = "";
    result[:definition] = "";
    result[:synonym] = "";
    result[:preferredTerm] = "";
    result[:children] = Array.new
        
    count = 0
    index = 0
    baseChildId = ""
    if self.children.length <= 10
      self.children.each do |key, child|
        result[:children][index] = ThesaurusNode.new(child)
        index += 1
      end
    else      
      self.children.each do |key, child|
        if count == 0
          baseChildId = child.identifier;
          result[:children][index] = Hash.new
          result[:children][index][:name] = child.label
          result[:children][index][:id] = child.id
          result[:children][index][:expand] = true
          result[:children][index][:expansion] = Array.new        
          result[:children][index][:expansion][count] = ThesaurusNode.new(child)
          count += 1
        elsif count == 9
          result[:children][index][:name] = baseChildId + ' - ' + child.identifier
          result[:children][index][:expansion][count] = ThesaurusNode.new(child)
          count = 0
          index += 1        
        else
          result[:children][index][:name] = baseChildId + ' - ' + child.identifier;
          result[:children][index][:expansion][count] = ThesaurusNode.new(child)
          count += 1
        end
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"d3","D3=" + result.to_s)
    return result

  end

private

  def self.processNode(node, results)
    object = nil
    uriSet = node.xpath("binding[@name='a']/uri")
    idSet = node.xpath("binding[@name='b']/literal")
    nSet = node.xpath("binding[@name='c']/literal")
    ptSet = node.xpath("binding[@name='d']/literal")
    sSet = node.xpath("binding[@name='e']/literal")
    dSet = node.xpath("binding[@name='f']/literal")
    tlSet = node.xpath("binding[@name='g']/uri")
    if uriSet.length == 1 
      object = ThesaurusConcept.new 
      object.identifier = idSet[0].text
      object.notation = nSet[0].text
      object.preferredTerm = ptSet[0].text
      object.synonym = sSet[0].text
      object.definition = dSet[0].text
      object.topLevel = false
      if tlSet.length == 1 
        object.topLevel = true
      end
      results.push(object)
    end
  end

  def self.queryString(searchTerm, ns)
    query = "SELECT DISTINCT ?a ?b ?c ?d ?e ?f ?g WHERE \n" +
      "  {\n" +
      "    ?a iso25964:identifier ?b . \n" +
      "    ?a iso25964:notation ?c . \n" +
      "    ?a iso25964:preferredTerm ?d . \n" +
      "    ?a iso25964:synonym ?e . \n" +
      "    ?a iso25964:definition ?f . \n" +
      "    OPTIONAL { ?a iso25964:inScheme ?g . }\n"
      if searchTerm != ""
        query += "    ?a ( iso25964:identifier | iso25964:notation | iso25964:preferredTerm | iso25964:synonym | iso25964:definition ) ?h . FILTER regex(?h, \"" + 
          searchTerm + "\") . \n"
      end
      query += "    FILTER(STRSTARTS(STR(?a), \"" + ns + "\"))" +
      "  }"
      return query
  end

  def self.getOrderVariable(col)
    columnMap = 
      {
        # See query above to map the columns to variables
        "0" => "?b", # identifier
        "1" => "?c", # notation
        "2" => "?f", # definition
        "3" => "?e", # synonym
        "4" => "?d"  # preferred term
      }  
    variable = columnMap["0"]
    if columnMap.has_key?(col)
      variable = columnMap[col]
    end
    return variable
  end  
  
  def self.getOrdering(dir)
    orderMap = 
      {
        "desc" => "DESC",
        "asc" => "ASC"
      }
    order = orderMap["asc"]
    if orderMap.has_key?(dir)
      order = orderMap[dir]
    end
    return order
  end


end