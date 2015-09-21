require "nokogiri"
require "uri"

class ThesaurusConcept

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :identifier, :notation, :synonym, :extensible, :definition, :preferredTerm
  validates_presence_of :identifier, :notation, :synonym, :extensible, :definition, :preferredTerm
  
  # Base namespace 
  @@ns
  
  # Constants
  C_CLASS_PREFIX = "THC"
  C_NS_PREFIX = "th"
        
  def persisted?
    id.present?
  end
 
  def initialize()
    
    after_initialize
  
  end

  def ns
    
    return @@ns 
    
  end
  
  def self.find(id)
    
    object = nil
    
    # Create the query
    query = Namespace.build(C_NS_PREFIX, ["iso25964"]) +
      "SELECT ?a ?b ?c ?d ?e ?f WHERE \n" +
      "{ \n" +
      "	 :" + id + " iso25964:identifier ?a . \n" +
      "	 :" + id + " iso25964:notation ?b . \n" +
      "	 :" + id + " iso25964:preferredTerm ?c . \n" +
      "	 :" + id + " iso25964:synonym ?d . \n" +
      "	 :" + id + " iso25964:extensible ?e . \n" +
      "	 :" + id + " iso25964:definition ?f . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      idSet = node.xpath("binding[@name='a']/literal")
      nSet = node.xpath("binding[@name='b']/literal")
      ptSet = node.xpath("binding[@name='c']/literal")
      sSet = node.xpath("binding[@name='d']/literal")
      eSet = node.xpath("binding[@name='e']/literal")
      dSet = node.xpath("binding[@name='f']/literal")
      
      p "id: " + idSet.text
      
      if idSet.length == 1
        
        p "Found"
        
        object = self.new 
        object.id = id
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.extensible = eSet[0].text
        object.definition = dSet[0].text

      end
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = Namespace.build(C_NS_PREFIX, ["iso25964"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g WHERE \n" +
      "{ \n" +
      "	 ?a rdf:type iso25964:ThesaurusConcept . \n" +
      "	 ?a iso25964:identifier ?b . \n" +
      "	 ?a iso25964:notation ?c . \n" +
      "	 ?a iso25964:preferredTerm ?d . \n" +
      "	 ?a iso25964:synonym ?e . \n" +
      "	 ?a iso25964:extensible ?f . \n" +
      "	 ?a iso25964:definition ?g . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      idSet = node.xpath("binding[@name='b']/literal")
      nSet = node.xpath("binding[@name='c']/literal")
      ptSet = node.xpath("binding[@name='d']/literal")
      sSet = node.xpath("binding[@name='e']/literal")
      eSet = node.xpath("binding[@name='f']/literal")
      dSet = node.xpath("binding[@name='g']/literal")
      
      if uriSet.length == 1 
        
        p "Found"
        
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.extensible = eSet[0].text
        object.definition = dSet[0].text
        results.push (object)
        
      end
    end
    
    return results
    
  end

  def self.create(params)
    
    identifier  = params[:identifier]
    notation = params[:notation]
    preferredTerm = params[:preferredTerm]
    synonym = params[:synonym]
    extensible = params[:extensible]
    definition = params[:definition]
    
    # Create the query
    id = ModelUtility.buildCid(C_CLASS_PREFIX, identifier)
    update = Namespace.build(C_NS_PREFIX, ["iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type iso25964:ThesaurusConcept . \n" +
      "	 :" + id + " iso25964:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:preferredTerm \"" + preferredTerm.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:synonym \"" + synonym.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:extensible \"" + extensible.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:definition \"" + definition.to_s + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.identifier = identifier
      object.notation = notation
      object.preferredTerm = preferredTerm
      object.synonym = synonym
      object.extensible = extensible
      object.definition = definition
      p "It worked!"
    else
      p "It didn't work!"
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def update(id)
    return nil
  end

  def destroy
    
    # Create the query
    update = Namespace.build(C_NS_PREFIX, ["iso25964"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	 :" + self.id + " rdf:type iso25964:ThesaurusConcept . \n" +
      "  :" + self.id + " iso25964:identifier \"" + self.identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " iso25964:notation \"" + self.notation.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " iso25964:preferredTerm \"" + self.preferredTerm.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " iso25964:synonym \"" + self.synonym.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " iso25964:extensible \"" + self.extensible.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " iso25964:definition \"" + self.definition.to_s + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      p "It worked!"
    else
      p "It didn't work!"
    end
     
  end
  
  private
  
  def after_initialize
  
    @@ns = Namespace.find(C_NS_PREFIX)
  
  end
  
end