class Uri

  # Scheme for constructing URIs
  #
  # <uri> ::= <scheme>://<authority>/<path>#<fragment>
  # <cid> ::= <prefix>-<itemType>[-<version>]
  # <path> ::= <path_element>/<path>
  #
  # CID = Class Identifier, used as the id for Rails classes and based on the URI
  # CID and fragment are the same thing

  
  C_SCHEME_SEPARATOR = "://"
  C_PATH_SEPARATOR = "/"
  C_FRAGMENT_SECTIONS_SEPARATOR = "-"
  C_FRAGMENT_SEPARATOR = "#"
  
  attr_accessor :scheme, :authority, :path, :prefix, :itemType, :version
  
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
    @itemType = id.gsub(/[^0-9A-Za-z_]/, '')
    @version = ""    
  end

  def setCidWithVersion(prefix, itemType, version)  
    @prefix = prefix.gsub(/[^A-Z]/, '')    
    @itemType = itemType.gsub(/[^0-9A-Za-z_]/, '')
    #@version = version.gsub(/[^0-9]/, '')
    @version = version.to_s
  end

  def setCid(classId) 
    @prefix = getPrefix(classId)
    @itemType = getitemType(classId)
    @version = getVersion(classId)
  end
  
  def setUri(uri)
  @path = getPath(uri)
    fragment = getFragment(uri)
    @prefix = getPrefix(fragment)
    @itemType = getItemType(fragment)
    @version = getVersion(fragment)
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
    #p "Short Name=" + @itemType
    #p "Version=" + @version
    
    result = ""
    if @prefix != ""
      result = @prefix + C_FRAGMENT_SECTIONS_SEPARATOR
    end
    if @version == ""
      result += @itemType
    else
      result += @itemType + C_FRAGMENT_SECTIONS_SEPARATOR + @version
    end
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

  def getItemType(fragment)
    parts = fragment.split(C_FRAGMENT_SECTIONS_SEPARATOR)
    if parts.size >= 2 and parts.size <= 3
      result = parts[1]
    elsif parts.size == 1
      result = fragment
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
