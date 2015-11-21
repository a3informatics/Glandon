require "uri"

module ModelUtility

  C_CLASS_NAME = "ModelUtility"

  def ModelUtility.validIdentifier?(value, object)
    result = value =~ /\A\w+\z/ 
    return true if result != nil
    object.errors.add(:identifer, "contains invalid characters or is empty")
    return false
  end

  def ModelUtility.validItemType?(value, object)
    result = value =~ /\A\w+\z/  
    return true if result != nil
    object.errors.add(:item_type, "contains invalid characters or is empty")
    return false
  end

  def ModelUtility.buildUri(namespace, id)
  
    uri = Uri.new
    uri.setNsCid(namespace,id)
    return "<" + uri.all + ">"
    
  end
  
  def ModelUtility.buildCid(prefix, unique)
  
    uri = Uri.new
    uri.setCidNoVersion(prefix,unique)
    return uri.getCid
    
  end
  
  def ModelUtility.buildCidVersion(prefix, itemType, version)
  
    uri = Uri.new
    uri.setCidWithVersion(prefix, itemType, version)
    return uri.getCid
    
  end
  
  def ModelUtility.buildCidTime(prefix)
  
    return buildCid(prefix,Time.now.to_formatted_s(:number))
    
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
  
  def ModelUtility.extractItemType(cid)
  
    object = Uri.new()
    object.setCid(cid)
    return object.itemType()
  
  end

  def ModelUtility.getValue(name, uri, node)
    path = "binding[@name='" + name + "']/"
    if uri 
      path = path + "uri"
    else
      path = path + "literal"
    end
    valueArray = node.xpath(path)
    if valueArray.length == 1
      #ConsoleLogger::log(C_CLASS_NAME,"getValue","Result=" + valueArray[0].text)
      return valueArray[0].text
    else
      #ConsoleLogger::log(C_CLASS_NAME,"getValue","Blank result")
      return ""
    end
  end
  
end
