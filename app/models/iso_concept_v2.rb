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
    super({label: label}, {uri: create_uri(base_uri), label: label})
  end

  # Add Tags. Add tags if not already present
  #
  # @param tags [Array] array of IsoConceptSystem::Node items
  # @return [Void] no return
  def add_tags(tags)
    uris = self.tagged.map{|x| x.uri}
    tags.each do |tag|
      self.tagged << tag if !uris.include?(tag.uri)
    end
  end

  # Add Tag. Add a tag if not already present
  #
  # @param tag [IsoConceptSystem] a single IsoConceptSystem::Node item
  # @return [Void] no return
  def add_tag(tag)
    self.tagged << tag if !self.tagged.map{|x| x.uri}.include?(tag.uri)
  end

  # Add Change Note
  #
  # @param [Hash] params the parameters hash
  # @option params [String] :user_reference the reference to the user, the user's email
  # @option params [String] :description the change note description
  # @option params [String] :reference any references
  # @option params [String] :context_id the context id
  # @return [Annotation::ChangeNote] the change note, may contain errors.
  def add_change_note(params)
    transaction_begin
    cn = Annotation::ChangeNote.create(params)
    op_ref = OperationalReferenceV3.create({reference: self.uri, context: Uri.new(id: params[:context_id])}, cn)
    cn.current << op_ref
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

end
