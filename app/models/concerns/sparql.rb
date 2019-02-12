class Sparql

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
    add_owl_namespace # Add because we will add the OWL namespace for a file.
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

  # Write the header part
  def turtle_header(f)
    f.write("@prefix : <#{@default_namespace}#> .\n")
    UriManagement.required.map do |k,v|
      @prefix_used[k] = k if !@prefix_used.key?(k)
    end
    @prefix_used.map do |k,v|
      f.write("@prefix #{v}: <#{UriManagement.getNs(v)}#> .\n")
    end
    f.write("\n<#{@default_namespace}>\n")
    f.write("\trdf:type owl:Ontology ;\n")
  end

  # Write the body
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

  # Add OWL namespace if not already included
  def add_owl_namespace
    return if @prefix_used.key?(UriManagement::C_OWL)
    @prefix_used[UriManagement::C_OWL] = UriManagement::C_OWL 
  end


  # Build Namespace list
  #
  # @param default_namespace [string] The prefix
  # @param optional [array] Array of namespace prefixes
  # @return [string] The list of namespaces
  def self.buildNs(default_namespace, optional)
    if default_namespace == ""
      result = ""
    else
      result = formEntry("", default_namespace)
    end
    result = result + buildPrefixes(optional)
    return result
  end
  
private
  
  def self.buildPrefixes(optional)
    result = ""
    optional.each do |key|
      if @@optional.has_key?(key)
        result = result + formEntry(key,@@optional[key])
      end
    end
    @@required.each do |key,value|
      result = result + formEntry(key,value)
    end
    return result
  end

  def self.formEntry(prefix,ns)
    result = "PREFIX " + prefix + ": <" + ns + "#>" + "\n"
  end


end

    