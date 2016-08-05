class SparqlUpdateV2

  C_CLASS_NAME = "SparqlUpdateV2"

  def initialize()  
    @default_namespace = ""
    @prefix_set = []
    @prefix_used = {}
    @triples = ""
  end

  def default_namespace(ns)
    #ConsoleLogger::log(C_CLASS_NAME,"add_default_namespace","Default NS=#{ns}")
    @default_namespace = ns
  end

  # subject, predicate, object all <Inner Hash>
  # 
  # where
  # 
  # {:uri => UriV2 class}
  # {:namespace => string, :id => string} - Namespace can be "" but default namepace must be set
  # {:prefix => string, :id => string} - Prefix can be "" but default namepace must be set
  # {:literal => string, primitive_type => xsd:type as string} - Only valid for objects
  def triple(subject, predicate, object)
    triple = ""
    triple = process_part(subject)
    triple += " #{process_part(predicate)}"
    triple += " #{process_part(object, true)} . \n"
    @triples += triple
  end

  def to_s
    #ConsoleLogger::log(C_CLASS_NAME,"to_s","Default NS=#{@default_namespace}")
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
      if args[:primitive_type] == "string"
        literal = SparqlUtility::replace_special_chars(args[:literal])
      end
      part = "\"#{literal}\"^^xsd:#{args[:primitive_type]}"
    else
      raise "Invalid triple part detected.  Args: #{args.to_s}"
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

    