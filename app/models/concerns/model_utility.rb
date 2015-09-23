require "uri"

module ModelUtility

  def ModelUtility.buildCid(prefix, unique)
  
    uri = Uri.new
    uri.setCidNoVersion(prefix,unique)
    return uri.getCid
    
  end
  
  def ModelUtility.buildCidVersion(prefix, shortName, version)
  
    uri = Uri.new
    uri.setCidWithVersion(prefix, shortName, version)
    return uri.getCid
    
  end
  
  def ModelUtility.cidSwapPrefix(cid, prefix)
  
    uri = Uri.new
    uri.setCid(cid)
    uri.prefix = prefix
    return uri.getCid
    
  end
  
  def ModelUtility.extractCid(uri)
  
    object = Uri.new()
    object.setUri(uri)
    return object.getCid()
  
  end
  
  def ModelUtility.extractNs(uri)
  
    object = Uri.new()
    object.setUri(uri)
    return object.getNs()
  
  end
  
  def ModelUtility.extractShortName(cid)
  
    object = Uri.new()
    object.setCid(cid)
    return object.shortName()
  
  end
  
end
