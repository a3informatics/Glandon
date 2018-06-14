# Handles a URI
#
# <uri>      ::= <scheme>://<authority>/<path>#<fragment>
# <path>     ::= <path_element>/<path>
# <fragment> ::= <prefix>-<uid>[-<version>]
#
# Note: Upgrade to V2 to allow a Base64 encoding of the URI to be the rails class id.
#
# @author Dave Iberson-Hurst
# @since 2.18.0
# @!attribute scheme
#   @return [String] the URI scheme.
# @!attribute authority
#   @return [String] the URI authority.
# @!attribute path
#   @return [String] the URI path.
# @!attribute prefix
#   @return [String] the fragment prefix.
# @!attribute uid
#   @return [String] the fragment unique identifier.
# @!attribute version
#   @return [String] the fragment version.
class UriV3

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
  # Five ways to initialize
  # 1. {:id}
  # 1. {:uri}
  # 2. {:namespace, :fragment}
  # 3. {:namespace, :prefix, :org_name, :identifier, [:version]}
  # 4. {}
  #
  # @param [Hash] args The arguments hash.
  # @option args [String] :id The unique id.
  # @option args [String] :uri the URI as a string.
  # @option args [String] :namespace the URI namespace.
  # @option args [String] :fragment the URI fragment.
  # @option args [String] :prefix the fragment prefix.
  # @option args [String] :org_name the fragment organization name.
  # @option args [String] :identifier the fragment identifier.
  # @option args [String] :version the fragment version.
  # @return [object] The URI object
  def initialize(args)
    @scheme = "http"
    @authority = "www.assero.co.uk" 
    @path = ""
    @prefix = ""
    @uid = ""
    @version = ""
    if args.has_key?(:id)
      from_uri(Base64.strict_decode64(args[:id]))
    elsif args.has_key?(:uri)
      from_uri(args[:uri]) # @todo - Check the uri, regex to check?
    elsif args.has_key?(:fragment) && args.has_key?(:namespace)
      fragment = args[:fragment].gsub(/[^0-9A-Za-z_\-]/, '')
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

  # To Id
  #
  # @return [String] The uri as an class unique identifier
  def to_id
    return Base64.strict_encode64(self.to_s)
  end

  # To String
  #
  # @return [String] The uri as a string namesapce#id form
  def to_s
    result = ""
    if self.fragment == ""
      result = "#{self.namespace}"
    else
      result = "#{self.namespace}#{C_FRAGMENT_SEPARATOR}#{self.fragment}"
    end
    return result      
  end
  
  # To Reference
  #
  # @return [String] The uri as a reference "<" + namesapce#id + ">" form
  def to_ref
    result = ""
    if self.fragment == ""
      result = "#{C_IRIREF_START}#{self.namespace}#{C_IRIREF_END}"
    else
      result = "#{C_IRIREF_START}#{self.namespace}#{C_FRAGMENT_SEPARATOR}#{self.fragment}#{C_IRIREF_END}"
    end
    return result      
  end
  
  # To Hash
  #
  # @return [Hash] The uri in a hash
  def to_hash
    return {:uri => self.to_s}
  end

  # Namespace
  #
  # @return [string] The namespace part only 
  def namespace()
    return @scheme + C_SCHEME_SEPARATOR + @authority + C_PATH_SEPARATOR + @path
  end

  # Fragment
  #
  # @return [string] The fragment
  def fragment()
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

  # Extend the path
  #
  # @param extension [string] The extension to the path
  # @return [null]
  def extend_path(extension)
    @path = @path + C_PATH_SEPARATOR + extension
  end

  # Update the prefix
  #
  # @param prefix [string] The new prefix
  # @return [null]
  def update_prefix(prefix)
    @prefix = prefix
  end

private
  
  def from_uri(uri)
    @authority = get_authority(uri)
    @path = get_path(uri)
    fragment = get_fragment(uri)
    @prefix = get_prefix(fragment)
    @uid = get_uid(fragment)
    @version = get_version(fragment)
  end

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
