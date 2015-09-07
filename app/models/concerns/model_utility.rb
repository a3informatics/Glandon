module ModelUtility

  def ModelUtility.BuildPrefixes(prefix, prefixes)
  
    result = "PREFIX " + prefix + " \n"
    prefixes.each do |p|
      result = result + "PREFIX " + p + " \n"
    end
    return result
    
  end

  def ModelUtility.BuildId(prefix, unique)
  
    return prefix + "_" + unique
    
  end
  
  def ModelUtility.BuildURI(ns, id)
  
    return ns + '#' + id
    
  end

  def ModelUtility.URIGetId(uri)
  
    parts = uri.split('#')
    if parts.size == 2
      result = parts[1]
    else
      result = uri
    end
    return result
    
  end
    
  def ModelUtility.URIGetUnique(id)
  
    parts = id.split('_')
    if parts.size == 2
      result = parts[1]
    else
      result = id
    end
    return result
    
  end
  
end
