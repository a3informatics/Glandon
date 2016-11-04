class UriV2

  # Scheme for constructing URIs
  #
  # <uri>      ::= <scheme>://<authority>/<path>#<fragment>
  # <cid>      ::= <prefix>-<uid>[-<version>]
  # <path>     ::= <path_element>/<path>
  #
  # CID = Class Identifier, used as the id for Rails classes and based on the URI
  # CID and fragment are the same thing, CID is a specalist form of.

  C_CLASS_NAME = "Uri"  
  C_SCHEME_SEPARATOR = "://"
  C_PATH_SEPARATOR = "/"
  C_FRAGMENT_SECTION_SEPARATOR = "-" 
  C_UID_SECTION_SEPARATOR = "_"
  C_FRAGMENT_SEPARATOR = "#"
  C_IRIREF_START = "<"
  C_IRIREF_END = ">"
  
  # Initialize
  #
  # Four ways to initialize
  # 1. {:uri}
  # 2. {:namespace, :id}
  # 3. {:namespace, :prefix, :org_name, :identifier, [:version]}
  # 4. {}
  #
  # @param args [hash] The arguments hash
  # @return [object] The URI object
  def initialize(args)
    @scheme = "http"
    @authority = "www.assero.co.uk" 
    @path = ""
    @prefix = ""
    @uid = ""
    @version = ""
    if args.has_key?(:uri)
      uri = args[:uri] # @todo - Check this, regex to check?
      @authority = get_authority(uri)
      @path = get_path(uri)
      fragment = get_fragment(uri)
      @prefix = get_prefix(fragment)
      @uid = get_uid(fragment)
      @version = get_version(fragment)
    elsif args.has_key?(:id) && args.has_key?(:namespace)
      fragment = args[:id].gsub(/[^0-9A-Za-z_\-]/, '')
      namespace = args[:namespace] # @todo - Check this, regex to check?
      @authority = get_authority(namespace)
      @path = get_path(namespace)
      @prefix = get_prefix(fragment)
      @uid = get_uid(fragment)
      @version = get_version(fragment)
    elsif args.has_key?(:prefix) && args.has_key?(:org_name) && args.has_key?(:identifier) && args.has_key?(:namespace)
      uid = "#{args[:org_name]}#{C_UID_SECTION_SEPARATOR}#{args[:identifier]}"
      uid = uid.gsub(/[^0-9A-Za-z_]/, '')
      namespace = args[:namespace]
      #ConsoleLogger::log(C_CLASS_NAME,"initialize","namespace=#{namespace}")
      @authority = get_authority(namespace)
      @path = get_path(namespace)
      @prefix = args[:prefix] # @todo - Check this, restrict to upper case only?
      @uid = uid
      if args.has_key?(:version)
        @version = "#{args[:version]}"
      end
    end
  end

  # To String
  #
  # @return [string] The uri as a string namesapce#id form
  def to_s
    result = ""
    if self.id == ""
      result = "#{self.namespace}"
    else
      result = "#{self.namespace}#{C_FRAGMENT_SEPARATOR}#{self.id}"
    end
    return result      
  end
  
  # To Reference
  #
  # @return [string] The uri as a reference "<" + namesapce#id + ">" form
  def to_ref
    result = ""
    if self.id == ""
      result = "#{C_IRIREF_START}#{self.namespace}#{C_IRIREF_END}"
    else
      result = "#{C_IRIREF_START}#{self.namespace}#{C_FRAGMENT_SEPARATOR}#{self.id}#{C_IRIREF_END}"
    end
    return result      
  end
  
  # To JSON
  #
  # @return [hash] The uri as JSON, namesapce and id
  def to_json
    return {:namespace => self.namespace, :id => self.id}
  end

  # Namespace
  #
  # @return [string] The namespace part only 
  def namespace()
    return @scheme + C_SCHEME_SEPARATOR + @authority + C_PATH_SEPARATOR + @path
  end

  # Id
  #
  # @return [string] The id part only 
  def id()
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

  def extend_path(extension)
    @path = @path + C_PATH_SEPARATOR + extension
  end

private
  
  def get_authority(uri)
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
    return result  
  end

  def get_path(uri)
    parts = uri.split(C_FRAGMENT_SEPARATOR)
    if parts.size == 1 or parts.size == 2
      result = parts[0].sub(@scheme + C_SCHEME_SEPARATOR + @authority + C_PATH_SEPARATOR,"")
    else
      result = ""
    end
    return result  
  end
  
  def get_fragment(uri)
    parts = uri.split(C_FRAGMENT_SEPARATOR )
    if parts.size == 2
      result = parts[1]
    else
      result = ""
    end
    return result 
  end

  def get_prefix(fragment)
    parts = fragment.split(C_FRAGMENT_SECTION_SEPARATOR)
    if parts.size >= 2 and parts.size <= 3
      result = parts[0]
    else
      result = ""
    end
    return result 
  end

  def get_uid(fragment)
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

  def get_version(fragment)
    parts = fragment.split(C_FRAGMENT_SECTION_SEPARATOR)
    if parts.size == 3
      result = parts[2]
    else
      result = ""
    end
    return result  
  end
  
end
