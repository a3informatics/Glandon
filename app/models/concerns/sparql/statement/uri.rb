# Sparql Update Statement URI
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Sparql::Statement::Uri

  include Sparql::Namespace

  C_CLASS_NAME = self.name

  # Initialize
  #
  # @param [Hash] args the hash of arguments
  # @option [UriV4] :uri a complete uri
  # @option [String] :namespace the namespace
  # @option [String] :prefix the namespace prefix
  # @option [String] :fragment the fragment
  #
  # @example full URI
  #   {:uri => UriV4 class}
  #
  # @example namespace and fragement
  # {:namespace => string, :fragment => string} - Namespace can be "" but default namepace must be set
  #
  # @example namespace prefix and fragement
  # {:prefix => string, :fragment => string} - Prefix can be "" but default namepace must be set
  #
  # @return [SparqlUpdateV2::StatementLiteral] the object
  def initialize(args, default_namespace, prefix_set)
    @prefix = ""
    if args.has_key?(:uri) 
      @uri = args[:uri]
    elsif args.has_key?(:namespace) && args.has_key?(:fragment)
      check_namespace(args, default_namespace)
      @uri = UriV4.new(args)      
    elsif args.has_key?(:prefix) && args.has_key?(:fragment)
      check_prefix(args, default_namespace)
      @uri = UriV4.new(args)      
      add_prefix(args[:prefix], prefix_set)
    else
      raise Errors.application_error(C_CLASS_NAME, __method__.to_s, "Invalid triple part detected. Args: #{args}") 
    end
    @default = default_namespace == @uri.namespace
  end

  # URI
  #
  # @return [UriV4] obtain the uri
  def uri
    @uri
  end

  # To String. Output in the prefixed form
  #
  # @return [String] string representation of the object
  def to_s
    return @uri.to_ref if @prefix.empty?
    "#{@prefix}:#{@uri.fragment}"
  end

  # To Ref. Full URI form 
  #
  # @return [String] string representation of the object
  def to_ref
    @uri.to_ref
  end

  # To Tutle
  #
  # @return [String] turtle string representation of the object
  def to_turtle
    # Order important
    return ":#{@uri.fragment}" if @default
    return "#{@prefix}:#{@uri.fragment}" if !@prefix.empty?
    @uri.to_ref
  end

private

  # Check namespace args and set to default if necessary
  def check_namespace(args, default_namespace)
    check_default_namespace(args, :namespace, default_namespace)
    args[:namespace] = default_namespace if args[:namespace].empty?
  end

  # Check prefix args and set to default if necessary
  def check_prefix(args, default_namespace)
    check_default_namespace(args, :prefix, default_namespace)
    args[:namespace] = args[:prefix].empty? ? default_namespace : namespace_from_prefix(args[:prefix]) 
  end

  # Check if both empty
  def check_default_namespace(args, symbol, default_namespace)
    return if !args[symbol].empty? || !default_namespace.empty?
    raise Errors.application_error(C_CLASS_NAME, __method__.to_s, "No default namespace available and #{symbol} not set. Args: #{args}") 
  end

  # Add a prefix to the set, save locally
  def add_prefix(prefix, prefix_set)
    return if prefix.empty?
    prefix_set[prefix] = prefix if !prefix_set.key?(prefix)
    @prefix = prefix
  end
end

    