require "uri"

class CdiscCl
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Xml
  include Xslt
      
  attr_accessor :id, :identifier, :notation, :synonym, :extensible, :definition, :preferredTerm, :namespace
  validates_presence_of :identifier, :notation, :synonym, :extensible, :definition, :preferredTerm, :namespace
  
  # Base namespace 
  @@cdiscOrg # CDISC Organization identifier
  
  # Base namespace 
  @@BaseNs = ThesaurusConcept.baseNs()
  
  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    return @baseNs
  end
  
  def self.find(id, ns)
    
    object = nil
    tc = ThesaurusConcept.find(id, ns)
    object = self.new 
    object.id = tc.id
    
    p "[CdiscCl            ][find                ] id=" + tc.id
  
    object.identifier = tc.identifier
    object.notation = tc.notation
    object.preferredTerm = tc.preferredTerm
    object.synonym = tc.synonym
    object.extensible = tc.extensible
    object.definition = tc.definition
    object.namespace = ns
    return object  
    
  end

  def self.all(ns)
    
    results = Array.new
    tcSet = ThesaurusConcept.allTopLevelWithNs(ns)
    tcSet.each do |tc|
      object = self.new 
      object.id = tc.id
      
      # p "[CdiscCl            ][all                 ] id=" + tc.id
    
      object.identifier = tc.identifier
      object.notation = tc.notation
      object.preferredTerm = tc.preferredTerm
      object.synonym = tc.synonym
      object.extensible = tc.extensible
      object.definition = tc.definition
      object.namespace = ns
      results.push(object)
    end
    return results  
    
  end

  def self.create(params)
    object = nil
    return object
  end

  def update
    return nil
  end

  def destroy
  end
  
end
