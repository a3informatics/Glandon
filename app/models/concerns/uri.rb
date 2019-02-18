# Handles a URI
#
# <uri>      ::= <scheme>://<authority>/<path>#<fragment>
# <path>     ::= <path_element>/<path>
# <fragment> ::= string
#
# @note Paths will be formed from <identifier>/V<version>#<fragment>
# @note This is am upgrade to V3 to form simple URIs
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class Uri

  C_CLASS_NAME = "Uri"  
  C_SCHEME_SEPARATOR = "://"
  C_PREFIX_SEPARATOR = ":"
  C_PATH_SEPARATOR = "/"
  C_FRAGMENT_SEPARATOR = "#"
  C_FRAGMENT_EXTENDER = "_"
  C_IRIREF_START = "<"
  C_IRIREF_END = ">"
  
  # Initialize
  #
  # Five ways to initialize
  # 1. {:id}
  # 2. {:uri} either full namespace or prefixed
  # 3. {:namespace, :fragment}
  # 4. {:namespace, :identifier, :version}
  #
  # @param [Hash] args The arguments hash.
  # @option args [String] :id The unique id.
  # @option args [String] :uri the URI as a string.
  # @option args [String] :namespace the URI namespace.
  # @option args [String] :fragment the URI fragment.
  # @option args [String] :identifier the fragment identifier.
  # @option args [String] :version the fragment version.
  # @return [object] The URI object
  def initialize(args)
    @scheme = "http"
    @authority = "" 
    @path = ""
    @fragment = ""
    if args.has_key?(:id)
      from_uri(Base64.strict_decode64(args[:id]))
    elsif args.has_key?(:uri)
      prefixed?(args[:uri]) ? from_prefixed(args[:uri]) : from_uri(args[:uri])
    elsif args.has_key?(:fragment) && args.has_key?(:namespace)
      @fragment = args[:fragment].gsub(/[^0-9A-Za-z_\-]/, '_')
      namespace = filter_namespace(args[:namespace])
      @authority = get_authority(namespace)
      @path = get_path(namespace)
    elsif args.has_key?(:identifier) && args.has_key?(:version) && args.has_key?(:namespace) 
      namespace = filter_namespace(args[:namespace])
      @authority = get_authority(namespace)
      @path = get_path(namespace)
      extend_path(filter_identifier(args[:identifier]))
      extend_path("V#{filter_version(args[:version])}")
      @fragment = ""
    end
  end

  # Namespaces. Return a namespace object. Class version
  #
  # @return [Uri::Namespace] the object
  def self.namespaces
    Uri::Namespace.new
  end

  # Namespaces. Return a namespace object. Instance version
  #
  # @return [Uri::Namespace] the object
  def namespaces
    self.class.namespaces
  end

  # To Id
  #
  # @return [String] The uri as a unique identifier
  def to_id
    return nil if @authority.blank?
    return Base64.strict_encode64(self.to_s)
  end

  # To String
  #
  # @return [String] The uri as a string namesapce#id form
  def to_s
    return "" if @authority.blank?
    return "#{self.namespace}" if self.fragment == ""
    return "#{self.namespace}#{C_FRAGMENT_SEPARATOR}#{self.fragment}"
  end
  
  # To Reference
  #
  # @return [String] The uri as a reference "<" + namesapce#id + ">" form
  def to_ref
    return "" if @authority.blank?
    return "#{C_IRIREF_START}#{self.to_s}#{C_IRIREF_END}"
  end
  
  # To Prefixed
  #
  # @return [String] The uri as a prefixed form
  def to_prefixed
    return "" if @authority.blank?
    prefix = namespaces.prefix_from_namespace(self.namespace)
    return "" if prefix.nil?
    return "#{prefix}#{C_PREFIX_SEPARATOR}#{@fragment}"
  end
  
  # To Hash
  #
  # @return [Hash] The uri in a hash
  def to_h
    return self.to_s
  end

  # Namespace
  #
  # @return [String] The namespace part only 
  def namespace()
    return @scheme + C_SCHEME_SEPARATOR + @authority + C_PATH_SEPARATOR + @path
  end

  # Fragment
  #
  # @return [String] The fragment
  def fragment()
    return @fragment
  end

  # Extend the path
  #
  # @param extension [String] The extension to the path
  # @return [Void] no return
  def extend_path(extension)
    @path = @path.blank? ? extension : "#{@path}#{C_PATH_SEPARATOR}#{extension}"
  end

  # Extend the fragment
  #
  # @param extension [String] The extension to the fragment
  # @return [Void] no return
  def extend_fragment(extension)
    @fragment = @fragment.blank? ? extension : "#{@fragment}#{C_FRAGMENT_EXTENDER}#{extension}"
  end

  # Equal
  #
  # @param other [Uri] the other URI
  # @return [Boolean] true if equal, false otherwise
  def ==(other)
    return self.to_s == other.to_s
  end

private

  # Prefixed?  
  def prefixed?(uri)
    uri.scan(/\A[a-zA-Z]+:[0-9A-Za-z_\-]+\z/).any?
  end

  # Build from prefix URI
  def from_prefixed(uri)
    parts = uri.split(C_PREFIX_SEPARATOR)
    return from_uri("#{namespaces.namespace_from_prefix(parts[0])}##{parts[1]}") if parts.size == 2
    return ""
  end

  # Build from an exisitng URI
  def from_uri(uri)
    @authority = get_authority(uri)
    @path = get_path(uri)
    @fragment = get_fragment(uri)
  end

  # Get the authority from the URI
  def get_authority(uri)
    parts = uri.split(C_FRAGMENT_SEPARATOR)
    if parts.size == 1 or parts.size == 2
      temp = parts[0].sub(@scheme + C_SCHEME_SEPARATOR, "")
      innerParts = temp.split(C_PATH_SEPARATOR)
      return innerParts.size >= 1 ? innerParts[0] : ""
    else
      return ""
    end
  end

  # Get the path from a URI
  def get_path(uri)
    return "" if uri.blank?
    parts = uri.split(C_FRAGMENT_SEPARATOR)
    return "" if parts.count > 2
    return parts[0].sub(@scheme + C_SCHEME_SEPARATOR + @authority, "").trim C_PATH_SEPARATOR    
  end
  
  # Get the fragment from the URI
  def get_fragment(uri)
    return "" if uri.blank?
    parts = uri.split(C_FRAGMENT_SEPARATOR)
    return parts[1] if parts.size == 2
    return ""
  end

  # Filter the namespace for nasty characters
  def filter_namespace(namespace)
    namespace.gsub(/[^0-9A-Za-z.:\/]/, '')
  end

  # Filter the version for nasty characters
  def filter_version(version)
    "#{version}".gsub(/[^0-9]+/, '')
  end

  # Filter the identifier for nasty characters
  def filter_identifier(identifier)
    identifier.gsub(/[^0-9A-Za-z_\-]/, '_')
  end

  # Filter the fragment for nasty characters
  def filter_fragment(fragment)
    fragment.gsub(/[^0-9A-Za-z_\-]/, '_')
  end
end
