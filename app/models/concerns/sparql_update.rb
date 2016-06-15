class SparqlUpdate

  C_CLASS_NAME = "SparqlUpdate"

  def initialize()  
    @default_ns = ""
    @prefix_set = []
    @prefix_used = {}
    @triples = ""
  end

  def add_default_namespace(ns)
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

  def triple_primitive_type(s_prefix, s_id, p_prefix, p_id, literal, primitive_type)
    if primitive_type == "string"
      literal = SparqlUtility::replace_special_chars(literal)
    end
    @triples += s_prefix + ":" + s_id + " " + p_prefix + ":" + p_id + " \"" + literal.to_s + "\"^^xsd:" + primitive_type + " . \n"
    add_prefix (s_prefix)
    add_prefix (p_prefix)
  end

  def to_s
    update = UriManagement.buildNs(@default_ns, @prefix_set) +
      "INSERT DATA \n" +
      "{ \n" +
      @triples +
      "}"
    return update 
  end

end

    