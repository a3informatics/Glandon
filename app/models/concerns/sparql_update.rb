class SparqlUpdate

  C_CLASS_NAME = "SparqlUpdate"

  def initialize()  
    @default_ns = ""
    @prefix_set = []
    @prefix_used = {}
    @triples = ""
  end

  def add_default_namespace(ns)
    #ConsoleLogger::log(C_CLASS_NAME,"add_default_namespace","Default NS=#{ns}")
    @default_ns = ns
  end

  def add_prefix(prefix)
    if prefix != ""
      if !@prefix_used.has_key?(prefix)
        @prefix_set << prefix
        @prefix_used[prefix] = prefix
      end
    end
  end

	def triple(s_prefix, s_id, p_prefix, p_id, o_prefix, o_id)
    @triples += s_prefix + ":" + s_id + " " + p_prefix + ":" + p_id + " " + o_prefix + ":" + o_id + " . \n"
    add_prefix (s_prefix)
    add_prefix (p_prefix)
    add_prefix (o_prefix)    
  end

  def triple_uri(s_prefix, s_id, p_prefix, p_id, o_ns, o_id)
    @triples += s_prefix + ":" + s_id + " " + p_prefix + ":" + p_id + " <" + o_ns + "#" + o_id + "> . \n"
    add_prefix (s_prefix)
    add_prefix (p_prefix)    
  end

  def triple_uri_full(s_prefix, s_id, p_prefix, p_id, o_uri)
    @triples += "#{s_prefix}:#{s_id} #{p_prefix}:#{p_id} #{o_uri} . \n"
    add_prefix (s_prefix)
    add_prefix (p_prefix)    
  end

  def triple_uri_full_v2(s_prefix, s_id, p_prefix, p_id, o_uri)
    @triples += "#{s_prefix}:#{s_id} #{p_prefix}:#{p_id} #{o_uri.to_ref} . \n"
    add_prefix (s_prefix)
    add_prefix (p_prefix)    
  end

  def triple_primitive_type(s_prefix, s_id, p_prefix, p_id, literal, primitive_type)
    if primitive_type == "string"
      literal = SparqlUtility::replace_special_chars(literal)
    end
    @triples += s_prefix + ":" + s_id + " " + p_prefix + ":" + p_id + " \"" + literal.to_s + "\"^^xsd:" + primitive_type + " . \n"
    add_prefix (s_prefix)
    add_prefix (p_prefix)
  end

  def to_s
    #ConsoleLogger::log(C_CLASS_NAME,"to_s","Default NS=#{@default_ns}")
    update = UriManagement.buildNs(@default_ns, @prefix_set) +
      "INSERT DATA \n" +
      "{ \n" +
      @triples +
      "}"
    return update 
  end

end

    