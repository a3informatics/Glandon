class SparqlUpdateV2

  C_CLASS_NAME = "SparqlUpdateV2"

  def initialize()  
    @default_namespace = ""
    @prefix_set = []
    @prefix_used = {}
    @triples = ""
  end

  # Set default namespace
  #
  # @param namespace [string] The namespace
  # @return [Null] Nothing returned
  def default_namespace(namespace)
    @default_namespace = namespace
  end

  # Add a Triple
  #
  # @param subject [Hash] The subject
  # @param predicate [Hash] The predictae
  # @param object [Hash] The object
  #
  # where each can be
  # 
  # {:uri => UriV2 class}
  # {:namespace => string, :id => string} - Namespace can be "" but default namepace must be set
  # {:prefix => string, :id => string} - Prefix can be "" but default namepace must be set
  # {:literal => string, primitive_type => xsd:type as string} - Only valid for objects
  #
  # @return [Null] Nothing returned
  def triple(subject, predicate, object)
    triple = ""
    triple = process_part(subject)
    triple += " #{process_part(predicate)}"
    triple += " #{process_part(object, true)} . \n"
    @triples += triple
  end

  # Create Update
  #
  # @param uri [Object] The subject uri
  # @return [String] The sparql update string
  def update(uri)
    update = UriManagement.buildNs(@default_namespace, @prefix_set) +
      "DELETE \n" +
      "{\n" +
      "#{uri.to_ref} ?p ?o . \n" +
      "}\n" +
      "INSERT \n" +
      "{\n" +
      "#{@triples}" +
      "}\n" +
      "WHERE \n" + 
      "{\n" +
      "#{uri.to_ref} ?p ?o . \n" +
      "}"
    return update
  end

  # Insert Update
  #
  # @return [String] The sparql update string
  def create
    return to_s
  end

  # To String
  #
  # @return [String] The sparql update string
  def to_s
    update = UriManagement.buildNs(@default_namespace, @prefix_set) +
      "INSERT DATA \n" +
      "{ \n" +
      @triples +
      "}"
    return update 
  end

private

  # Always builds fully qualified triples. Default namespace is filled in
  # automatically.
  def process_part(args, object_literal=false)
    part = ""
    if args.has_key?(:uri) 
      part = args[:uri].to_ref
    elsif args.has_key?(:namespace) && args.has_key?(:id)
      uri = nil
      if args[:namespace] == ""
        if @default_namespace.empty?
          raise "Default namespace used (namespace) but not set. Args: #{args.to_s}"
        else
          uri = UriV2.new({:namespace => @default_namespace, :id => args[:id]})    
        end
      else
        uri = UriV2.new(args)      
      end
      part = uri.to_ref
    elsif args.has_key?(:prefix) && args.has_key?(:id)
      # Note that :prefix can be empty (default namespace).
      if args[:prefix] == ""
        if @default_namespace.empty?
          raise "Default namespace used (prefix) but not set. Args: #{args.to_s}"
        else
          uri = UriV2.new({:namespace => @default_namespace, :id => args[:id]})    
          part = uri.to_ref
        end
      else
        part = "#{args[:prefix]}:#{args[:id]}"
        add_prefix (args[:prefix])
      end
    elsif args.has_key?(:literal) && args.has_key?(:primitive_type) && object_literal
      literal = args[:literal]
      if args[:primitive_type] == BaseDatatype.to_xsd(BaseDatatype::C_STRING) || BaseDatatype.to_xsd(BaseDatatype::C_DATETIME) 
        literal = SparqlUtility::replace_special_chars(args[:literal])
      end
      part = "\"#{literal}\"^^xsd:#{args[:primitive_type]}"
    else
      raise "Invalid triple part detected. Args: #{args.to_s}"
    end
    return part
  end

  def add_prefix(prefix)
    if prefix != ""
      if !@prefix_used.has_key?(prefix)
        @prefix_set << prefix
        @prefix_used[prefix] = prefix
      end
    end
  end

end

    