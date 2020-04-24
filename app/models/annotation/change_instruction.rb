# Change Instruction. A change instruction
#
# @author Dave Iberson-Hurst
# @since 2.23.0
class Annotation::ChangeInstruction < Annotation
  
  configure rdf_type: "http://www.assero.co.uk/Annotations#ChangeInstruction",
            base_uri: "http://#{ENV["url_authority"]}/CHIN",
            uri_unique: true,
            uri_property: :ordinal

  data_property :ordinal, default: 1
  data_property :semantic 
  object_property :previous, cardinality: :many, model_class: "OperationalReferenceV3"

  # Create. 
  #
  # @return [Annotation::ChangeInstruction] the change instruction, may contain errors.
  def self.create
    ci = Annotation::ChangeInstruction.new
    ci.uri = ci.create_uri(ci.class.base_uri)
    ci.by_authority = IsoRegistrationAuthority.owner.uri
    ci.reference = "Not set"
    ci.description = "Not set"
    ci.semantic = "Not set"
    ci.save
    ci
  end

  # Delete. Delete the change instruction and the associated references.
  def delete
    query_string = %Q{
      DELETE 
        {
          ?s ?p ?o
        } 
        WHERE 
        {
          {
            #{self.uri.to_ref} (ba:current) ?s .
            ?s ?p ?o .
          }     
          UNION
          { 
            #{self.uri.to_ref} (ba:previous) ?s .
            ?s ?p ?o .
          }
          UNION
          { 
            #{self.uri.to_ref} ?p ?o .
            BIND (#{self.uri.to_ref} as ?s)
          }  
        }
      }
      partial_update(query_string, [:ba])
  end

  # Get data. 
  #
  # @return [Annotation::ChangeInstruction] the change instruction and the associated references
  def get_data
      results = {id: nil, reference: nil, description: nil, previous: [], current: []}
      query_string = %Q{
      SELECT DISTINCT ?r ?desc ?reference ?p_n ?p_id ?sv ?c_n ?c_id ?t ?type ?rdf_type WHERE
      {
        #{self.uri.to_ref} ba:description ?desc .
        #{self.uri.to_ref} ba:reference ?reference .
        OPTIONAL {
          {
            #{self.uri.to_ref} (ba:current/bo:reference) ?r .
            BIND ("current" as ?t)
          } UNION
          {
            #{self.uri.to_ref} (ba:previous/bo:reference) ?r .
            BIND ("previous" as ?t)
          }
          OPTIONAL {
            ?r rdf:type th:ManagedConcept .
            ?r rdf:type ?rdf_type .
            ?r th:notation ?p_n .
            ?r th:identifier ?p_id .
            ?r isoT:hasIdentifier/isoI:semanticVersion ?sv
             BIND ("ManagedConcept" as ?type)
          }
          OPTIONAL {
            ?r rdf:type th:UnmanagedConcept .
            ?r rdf:type ?rdf_type .
            ?r th:identifier ?c_id .
            ?r th:notation ?c_n .
            BIND ("UnmanagedConcept" as ?type)
            ?r ^th:narrower ?parent .
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
            ?r rdf:type th:Thesaurus .
            ?r rdf:type ?rdf_type .
            ?r isoT:hasIdentifier/isoI:identifier ?p_id .
            ?r isoC:label ?p_n .
            ?r isoT:hasIdentifier/isoI:semanticVersion ?sv
            BIND ("Thesaurus" as ?type)
          }
        }
      }}
      query_results = Sparql::Query.new.query(query_string, "", [:ba, :th, :bo, :isoT, :isoI, :isoC])
      query_results.by_object_set([:r, :desc, :reference, :p_id, :sv, :c_id, :p_n, :c_n, :t, :type, :rdf_type]).each do |x|
        results[:description] = x[:desc] if results[:description].nil?
        results[:reference] = x[:reference] if results[:reference].nil?
        results[:id] = self.uri.to_id if results[:id].nil?
        case x[:type].to_sym
          when :ManagedConcept
            results[x[:t].to_sym] << {parent: {id: x[:r].to_id ,identifier: x[:p_id], notation: x[:p_n], semantic_version: x[:sv], rdf_type: x[:rdf_type].to_s}}
          when :UnmanagedConcept
            results[x[:t].to_sym] << {parent: {id: x[:r].to_id ,identifier: x[:p_id], notation: x[:p_n], semantic_version: x[:sv]}, child: {identifier: x[:c_id], notation: x[:c_n], rdf_type: x[:rdf_type].to_s}}
          when :Thesaurus
            results[x[:t].to_sym] << {parent: {id: x[:r].to_id ,identifier: x[:p_id], label: x[:p_n], semantic_version: x[:sv], rdf_type: x[:rdf_type].to_s}}
        end
      end
      results
  end

  # Remove reference
  #
  # @param [Hash] params the parameters hash
  # @option params [String] :type current or previous
  # @option params [String] :concept_id the concept referenced
  def remove_reference(params)
    case params[:type].to_sym
      when :previous
        set = self.previous_objects
      when :current
        set = self.current_objects
    end
    object = set.find{|x| x.reference == Uri.new(id: params[:concept_id])}   
    op_ref = OperationalReferenceV3.find(object.uri)
    transaction_begin
    op_ref.delete
    transaction_execute
    1
  end

  # Add references
  #
  # @param [Hash] params the parameters hash
  # @option params [String] :previous the previous ids references to add
  # @option params [String] :current the current ids references to add
  # @return [Annotation::ChangeNote] the change note, may contain errors.
  def add_references(params)
    tx = transaction_begin
    if !params[:previous].nil?
      base = self.previous.count
      params[:previous].each_with_index do |p, index|  
        self.previous_push(add_op_reference(Uri.new(id: p), base + index + 1, tx))
      end
    end
    if !params[:current].nil?
      base = self.current.count
      params[:current].each_with_index do |c, index|
        self.current_push(add_op_reference(Uri.new(id: c), base + index + 1, tx))
      end
    end
    self.save
    transaction_execute
    self
  end

  def add_previous(ct, reference)
    add_reference(self.previous, ct, reference)
  end

  def add_current(ct, reference)
    add_reference(self.current, ct, reference)
  end

private
  
  def add_op_reference(uri, ordinal, tx)
    OperationalReferenceV3.create({reference: uri, context: nil, ordinal: ordinal, transaction: tx}, self)
  end
  
  def add_reference(collection, ct, reference)
    set = ct.find_by_identifiers(reference)
    if set.key?(reference.last)
      object = reference.count == 1 ? OperationalReferenceV3::TmcReference.new : OperationalReferenceV3::TucReference.new
      object.ordinal = self.previous.count + self.current.count + 1
      object.uri = object.create_uri(self.uri)
      object.reference = set[reference.last]
      object.context = ct.uri
      object.enabled = true
      object.optional = false
      collection << object
    else
      errors.add(:base, "Failed to find code list references #{reference} within CT.")
    end
  end

end