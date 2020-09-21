class Form::Item::Question < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Question",
            uri_suffix: "Q",  
            uri_property: :ordinal

  data_property :datatype 
  data_property :format 
  data_property :mapping
  data_property :question_text 

  object_property :has_coded_value, cardinality: :many, model_class: "OperationalReferenceV3::TucReference"


  validates_with Validator::Field, attribute: :format, method: :valid_format?
  validates_with Validator::Field, attribute: :mapping, method: :valid_mapping?
  validates_with Validator::Field, attribute: :question_text, method: :valid_question?

  # Get Item
  #
  # @return [Hash] A hash of Question Item with CLI and CL references.
  def get_item
    blank_fields = {free_text:"", label_text:"", has_property: {}}
    item = self.to_h.merge!(blank_fields)
    item[:has_coded_value] = coded_values_to_hash(self.has_coded_value)
    return item
  end

  # To CRF
  #
  # @return [String] An html string of Question Item
  def to_crf
    html = ""
    html += start_row(self.optional)
    html += question_cell(self.question_text)
    if self.has_coded_value.count == 0
      html += input_field(self)
    else
      html += terminology_cell
    end
    html += end_row
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
        transaction = transaction_begin
        ordinal = next_ordinal(:has_coded_value)
        cli = Thesaurus::UnmanagedConcept.find(params[:id])
        cl = Thesaurus::ManagedConcept.find_with_properties(params[:context_id])
        child = OperationalReferenceV3::TucReference.create({label: cli.label, reference: cli, context: cl, ordinal: ordinal, transaction: transaction, parent_uri: self}, self)
        return child if child.errors.any?
        self.add_link(:has_coded_value, child.uri)
        transaction_execute
        results << child.to_h
      end
      results
    else
      self.errors.add(:base, "Attempting to add an invalid child type")
    end 
  end

  # def delete(parent)
  #   update_query = %Q{
  #     DELETE DATA
  #     {
  #       #{parent.uri.to_ref} bf:hasItem #{self.uri.to_ref} 
  #     };
  #     DELETE {?s ?p ?o} WHERE 
  #     { 
  #       { BIND (#{self.uri.to_ref} as ?s). 
  #         ?s ?p ?o
  #       }
  #       UNION
  #       { #{self.uri.to_ref} bf:hasCodedValue ?o1 . 
  #         BIND (?o1 as ?s) . 
  #         ?s ?p ?o .
  #       }
  #     }
  #   }
  #   partial_update(update_query, [:bf])
  #   1
  # end

  def children_ordered(child)
    self.has_coded_value_objects.sort_by {|x| x.ordinal}
  end

end