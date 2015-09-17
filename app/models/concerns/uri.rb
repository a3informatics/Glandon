class Uri

  C_SCHEME_SEPARATOR = "://"
  C_PATH_SEPARATOR = "/"
  C_UNIQUE_ID_SEPARATOR = "-"
  C_PREFIX_SEPARATOR = "_"
  C_FRAGMENT_SEPARATOR = "#"
  
  attr_accessor :scheme, :authority, :path, :prefix, :id
  
  def initialize()
    
    @scheme = "http"
    @authority = "www.assero.co.uk"
    
  end
  
  def to_s
  
    return all()
    
  end
  
  def setCidNoVersion(prefix,id)
  
    @prefix = prefix
    @id = id
    
  end

  def setCidWithVersion(prefix,name,version)
  
    @prefix = prefix
    @id = name + C_UNIQUE_ID_SEPARATOR + version
    
  end

  def setCid(classId)
  
    @prefix = getPrefix(classId)
    @id = getId(classId)
    
  end
  
  def setUri(uri)
  
    p "URI=" + uri
    
    @path = getPath(uri)
    fragment = getFragment(uri)
    @prefix = getPrefix(fragment)
    @id = getId(fragment)
    
    p "Fragment=" + fragment
    p "Path=" + @path
    p "Prefix=" + @prefix
    p "Id=" + @id
    
  end
  
  def extendPath(extension)
  
    @path = @path + "/" + extension
    
  end
   
  def all()

    return getNS() + C_FRAGMENT_SEPARATOR  + getClassId()
  
  end
  
  def getNS()

    return @scheme + C_SCHEME_SEPARATOR + @authority + C_PATH_SEPARATOR + @path
  
  end

  def getCid()

    if @prefix == ""
      return @id
    else
      return @prefix + C_PREFIX_SEPARATOR + @id
    end
    
  end

  private
  
  def getPath(uri)
  
    parts = uri.split(C_FRAGMENT_SEPARATOR )
    if parts.size == 2
      result = parts[0].sub(@scheme + C_SCHEME_SEPARATOR + @authority + C_PATH_SEPARATOR,"")
    else
      result = ""
    end
    return result
    
  end
  
  def getFragment(uri)
  
    parts = uri.split(C_FRAGMENT_SEPARATOR )
    if parts.size == 2
      result = parts[1]
    else
      result = ""
    end
    return result
    
  end

  def getPrefix(fragment)
  
    parts = fragment.split(C_PREFIX_SEPARATOR)
    if parts.size >= 2
      result = parts[0]
    else
      result = ""
    end
    return result
    
  end

  def getId(fragment)
  
    parts = fragment.split(C_PREFIX_SEPARATOR)
    if parts.size == 2
      result = parts[1]
    elsif parts.size >= 2
        result = fragment.sub(parts[0] + C_PREFIX_SEPARATOR, "")
    else
      result = ""
    end
    return result
    
  end
  
end
