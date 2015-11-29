class FrameworkItem

  include CRUD
  include ModelUtility
      
  attr_accessor :uri
  
  # Constants
  C_CLASS_NAME = "FrameworkItem"
  
  def id
    return self.uri.getCid
  end

  def namespace
    return self.uri.getNs
  end

  def initialize()
    self.uri = Uri.new
  end

  def self.find(id, ns)
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    uri = Uri.new
    uri.setNs(ns)
    uri.setCid(id)
    object = self.new
    object.uri = uri
    return object
  end

  #def self.findPrefix(id, prefix)
  #  ConsoleLogger::log(C_CLASS_NAME,"findPrefix","*****Entry*****")
  #  ns = UriManagement.getNs(prefix)
  #  uri = Uri.new
  #  uri.setNs(ns)
  #  uri.setCid(id)
  #  object = self.new
  #  object.uri = uri
  #  return object
  #end

  def self.create(ns, prefix, uid)
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    #ns = UriManagement.getNs(prefix)
    uri = Uri.new
    uri.setCidNoVersion(prefix, uid)
    uri.setNs(ns)
    object = self.new
    object.uri = uri
    return object
  end

end