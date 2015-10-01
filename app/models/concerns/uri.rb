class Uri

  # Scheme for constructing URIs
  #
  # <uri> ::= <scheme>://<authority>/<path>#<fragment>
  # <fragment> ::= <prefix>-<shortName>[-<version>]
  # <path> ::= <path_element>/<path>
  
  C_SCHEME_SEPARATOR = "://"
  C_PATH_SEPARATOR = "/"
  C_FRAGMENT_SECTIONS_SEPARATOR = "-"
  C_FRAGMENT_SEPARATOR = "#"
  
  attr_accessor :scheme, :authority, :path, :prefix, :shortName, :version
  
  def initialize()
    
    @scheme = "http"
    @authority = "www.assero.co.uk"
    
  end
  
  def to_s
  
    return all()
    
  end
  
  # Note: no setPath as can use default path accessor
   
  def setCidNoVersion(prefix, id)
  
    @prefix = prefix.gsub(/[^A-Z]/, '')    
    @shortName = id.gsub(/[^0-9A-Za-z_]/, '')
    @version = ""
    
  end

  def setCidWithVersion(prefix, shortName, version)
  
    @prefix = prefix.gsub(/[^A-Z]/, '')    
    @shortName = shortName.gsub(/[^0-9A-Za-z_]/, '')
    #@version = version.gsub(/[^0-9]/, '')
    @version = version.to_s
    
  end

  def setCid(classId)
  
    @prefix = getPrefix(classId)
    @shortName = getShortName(classId)
    @version = getVersion(classId)
    
  end
  
  def setUri(uri)
  
    #p "URI=" + uri
    
    @path = getPath(uri)
    fragment = getFragment(uri)
    @prefix = getPrefix(fragment)
    @shortName = getShortName(fragment)
    @version = getVersion(fragment)
    
    #p "Fragment=" + fragment
    #p "Path=" + @path
    #p "Prefix=" + @prefix
    #p "Short Name=" + @shortName
    #p "Version=" + @version
    
  end
  
  def extendPath(extension)

    #p "EXTEND PATH"
    #p "Path=" + @path
  
    @path = @path + "/" + extension

    #p "Path=" + @path
    
  end
   
  def all()

    return getNs() + C_FRAGMENT_SEPARATOR  + getCid()
  
  end
  
  def getNs()

    return @scheme + C_SCHEME_SEPARATOR + @authority + C_PATH_SEPARATOR + @path
  
  end

  def getCid()

    #p "Prefix=" + @prefix
    #p "Short Name=" + @shortName
    #p "Version=" + @version
    
    result = ""
    result = @prefix + C_FRAGMENT_SECTIONS_SEPARATOR
    if @version == ""
      result += @shortName
    else
      result += @shortName + C_FRAGMENT_SECTIONS_SEPARATOR + @version
    end
    
    #p "Result=" + result
    
    return result
    
  end

  private
  
  def getPath(uri)
  
    parts = uri.split(C_FRAGMENT_SEPARATOR)
    if parts.size == 1 or parts.size == 2
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
  
    parts = fragment.split(C_FRAGMENT_SECTIONS_SEPARATOR)
    if parts.size >= 2 and parts.size <= 3
      result = parts[0]
    else
      result = ""
    end
    return result
    
  end

  def getShortName(fragment)
  
    parts = fragment.split(C_FRAGMENT_SECTIONS_SEPARATOR)
    if parts.size >= 2 and parts.size <= 3
      result = parts[1]
    else
      result = ""
    end
    return result
    
  end

  def getVersion(fragment)
  
    parts = fragment.split(C_FRAGMENT_SECTIONS_SEPARATOR)
    if parts.size == 3
      result = parts[2]
    else
      result = ""
    end
    return result
    
  end
  
end
