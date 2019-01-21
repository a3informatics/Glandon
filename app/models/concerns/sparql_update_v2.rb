class SparqlUpdateV2

  C_CLASS_NAME = "SparqlUpdateV2"

  def initialize()  
    @default_namespace = ""
    @prefix_used = {}
    @triples = Hash.new {|h,k| h[k] = [] }
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
    s = SparqlUpdateV2::Statement.new({subject: subject, predicate: predicate, object: object}, @default_namespace, @prefix_used)
    @triples[s.subject.to_s] << s
  end

  # Create Update
  #
  # @param uri [Object] The subject uri
  # @return [String] The sparql update string
  def update(uri)
    prefix_set = @prefix_used.map{|k,v| v}
    update = UriManagement.buildNs(@default_namespace, prefix_set) +
      "DELETE \n" +
      "{\n" +
      "#{uri.to_ref} ?p ?o . \n" +
      "}\n" +
      "INSERT \n" +
      "{\n" +
      "#{triples_to_s}" +
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
    prefix_set = @prefix_used.map{|k,v| v}
    update = UriManagement.buildNs(@default_namespace, prefix_set) +
      "INSERT DATA \n" +
      "{ \n" +
      "#{triples_to_s}" +
      "}"
    return update 
  end

  # To File
  #
  # @return [String] the full_path of the created file
  def to_file
    triples_to_file
  end

private

  # Puts the triples to a using prefixed notation
  def triples_to_s
    result = ""
    @triples.each {|key, subject| subject.each{|triple| result += triple.to_s}}
    return result
  end

  # Puts the triples to a file
  def triples_to_file
    output_file = ImportFileHelpers.pathname("SPARQL_#{DateTime.now.strftime('%Q')}.ttl")
    File.open(output_file, "wb") do |f|
      turtle_header(f)
      turtle_body(f)
    end
    return output_file
  end

  def turtle_header(f)
    f.write("@prefix : <#{@default_namespace}#> .\n")
    @prefix_used.map do |k,v|
      f.write("@prefix #{UriManagement.getPrefix(namespace)}: <#{v}#> .\n")
    end
    f.write("\n<#{@default_namespace}>\n")
    f.write("\trdf:type\towl:Ontology ;\n")
  end

  def turtle_body(f)
    current_subject = ""
    @triples.each do |key, subject|
      subject.each do |triple| 
        f.write(triple.to_turtle(current_subject))
        current_subject = key
      end
    end
    f.write(".")
  end

end

    