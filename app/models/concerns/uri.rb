class Uri

  # Scheme for constructing URIs
  #
  # <uri>      ::= <scheme>://<authority>/<path>#<fragment>
  # <cid>      ::= <prefix>-<uid>[-<version>]
  # <path>     ::= <path_element>/<path>
  #
  # CID = Class Identifier, used as the id for Rails classes and based on the URI
  # CID and fragment are the same thing

  C_CLASS_NAME = "Uri"  
  C_SCHEME_SEPARATOR = "://"
  C_PATH_SEPARATOR = "/"
  C_FRAGMENT_SECTION_SEPARATOR = "-" 
  C_UID_SECTION_SEPARATOR = "_"
  C_FRAGMENT_SEPARATOR = "#"
  
  attr_accessor :scheme, :authority, :path, :prefix, :uid, :version
  
  def initialize()  
    @scheme = "http"
    @authority = "www.assero.co.uk" 
    @path = ""
    @prefix = ""
    @uid = ""
    @version = ""
  end
  
  def to_s
    return all()  
  end
  
  # Note: no setPath as can use default path accessor
   
  def setCidNoVersion(prefix, uid)  
    #@prefix = prefix.gsub(/[^A-Z]/, '')    
    #@uid = id.gsub(/[^0-9A-Za-z_]/, '')
    @prefix = prefix
    @uid = uid
    @version = ""    
  end

  def setCidWithVersion(prefix, uid, version)  
    #@prefix = prefix.gsub(/[^A-Z]/, '')    
    #@uid = uid.gsub(/[^0-9A-Za-z_]/, '')
    #@version = version.gsub(/[^0-9]/, '')
    @prefix = prefix
    @uid = uid
    @version = version.to_s
  end

  def setNsCid(ns, cid)
    @authority = getAuthority(ns)
    @path = getPath(ns)
    setCid(cid)
  end

  def setNs(ns)
    @authority = getAuthority(ns)
    @path = getPath(ns)
  end

  def setCid(classId) 
    @prefix = getPrefix(classId)
    @uid = getUid(classId)
    @version = getVersion(classId)
  end
  
  def setUri(uri)
    @authority = getAuthority(uri)
    @path = getPath(uri)
    fragment = getFragment(uri)
    @prefix = getPrefix(fragment)
    @uid = getUid(fragment)
    @version = getVersion(fragment)
  end
  
  def extendPath(extension)
    @path = @path + C_PATH_SEPARATOR + extension
  end
   
  def extendUid(extension)
    @uid = @uid + C_UID_SECTION_SEPARATOR + extension.to_s
  end
   
  def all()
    return getNs() + C_FRAGMENT_SEPARATOR + getCid()
  end
  
  def getNs()
    return @scheme + C_SCHEME_SEPARATOR + @authority + C_PATH_SEPARATOR + @path
  end

  def getCid()
    #p "Prefix=" + @prefix
    #p "Short Name=" + @uid
    #p "Version=" + @version
    
    result = ""
    if @prefix != ""
      result = @prefix + C_FRAGMENT_SECTION_SEPARATOR
    end
    if @version == ""
      result += @uid
    else
      result += @uid + C_FRAGMENT_SECTION_SEPARATOR + @version
    end
    return result  
  end

private
  
  def getAuthority(uri)
    parts = uri.split(C_FRAGMENT_SEPARATOR)
    if parts.size == 1 or parts.size == 2
      temp = parts[0].sub(@scheme + C_SCHEME_SEPARATOR,"")
      innerParts = temp.split(C_PATH_SEPARATOR)
      if innerParts.size >= 1
        result = innerParts[0]
      else
        result = ""
      end
    else
      result = ""
    end
    #ConsoleLogger::log(C_CLASS_NAME,"getAuthority","Authority=" + result)
    return result  
  end

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
    parts = fragment.split(C_FRAGMENT_SECTION_SEPARATOR)
    if parts.size >= 2 and parts.size <= 3
      result = parts[0]
    else
      result = ""
    end
    return result 
  end

  def getUid(fragment)
    parts = fragment.split(C_FRAGMENT_SECTION_SEPARATOR)
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
    parts = fragment.split(C_FRAGMENT_SECTION_SEPARATOR)
    if parts.size == 3
      result = parts[2]
    else
      result = ""
    end
    return result  
  end
  
end
