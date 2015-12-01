require "nokogiri"
require "uri"

class IsoLink

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :frameworkItem, :typeName
  validates_presence_of :id, :frameworkItem, :typeName
  
  # Constants
  C_NS_PREFIX = "mdrCons"
  C_CID_PREFIX = "L"
  C_CLASS_NAME = "IsoLink"
        
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def persisted?
    id.present?
  end
 
  def initialize()
  end

  def baseNs
    return @@baseNs 
  end
  
  # See IsoProperty for what is needed here
  
end