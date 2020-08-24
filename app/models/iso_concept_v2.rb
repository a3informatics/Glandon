# ISO Concept (V2)
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoConceptV2 < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Concept",
            base_uri: "http://#{ENV["url_authority"]}/IC",
            uri_unique: :label

  data_property :label
  object_property :tagged, cardinality: :many, model_class: "IsoConceptSystem::Node", delete_exclude: true

  validates_with Validator::Field, attribute: :label, method: :valid_label?

  include ManagedAncestors
  
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
    uri = self.class.as_uri(uri_or_id)
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
    uri = self.class.as_uri(uri_or_id)
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
      }
    }
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
        ?s rdf:type ba:ChangeNote . 
        ?s ?p ?o
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bo, :ba])
    query_results.by_subject.each do |subject, triples|
      result << Annotation::ChangeNote.from_results(Uri.new(uri: subject), triples)
    end
    result
  end

  # Change Instructions
  #
  # @return [Array] set of Annotation::ChangeInstructions items
  def change_instructions
    results = []
    query_string = %Q{SELECT DISTINCT ?ci WHERE {         
      OPTIONAL{               
        {             
          ?ci (ba:previous/bo:reference) #{self.uri.to_ref} .
          ?ci rdf:type ba:ChangeInstruction .                 
        } UNION           
        {             
          ?ci (ba:current/bo:reference) #{self.uri.to_ref} .
          ?ci rdf:type ba:ChangeInstruction .                   
        }       
      }       
    }}
    query_results = Sparql::Query.new.query(query_string, "", [:ba, :bo])
    triples = query_results.by_object(:ci)
      triples.each do |x|
        results << Annotation::ChangeInstruction.find(x).get_data
      end
    results
  end

  # Indicators. Get the indicators for the item.
  #
  # @return [Hash] Hash containing the indicators
  def indicators
    results = {}
    query_string = %Q{
      SELECT DISTINCT ?i ?eo ?ei ?so ?si ?ranked ?type (count(distinct ?ci) AS ?countci) (count(distinct ?cn) AS ?countcn) WHERE
      {
        OPTIONAL{
            #{self.uri.to_ref} rdf:type th:ManagedConcept .
            BIND (EXISTS {#{self.uri.to_ref} th:extends ?xe1} as ?eo)
            BIND (EXISTS {#{self.uri.to_ref} th:subsets ?xs1} as ?so)
            BIND (EXISTS {#{self.uri.to_ref} ^th:extends ?xe2} as ?ei)
            BIND (EXISTS {#{self.uri.to_ref} ^th:subsets ?xs2} as ?si)
            BIND (EXISTS {#{self.uri.to_ref} th:isRanked ?xr1} as ?ranked)
            OPTIONAL {?ci (ba:current/bo:reference)|(ba:previous/bo:reference) #{self.uri.to_ref} . ?ci rdf:type ba:ChangeInstruction }
            OPTIONAL {?cn (ba:current/bo:reference) #{self.uri.to_ref} . ?cn rdf:type ba:ChangeNote }
            #{self.uri.to_ref} th:identifier ?i .
            BIND ("ManagedConcept" as ?type)
          }
        
        OPTIONAL{
            #{self.uri.to_ref} rdf:type th:UnmanagedConcept .                     
            OPTIONAL {?ci (ba:current/bo:reference)|(ba:previous/bo:reference) #{self.uri.to_ref} . ?ci rdf:type ba:ChangeInstruction }           
            OPTIONAL {?cn (ba:current/bo:reference) #{self.uri.to_ref} . ?cn rdf:type ba:ChangeNote }           
            #{self.uri.to_ref} th:identifier ?i .           
            BIND ("UnmanagedConcept" as ?type)
            BIND ("" as ?eo)
            BIND ("" as ?ei)
            BIND ("" as ?so)
            BIND ("" as ?si)
            BIND ("" as ?ranked)
          }
      } GROUP BY ?i ?eo ?ei ?so ?si ?ranked ?countci ?countcn ?type ORDER BY ?i 
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC, :isoT, :isoI, :ba])
    query_results.by_object_set([:i, :eo, :ei, :so, :si, :ranked, :countcn, :countci, :type]).each do |x|
      case x[:type].to_sym
        when :ManagedConcept
          indicators = { extended: x[:ei].to_bool, extends: x[:eo].to_bool, subsetted: x[:si].to_bool, subset: x[:so].to_bool, ranked: x[:ranked].to_bool, annotations: {change_notes: x[:countcn].to_i, change_instructions: x[:countci].to_i}}
        when :UnmanagedConcept
          indicators = { annotations: {change_notes: x[:countcn].to_i, change_instructions: x[:countci].to_i}}
      end
      results[:indicators] = indicators
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

  # # Other Parents. Determine if this object is connected with other parents objects other than 
  # #   the one specified. The other parents must be of the same type.
  # #
  # # @param [Object] parent the known parent item
  # # @return [Array] the other uris
  # def other_parents(parent, predicates)
  #   path = "(#{predicates.map{|x| x.to_ref}.join("/")})"
  #   query_string = %Q{
  #     SELECT DISTINCT ?s WHERE
  #     {
  #       #{parent.uri.to_ref} #{path} #{self.uri.to_ref} .
  #       #{parent.uri.to_ref} rdf:type ?t .
  #       ?s rdf:type ?t .
  #       FILTER (STR(?s) != STR(#{parent.uri.to_ref})) .
  #       ?s #{path} #{self.uri.to_ref} .
  #     }
  #   }
  #   query_results = Sparql::Query.new.query(query_string, "", [])
  #   query_results.by_object(:s)
  # end

  # Clone. Clone the object
  #
  # @return [Object] the cloned object.
  def clone
    self.tagged_links
    super
  end
  
  # Replace If No Change. Replace the current item with the previous one if there are no differences.
  #
  # @param [Object] previous the previous item
  # @param [Array] ignore_properties array of symbols of properties to be ignored in comparison
  # @return [Object] the new object if changes, otherwise the previous object
  def replace_if_no_change(previous, ignore_properties=[])
    return self if previous.nil?
    return previous unless self.diff?(previous, {ignore: [:tagged] + ignore_properties})
    replace_children_if_no_change(previous) if self.class.children_predicate?
    return self
  end

private

  # Replace children if no change. Replaces current child with the previous one if there are no difference.
  def replace_children_if_no_change(previous)
    self.children.each_with_index do |child, index|
      previous_child = previous.children.select {|x| x.identifier == child.identifier}
      next if previous_child.empty?
      self.narrower[index] = child.replace_with_no_change(previous_child)
    end
  end


end
