# ISO Concept (V2)
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoConceptV2 < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Concept",
            base_uri: "http://#{ENV["url_authority"]}/IC",
            uri_unique: :label

  data_property :label
  object_property :tagged, cardinality: :many, model_class: "IsoConceptSystem::Node"

  validates_with Validator::Field, attribute: :label, method: :valid_label?

  # Where Only Or Create
  #
  # @param label [String] the label required or to be created
  # @return [Thesaurus::Synonym] the found or new synonym object
  def self.where_only_or_create(label)
    super({label: label}, {label: label})
  end

  # Add Tags No Save. Add tags if not already present, dont save
  #
  # @param tags [Array] array of IsoConceptSystem::Node items
  # @return [Void] no return
  def add_tags_no_save(tags)
    uris = self.tagged.map{|x| x.uri}
    tags.each do |tag|
      self.tagged << tag if !uris.include?(tag.uri)
    end
  end

  # Add Tag No Save. Add a tag if not already present, dont dave
  #
  # @param tag [IsoConceptSystem] a single IsoConceptSystem::Node item
  # @return [Void] no return
  def add_tag_no_save(tag)
    self.tagged << tag if !self.tagged.map{|x| x.uri}.include?(tag.uri)
  end

  # Add a tag
  #
  # @param uri_or_id [String|URI] The id or URI of the tag
  # @return [Void] no return
  def add_tag(uri_or_id)
    uri = uri_or_id.is_a?(Uri) ? uri_or_id : Uri.new(id: uri_or_id)
    update_string = %Q{
      INSERT DATA
      {
        #{self.uri.to_ref} isoC:tagged #{uri.to_ref} . \n
      }
    }
    Sparql::Update.new.sparql_update(update_string, self.uri.namespace, [:isoC])
  end

  # Remove a tag
  #
  # @param uri_or_id [String|URI] The id or URI of the tag
  # @return [Void] no return
  def remove_tag(uri_or_id)
    uri = uri_or_id.is_a?(Uri) ? uri_or_id : Uri.new(id: uri_or_id)
    update_string = %Q{
      DELETE
      {
       #{self.uri.to_ref} isoC:tagged #{uri.to_ref}
      }
      WHERE
      {
       #{self.uri.to_ref} isoC:tagged #{uri.to_ref}
      }
    }
    Sparql::Update.new.sparql_update(update_string, self.uri.namespace, [:isoC])
  end

  # Add Change Note
  #
  # @param [Hash] params the parameters hash
  # @option params [String] :user_reference the reference to the user, the user's email
  # @option params [String] :description the change note description
  # @option params [String] :reference any references
  # @return [Annotation::ChangeNote] the change note, may contain errors.
  def add_change_note(params)
    tx = transaction_begin
    params[:transaction] = tx
    cn = Annotation::ChangeNote.create(params)
    op_ref = OperationalReferenceV3.create({reference: self.uri, transaction: tx}, cn)
    cn.current_push(op_ref)
    cn.save
    transaction_execute
    cn
  end

  # Tags. Get the tags for the items
  #
  # @return [Array] set of IsoConceptSystem::Node items
  def tags
    result = []
    query_string = %Q{
SELECT DISTINCT ?s ?p ?o WHERE {
  #{self.uri.to_ref} isoC:tagged ?s .
  ?s ?p ?o
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoC])
    query_results.by_subject.each do |subject, triples|
      result << IsoConceptSystem::Node.from_results(Uri.new(uri: subject), triples)
    end
    result
  end

  # Change Notes
  #
  # @return [Array] set of Annotation::ChangeNote items
  def change_notes
    result = []
    query_string = %Q{
SELECT DISTINCT ?s ?p ?o WHERE {
  #{self.uri.to_ref} ^bo:reference ?or .
  ?or ^ba:current ?s .
  ?s ?p ?o
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bo, :ba])
    query_results.by_subject.each do |subject, triples|
      result << Annotation::ChangeNote.from_results(Uri.new(uri: subject), triples)
    end
    result
  end

  def change_instructions
      results = {id: nil, reference: nil, description: nil, previous: [], current: []}
      query_string = %Q{
      SELECT DISTINCT ?ci ?desc ?reference ?p_n ?p_id ?sv ?c_n ?c_id ?t ?type ?rdf_type WHERE
      {
        OPTIONAL{    
          {
            ?ci (ba:current/bo:reference) #{self.uri.to_ref} .
            BIND ("current" as ?t)
          } UNION
          {
            ?ci (ba:previous/bo:reference) #{self.uri.to_ref} .
            BIND ("previous" as ?t)
          }
          ?ci ba:description ?desc .
          ?ci ba:reference ?reference .
          OPTIONAL {
            #{self.uri.to_ref} rdf:type th:ManagedConcept .
            #{self.uri.to_ref} rdf:type ?rdf_type .
            #{self.uri.to_ref} th:notation ?p_n .
            #{self.uri.to_ref} th:identifier ?p_id .
            #{self.uri.to_ref} isoT:hasIdentifier/isoI:semanticVersion ?sv
            BIND ("ManagedConcept" as ?type)
          }
          OPTIONAL {
            #{self.uri.to_ref} rdf:type th:UnmanagedConcept .
            #{self.uri.to_ref} rdf:type ?rdf_type .
            #{self.uri.to_ref} th:identifier ?c_id .
            #{self.uri.to_ref} th:notation ?c_n .
            BIND ("UnmanagedConcept" as ?type)
            #{self.uri.to_ref} ^th:narrower ?parent .
            ?parent th:notation ?p_n .
            ?parent th:identifier ?p_id .
            ?parent isoT:hasIdentifier/isoI:version ?v.
            ?parent isoT:hasIdentifier/isoI:semanticVersion ?sv
            {
              SELECT (max(?lv) AS ?v) WHERE
                  {
                    ?parent isoT:hasIdentifier/isoI:version ?lv.
                  } 
            }
          }
          OPTIONAL {
            #{self.uri.to_ref} rdf:type th:Thesaurus .
            #{self.uri.to_ref} rdf:type ?rdf_type .
            #{self.uri.to_ref} isoT:hasIdentifier/isoI:identifier ?p_id .
            #{self.uri.to_ref} isoC:label ?p_n .
            #{self.uri.to_ref} isoT:hasIdentifier/isoI:semanticVersion ?sv
            BIND ("Thesaurus" as ?type)
          }
        }
      }}
      query_results = Sparql::Query.new.query(query_string, "", [:ba, :th, :bo, :isoT, :isoI, :isoC])
        query_results.by_object_set([:ci, :desc, :reference, :p_id, :sv, :c_id, :p_n, :c_n, :t, :type, :rdf_type]).each do |x|
          results[:description] = x[:desc] if results[:description].nil?
          results[:reference] = x[:reference] if results[:reference].nil?
          results[:id] = x[:ci].to_id if results[:id].nil?
          case x[:type].to_sym
            when :ManagedConcept
              results[x[:t].to_sym] << {parent: {id: self.uri.to_id ,identifier: x[:p_id], notation: x[:p_n], semantic_version: x[:sv], rdf_type: x[:rdf_type].to_s}}
            when :UnmanagedConcept
              results[x[:t].to_sym] << {parent: {identifier: x[:p_id], notation: x[:p_n], semantic_version: x[:sv]}, child: {id: self.uri.to_id ,identifier: x[:c_id], notation: x[:c_n], rdf_type: x[:rdf_type].to_s}}
            when :Thesaurus
              results[x[:t].to_sym] << {parent: {id: self.uri.to_id ,identifier: x[:p_id], label: x[:p_n], semantic_version: x[:sv], rdf_type: x[:rdf_type].to_s}}
          end
        end
      results
    end

  # Tag labels. Get the ordered tag labels for the items
  #
  # @return [Array] set of ordered String items
  def tag_labels
    tags = self.tags
    tags.map{ |x| x.pref_label }.sort
  end

  # Other Parents. Determine if this object is connected with other parents objects other than 
  #   the one specified. The other parents must be of the same type.
  #
  # @param [Object] parent the known parent item
  # @return [Array] the other uris
  def other_parents(parent, predicates)
    path = "(#{predicates.map{|x| x.to_ref}.join("/")})"
    query_string = %Q{
      SELECT DISTINCT ?s WHERE
      {
        #{parent.uri.to_ref} #{path} #{self.uri.to_ref} .
        #{parent.uri.to_ref} rdf:type ?t .
        ?s rdf:type ?t .
        FILTER (STR(?s) != STR(#{parent.uri.to_ref})) .
        ?s #{path} #{self.uri.to_ref} .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [])
    query_results.by_object(:s)
  end

  def clone
    self.tagged_links
    super
  end
  
end
