# SPARQL Update. Handles the execution of sparql updates
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql

  class Update

    include Sparql::PrefixClauses
    include Sparql::CRUD

    C_CLASS_NAME = self.name

    def initialize(transaction=nil)  
      @default_namespace = ""
      @prefix_used = {}
      @triples = Hash.new {|h,k| h[k] = []}
      @duplicates = {}
      @transaction = transaction
    end

    # Set default namespace
    #
    # @param [String] namespace the namespace
    # @return [Null] Nothing returned
    def default_namespace(namespace)
      @default_namespace = namespace
    end

    # Add a Triple
    #
    # @param [Hash] subject the subject
    # @param [Hash] predicate the predictae
    # @param [Hash] object the object
    #
    # where each can be
    # 
    # {:uri => Uri class}
    # {:namespace => string, :id => string} - Namespace can be "" but default namepace must be set
    # {:prefix => string, :id => string} - Prefix can be "" but default namepace must be set
    # {:literal => string, primitive_type => xsd:type as string} - Only valid for objects
    #
    # @return [Null] Nothing returned
    def add(subject, predicate, object)
      s = Sparql::Update::Statement.new({subject: subject, predicate: predicate, object: object}, @default_namespace, @prefix_used)
      return if duplicate?(s)
      @triples[s.subject.to_s] << s
    end

    # Update. Generate an update query
    #
    # @param [Uri] uri the subject uri
    # @raise [Errors::UpdateError] if update fails
    # @return [Void] no return
    def update(uri)
      execute_update(:update, to_update_sparql(uri))
    end

    # Selective Update. Generate an update query for the predicates detailed.
    #
    # @param [Array] predicates a list of predicates being updated
    # @param [Uri] uri the subject uri
    # @raise [Errors::UpdateError] if update fails
    # @return [Void] no return
    def selective_update(predicates, uri)
      execute_update(:update, to_selective_update_sparql(predicates, uri))
    end

    # Create. Generate a create query
    #
    # @raise [Errors::CreateError] if create fails
    # @return [Void] no return
    def create
      execute_update(:create, to_create_sparql)
    end

    # Delete. Generate a delete query
    #
    # @param uri [Uri] The subject uri
    # @raise [Errors::DestroyError] if delete fails
    # @return [Void] no return
    def delete(uri)
      execute_update(:delete, to_delete_sparql(uri))
    end

    # Upload
    #
    # @raise [Errors::CreateError] if update fails
    # @return [String] the full_path of the created file
    def upload
      execute_upload(to_file)
    end

    # To Update Sparql. Build the sparql for an update
    #
    # @param [Uri] uri the uri for the subject being modified
    # @return [String] the sparql update as a string
    def to_update_sparql(uri)
      "#{build_clauses(@default_namespace, prefix_set)}DELETE \n{\n#{uri.to_ref} ?p ?o . \n}\n" + 
        "INSERT \n{\n#{triples_to_s}}\nWHERE \n{\n#{uri.to_ref} ?p ?o . \n}"  
    end

    # To Update Sparql. Build the sparql for an update
    #
    # @param [Array] predicates set of predicates being updated
    # @param [Uri] uri the uri for the subject being modified
    # @return [String] the sparql update as a string
    def to_selective_update_sparql(predicates, uri)
      parts = []
      predicates.each_with_index {|x, index| parts << "#{uri.to_ref} #{x.to_ref} ?o#{index+1} . " }
      delete_where = parts.join("\n")
      "#{build_clauses(@default_namespace, prefix_set)}DELETE \n{\n#{delete_where}\n}\n" + 
        "INSERT \n{\n#{triples_to_s}}\nWHERE \n{\n#{delete_where}\n}"  
    end

    # To Create Sparql. Build the sparql for a create
    #
    # @return [String] the sparql create as a string
    def to_create_sparql
      "#{build_clauses(@default_namespace, prefix_set)}INSERT DATA \n{ \n#{triples_to_s}}"
    end

    # To Delete Sparql. Build the sparql for a delete
    #
    # @param [Uri] uri the uri for the subject being deleted
    # @return [String] the sparql update or create as a string
    def to_delete_sparql(uri)
      "DELETE { #{uri.to_ref} ?p ?o . } WHERE { #{uri.to_ref} ?p ?o . }"
    end

    # To File
    #
    # @return [String] the full_path of the created file
    def to_file
      add_owl_namespace # Add because we will add the OWL namespace for a file.
      triples_to_file
    end

    def sparql_update(sparql, default_namespace, prefixes)
      execute_update(:update, "#{build_clauses(default_namespace, prefixes)}\n#{sparql}")
    end

    # ---------
    # Test Only
    # ---------
    
    if Rails.env.test?

      def to_triples
        triples_to_s
      end

    end

  private

    # Duplicate triple
    def duplicate?(s)
      return true if @duplicates.key?(s.to_s)
      @duplicates[s.to_s] = true
      return false
    end

    # Execute update/create
    def execute_update(type, sparql)
      if @transaction.nil?
        response = send_update(sparql)
        if !response.success?
          base = "Failed to #{type} an item in the database. SPARQL #{type} failed."
          message = "#{base}\nSPARQL: #{sparql}"
          ConsoleLogger.info(C_CLASS_NAME, __method__.to_s, message)
          raise Errors::CreateError.new(base) if type == :create
          raise Errors::UpdateError.new(base) if type == :update
          raise Errors::DestroyError.new(base)
        end
      else
        @transaction.add(sparql)
      end
    end

    # Execute upload
    def execute_upload(file)
      response = send_file(file)
      if !response.success?
        base = "Failed to upload and create an item in the database."
        message = "#{base}\nFilename: #{file}"
        ConsoleLogger.info(C_CLASS_NAME, __method__.to_s, message)
        raise Errors::CreateError.new(base)
      end
    end

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
      namespaces = Uri::Namespace.new
      f.write("@prefix : <#{@default_namespace}#> .\n")
      namespaces.required_namespaces.map do |k, v|
        @prefix_used[k] = k if !@prefix_used.key?(k)
      end
      @prefix_used.map do |k, v|
        f.write("@prefix #{v}: <#{namespaces.namespace_from_prefix(v)}#> .\n")
      end
      f.write("\n<#{@default_namespace}>\n")
      f.write("\trdf:type owl:Ontology ;\n")
    end

    # Write the body
    def turtle_body(f)
      current_subject = ""
      @triples.each do |key, subject|
        subject.each do |triple| 
          text = triple.to_turtle(current_subject)
          f.write(text)
          current_subject = key
        end
      end
      f.write(".")
    end

    # Add OWL namespace if not already included
    def add_owl_namespace
      owl = Uri::Namespace.new.owl_prefix.to_s
      return if @prefix_used.key?(owl)
      @prefix_used[owl] = owl 
    end

  end

end

    