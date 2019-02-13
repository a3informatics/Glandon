# SPARQL Update. Handles the execution of sparql updates
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql

  class Update

    include Sparql::Namespace
    include Sparql::PrefixClauses

     
    C_CLASS_NAME = self.name

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
    # {:uri => UriV4 class}
    # {:namespace => string, :id => string} - Namespace can be "" but default namepace must be set
    # {:prefix => string, :id => string} - Prefix can be "" but default namepace must be set
    # {:literal => string, primitive_type => xsd:type as string} - Only valid for objects
    #
    # @return [Null] Nothing returned
    def add(subject, predicate, object)
      s = Sparql::Statement.new({subject: subject, predicate: predicate, object: object}, @default_namespace, @prefix_used)
      @triples[s.subject.to_s] << s
    end

    # Update. Generate an update query
    #
    # @param uri [UriV4] The subject uri
    # @return [String] The sparql update string
    def update(uri)
      "#{build_clauses(@default_namespace, prefix_set)}DELETE \n{\n#{uri.to_ref} ?p ?o . \n}\n" + 
      "INSERT \n{\n#{triples_to_s}}\nWHERE \n{\n#{uri.to_ref} ?p ?o . \n}"
    end

    # Create. Generate a insert query
    #
    # @return [String] The sparql update string
    def create
      "#{build_clauses(@default_namespace, prefix_set)}INSERT DATA \n{ \n#{triples_to_s}}"
    end

    # To String. String version
    #
    # @return [String] String representation of the prefixes and triples
    #def to_s
    #  %Q{#{build_clauses(@default_namespace, prefix_set)}\n#{triples_to_s}}
    #end

    # To File
    #
    # @return [String] the full_path of the created file
    def to_file
      add_owl_namespace # Add because we will add the OWL namespace for a file.
      triples_to_file
    end

  private

    # Prefixes as an array
    def prefix_set
      @prefix_used.map{|k,v| v}
    end

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

  end

end

    