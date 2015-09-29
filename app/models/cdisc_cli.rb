require "uri"

class CdiscCli
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Xml
  include Xslt
      
  attr_accessor :id, :identifier, :notation, :synonym, :definition, :preferredTerm, :namespace
  validates_presence_of :identifier, :notation, :synonym, :definition, :preferredTerm, :namespace
  
  # Base namespace 
  @@cdiscOrg # CDISC Organization identifier
  
  # Base namespace 
  @@baseNs = ThesaurusConcept.baseNs()
  
  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    return @baseNs
  end
  
  def diff? (otherCli)
  
    result = false
    if ((self.id == otherCli.id) &&
      (self.identifier == otherCli.identifier) &&
      (self.notation == otherCli.notation) &&
      (self.preferredTerm == otherCli.preferredTerm) &&
      (self.synonym == otherCli.synonym) &&
      (self.definition == otherCli.definition))
      result = false
    else
      result = true
    end
    return result
  
  end
  
  def self.find(id, cdiscTerm)
    
    p "[CdiscCli           ][find                ] id=" + id
    p "[CdiscCli           ][find                ] ns=" + cdiscTerm.namespace
  
    object = nil
    tc = ThesaurusConcept.find(id, cdiscTerm.namespace)
    if tc != nil
      object = self.new 
      object.id = tc.id
      object.identifier = tc.identifier
      object.notation = tc.notation
      object.preferredTerm = tc.preferredTerm
      object.synonym = tc.synonym
      object.definition = tc.definition
      object.namespace = cdiscTerm.namespace
    end
    return object
    
  end

  def self.allForCl(id, cdiscTerm)
    
    p "[CdiscCli           ][allForCL            ] id=" + id
    p "[CdiscCli           ][allForCL            ] ns=" + cdiscTerm.namespace
  
    results = Array.new
    tcSet = ThesaurusConcept.allLowerLevelWithNs(id, cdiscTerm.namespace)
    tcSet.each do |tc|
      object = self.new 
      object.id = tc.id
      object.identifier = tc.identifier
      object.notation = tc.notation
      object.preferredTerm = tc.preferredTerm
      object.synonym = tc.synonym
      object.definition = tc.definition
      object.namespace = cdiscTerm.namespace
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
