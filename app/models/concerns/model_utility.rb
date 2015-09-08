module ModelUtility

  def ModelUtility.BuildPrefixes(prefix, prefixes)
  
    result = "PREFIX " + prefix + " \n"
    prefixes.each do |p|
      result = result + "PREFIX " + p + " \n"
    end
    return result
    
  end

  def ModelUtility.BuildFragment(prefix, unique)
  
    return prefix + "_" + unique
    
  end
  
  def ModelUtility.BuildURI(ns, fragment)
  
    return ns + '#' + fragment
    
  end

  def ModelUtility.URIGetNs(uri)
  
    parts = uri.split('#')
    if parts.size == 2
      result = parts[0]
    else
      result = uri
    end
    return result
    
  end
  
  def ModelUtility.URIGetFragment(uri)
  
    parts = uri.split('#')
    if parts.size == 2
      result = parts[1]
    else
      result = uri
    end
    return result
    
  end
    
  def ModelUtility.URIGetUnique(fragment)
  
    parts = fragment.split('_')
    if parts.size == 2
      result = parts[1]
    else
      result = id
    end
    return result
    
  end
  
  def ModelUtility.FragmentSwapPrefix(fragment, prefix)
  
    unique = URIGetUnique(fragment)
    newFragment = BuildFragment(prefix, unique)
    return newFragment
    
  end
  
end
