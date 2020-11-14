# Form Question. Handles the question item specfic actions.
# Based on earlier implementation.
#
# @author Clarisa Romero
# @since 3.2.0
class Form::Item::Question < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Question",
            uri_suffix: "Q",  
            uri_unique: true 

  data_property :datatype 
  data_property :format 
  data_property :mapping
  data_property :question_text 

  object_property :has_coded_value, cardinality: :many, model_class: "OperationalReferenceV3::TucReference", children: true

  validates_with Validator::Field, attribute: :format, method: :valid_format?
  validates_with Validator::Field, attribute: :mapping, method: :valid_mapping?
  validates_with Validator::Field, attribute: :question_text, method: :valid_question?

  # # Managed Ancestors Children Set. Returns the set of children nodes. Normally this is children but can be a combination.
  # #
  # # @return [Form::Group::Normal] array of objects
  # def managed_ancestors_children_set
  #   self.has_coded_value
  # end

  # Children Ordered. Provides the childen ordered by ordinal
  #
  # @return [Array] the set of children ordered by ordinal
  def children_ordered
    self.has_coded_value_objects.sort_by {|x| x.ordinal}
  end

  # Get Item
  #
  # @return [Array] An array of Question Item with CLI and CL references.
  def get_item
    blank_fields = {free_text:"", label_text:"", has_property: {}}
    item = self.to_h.merge!(blank_fields)
    item[:has_coded_value] = coded_values_to_hash(self.has_coded_value_objects)
    [item]
  end

  # To CRF
  #
  # @return [String] An html string of Question Item
  def to_crf(annotations)
    html = start_row(self.optional)
    html += question_cell(self.question_text)
    qa = question_annotations(annotations)
    html += mapping_cell(qa, annotations)
    html += self.has_coded_value.count == 0 ? input_field(self) : terminology_cell(self)
    html += end_row
    html
  end

  def question_annotations(annotations)
    return "" if annotations.nil?
    html = ""
    html += annotation_to_html(annotations)
    return html
  end

  def add_child_with_clone(params, managed_ancestor)
    if multiple_managed_ancestors?
      new_question = replicate_with_clone(self, managed_ancestor)
      new_question.add_child(params)
    else
      add_child(params)
    end
  end

  # Add Child. Adds a child or children TUC references.
  #
  # @params [Hash] params the parameters
  # @option params [String] :type the param name of the new node
  # @option params [Array] :id_set array of unmanaged concepts ids
  # @return [Array] the created objects. May contain errors if unsuccesful. 
  def add_child(params)
    if params[:type].to_sym == :tuc_reference
      results = []
      params[:id_set].each do |params|
        ordinal = next_ordinal(:has_coded_value)
        cli = Thesaurus::UnmanagedConcept.find(params[:id])
        cl = Thesaurus::ManagedConcept.find_with_properties(params[:context_id])
        child = OperationalReferenceV3::TucReference.create({local_label: cli.label, reference: cli, context: cl, ordinal: ordinal, parent_uri: self}, self)
        child.save
        self.has_coded_value_push(child.uri)
        self.save
        results << child.to_h
      end
      results
    else
      self.errors.add(:base, "Attempting to add an invalid child type")
    end 
  end

  def delete_reference(reference, managed_ancestor)
    if multiple_managed_ancestors?
      #parent = clone_nodes_and_get_new_parent(reference,managed_ancestor)
      new_parent = reference.delete_with_clone(self, managed_ancestor)
      new_parent.reset_ordinals
      new_parent = Form::Item.find_full(new_parent.id).to_h
    else
      reference.delete_with_links
      self.reset_ordinals
      question = Form::Item::Question.find_full(self.uri).to_h
      question[:has_coded_value].each do |cv|
        cv[:reference] = Thesaurus::UnmanagedConcept.find(Uri.new(uri:cv[:reference])).to_h
      end
      question
    end
  end

  # Reset Ordinals. Reset the ordinals within the enclosing parent
  #
  # @return [Boolean] true if reordered, false otherwise.
  def reset_ordinals
    local_uris = uris_by_ordinal
    return false if local_uris.empty?
    string_uris = {delete: "", insert: "", where: ""}
    local_uris.each_with_index do |s, index|
      string_uris[:delete] += "#{s.to_ref} bo:ordinal ?x#{index} . "
      string_uris[:insert] += "#{s.to_ref} bo:ordinal #{index+1} . "
      string_uris[:where] += "#{s.to_ref} bo:ordinal ?x#{index} . "
    end
    query_string = %Q{
      DELETE 
        { #{string_uris[:delete]} }
      INSERT
        { #{string_uris[:insert]} }
      WHERE 
        { #{string_uris[:where]} }
    }
puts "Q: #{query_string}"
    results = Sparql::Update.new.sparql_update(query_string, "", [:bf, :bo])
    true
  end

  private

    # def question_annotations(annotations)
    #   return "" if annotations.nil?
    #   html = ""
    #   html += annotation_to_html(annotations)
    #   return html
    # end

    def annotation_to_html(annotations)
      annotation = annotations.annotation_for_uri(self.uri.to_s)
      if !annotation.nil?
        p_class = annotations.retrieve_domain_class(annotation.domain_prefix.to_sym)
        "<p class=\"#{p_class}\">#{self.mapping}</p>"
      else
        "<p class=\"domain-other\">#{self.mapping}</p>"
      end
    end

    # Return URIs of the children objects ordered by ordinal, make sure common group marked and placed first
    def uris_by_ordinal
      query_string = %Q{
        SELECT ?s WHERE {
          {
            #{self.uri.to_ref} bf:hasCommon ?s . 
            BIND ("A" as ?type)
          } 
          UNION 
          {
            #{self.uri.to_ref} bf:hasCodedValue ?s .  
            BIND ("B" as ?type)
          }
          ?s bo:ordinal ?ordinal .
        } ORDER BY ?type ?ordinal
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo])
      query_results.by_object(:s)
    end

end