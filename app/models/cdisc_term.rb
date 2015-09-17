require "uri"

class CdiscTerm
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :files, :name, :identifier, :version, :date, :thesaurus_id
  validates_presence_of :files, :date, :thesaurus_id
  
  # Base namespace 
  @@ns
  @@cdiscOrg
  
  def persisted?
    id.present?
  end
  
  def initialize()
    
    after_initialize
  
  end

  def ns
    
    return @@ns 
    
  end
  
  def name
    
    if self.thesaurus_id == nil
      return ""
    else
      thesaurus = Thesaurus.find(self.thesaurus_id)
      return thesaurus.name
    end
    
  end
  
  def identifier
    
    if self.thesaurus_id == nil
      return ""
    else
      thesaurus = Thesaurus.find(self.thesaurus_id)
      return thesaurus.identifier
    end
    
  end
  
  def version
    
    if self.thesaurus_id == nil
      return ""
    else
      thesaurus = Thesaurus.find(self.thesaurus_id)
      return thesaurus.version
    end
    
  end
  
  def self.find(id)
    return Thesaurus.find(id)
  end

  def self.all
    
    results = Array.new
    @@cdiscOrg = Organization.findByShortName("CDISC")
    tSet = Thesaurus.findByOrgId(@@cdiscOrg.id)
    tSet.each do |thesaurus|
      object = self.new 
      object.id = thesaurus.id
      object.thesaurus_id = thesaurus.id
      results.push(object)
    end
    return results  
    
  end

  def self.create(params)
    
    object = self.new
    
    org = Organization.findByName("CDISC")
    #identifier = params[:identifier]
    identifier = C_IDENTIFIER
    version = params[:version]
    date = params[:date]
    files = params[:files]
    
    #p "Id=" + identifier
    #p "Ver=" + version
    #p "Date=" + date
    p "Files=" + files.to_s
    
    # Create the IdentifiedItem
    iiParams = {:version => version, :identifier => identifier, :organization_id => org.id}
    ii = IdentifiedItem.create(iiParams)
    
    #Create the thesaurus
    tParams = {:ii_id => ii.id}
    thesaurus = Thesaurus.create(tParams)

    # Set the object
    object.date = date
    object.thesaurus_id = thesaurus.id
    return object
    
  end

  def update
    return nil
  end

  def destroy
         
  end

  private
  
  def after_initialize
  
    #@@ns = Namespace.find(C_NS_PREFIX)
    
    p "CDISC Term Initialized"
    
  end
  
end
