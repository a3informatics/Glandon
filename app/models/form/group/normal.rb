# Form Normal. Handles the normal group specfic actions.
# Based on earlier implementation.
#
# @author Clarisa Romero
# @since 3.2.0
class Form::Group::Normal < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#NormalGroup",
            uri_suffix: "NG",
            uri_unique: true

  data_property :repeating, default: false

  object_property :has_sub_group, cardinality: :many, model_classes: [ "Form::Group::Normal", "Form::Group::Bc" ]
  object_property :has_common, cardinality: :many, model_class: "Form::Group::Common"
  object_property_class :has_item, model_classes: 
    [ 
      Form::Item::Mapping, Form::Item::Placeholder, Form::Item::Question, Form::Item::TextLabel 
    ]

  validates_with Validator::Field, attribute: :repeating, method: :valid_boolean?

  # Managed Ancestors Children Set. Returns the set of children nodes. Normally this is children but can be a combination.
  #
  # @return [Form::Group::Normal] array of objects
  def managed_ancestors_children_set
    self.has_sub_group + self.has_item + self.has_common
  end

  # Children Ordered. Returns the set of children nodes ordered by ordinal. 
  #
  # @return [Form::Group::Normal] array of objects
  def children_ordered
    set = self.has_sub_group_objects + self.has_item_objects
    set.sort_by {|x| x.ordinal}
  end

  # Get Item
  #
  # @return [Array] Array of hashes, one per group, sub group and item.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: {}}
    group = self.to_h.merge!(blank_fields)
    group.delete(:has_sub_group)
    group.delete(:has_item)
    group[:has_common] = []
    results = [group]
    self.has_common.sort_by {|x| x.ordinal}.each do |cm|
      results += cm.get_item
    end
    children_ordered.each do |node|
      results += node.get_item
    end
    results
  end

  # To CRF
  #
  # @return [String] An html string of Normal group
  def to_crf
    html = ""
    html += text_row(self.label)
    if self.repeating && self.is_question_only_group?
      html += repeating_question_group
    elsif self.repeating && self.is_bc_only_group?
      html += repeating_bc_group
    else
      self.has_common.sort_by {|x| x.ordinal}.each do |cm|
        html += cm.to_crf
      end
      children_ordered.each do |node|
        html += node.to_crf
      end
    end
    return html
  end

  def add_child_with_clone(params, managed_ancestor)
    if multiple_managed_ancestors?
      new_normal = replicate_with_clone(managed_ancestor)
      new_normal.add_child(params)
    else
      add_child(params)
    end
  end

  # Add Child.
  #
  # @params [Hash] params the parameters
  # @option params [String] :type the param name of the new node
  # @option params [Array] :id_set array of biomedical concept ids
  # @return [Array] the created objects. May contain errors if unsuccesful.  
  def add_child(params)
    if params[:type].to_sym == :normal_group
      add_normal_group
    elsif params[:type].to_sym == :bc_group
      results = []
      params[:id_set].each do |id|
        results << add_bc_group(id)
      end
      results
    elsif params[:type].to_sym == :common_group
      add_common_group
    elsif items.include?params[:type].to_sym
      add_item(params)
    else
      self.errors.add(:base, "Attempting to add an invalid child type")
      []
    end
  end

  # Is a Question only group
  def is_question_only_group?
    if self.class == Form::Group::Normal
      self.has_sub_group.each do |sg|
        sg.is_question_only_group? if sg.class == Form::Group::Normal
      end
    end
    self.has_item.each do |item|
      return true if item.class == Form::Item::Question || item.class == Form::Item::Mapping || item.class == Form::Item::TextLabel 
    end
    return false
  end

  # Is a BC only group
  def is_bc_only_group?
    self.has_item.each do |item|
      return false if item.class != Form::Item::BcProperty
    end
    if self.class == Form::Group::Normal
      self.has_sub_group.each do |sg|
        sg.is_bc_only_group? if sg.class == Form::Group::Normal
      end
    end
    return true
  end

  # Repeating Question group
  def repeating_question_group
    html = ""
    # Put the labels and mappings out first
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      html += sg.repeating_question_group
    end
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.to_crf unless item.class == Form::Item::Question
    end
    # Now the questions
    html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.question_cell(item.question_text) if item.class == Form::Item::Question
    end
    html += '</tr>'
    html += '<tr>'
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += input_field(item) if item.class == Form::Item::Question
    end
    html += '</tr>'
    html += '</table></td>' 
    return html
  end

  # Repeating BC group
  def repeating_bc_group
    html = ""
    html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    columns = {}
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      sg.has_item.sort_by {|x| x.ordinal}.each do |item|
        property = BiomedicalConcept::PropertyX.find(item.has_property.reference)
        #if property.enabled && property.collect
          if !columns.has_key?(property.is_a.to_s)
            columns[property.is_a.to_s] = property.is_a.to_s
          end
        #end
      end
    end
    # Question text
    html += start_row(false)
    self.has_sub_group.first.has_item.sort_by {|x| x.ordinal}.each do |item|
      property = BiomedicalConcept::PropertyX.find(item.has_property.reference)
      if columns.has_key?(property.is_a.to_s)
        html += item.question_cell(property.question_text)
      end
    end
    html += end_row
    # BCs and the input fields
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      html += start_row(false)
      sg.has_item.sort_by {|x| x.ordinal}.each do |item|
        property = BiomedicalConcept::PropertyX.find(item.has_property.reference)
        if columns.has_key?(property.is_a.to_s)
          if property.has_coded_value.length == 0
            html += input_field(property)
          else
            html += terminology_cell(item)
          end
        end
      end
      html += end_row
      html += start_row(false)
      html += end_row
    end
    html += '</tr>'
    html += '</table></td>'
    return html
  end

  # Format input field
  def input_field(item)
    html = '<td>'
    if item.class == BiomedicalConcept::PropertyX
      prop = ComplexDatatype::PropertyX.find(item.is_complex_datatype_property)
      datatype = XSDDatatype.new(prop.simple_datatype)
    else
      datatype = XSDDatatype.new(item.datatype)
    end
      if datatype.datetime?
        html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y", "", "H", "H", ":", "M", "M"])
      elsif datatype.date?
       html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y"])
      elsif datatype.time?
       html += field_table(["H", "H", ":", "M", "M"])
      elsif datatype.float?
        item.format = "5.1" if item.format.blank?
        parts = item.format.split('.')
        major = parts[0].to_i
        minor = parts[1].to_i
        pattern = ["#"] * major
        pattern[major-minor-1] = "."
        html += field_table(pattern)
      elsif datatype.integer?
        count = item.format.to_i
        html += field_table(["#"]*count)
      elsif datatype.string?
        length = item.format.scan /\w/
        html += field_table([" "]*5 + ["S"] + length + [""]*5)
      elsif datatype.boolean?
        html += '<input type="checkbox">'
      else
        html += field_table(["?", "?", "?"])
      end
      html += '</td>'
  end

  # Format a field
  def field_table(cell_content)
    html = "<table class=\"crf-input-field\"><tr>"
    cell_content.each do |cell|
      html += "<td>#{cell}</td>"
    end
    html += "</tr></table>"
  end

  def terminology_cell(item)
    html = '<td>'
    item.has_coded_value.sort_by {|x| x.ordinal}.each do |cv|
      tc = Thesaurus::UnmanagedConcept.find(cv.reference)
      if cv.enabled
        html += "<p><input type=\"radio\" name=\"#{tc.identifier}\" value=\"#{tc.identifier}\"></input>#{tc.label}</p>"
      end
    end
    html += '</td>'
  end

  def start_row(optional)
    return '<tr class="warning">' if optional
    return '<tr>'
  end

  def end_row
    return "</tr>"
  end

  def delete(parent, managed_ancestor)
    parent = super(parent, managed_ancestor)
    parent = Form.find_full(parent.uri)
    parent = parent.full_data
  end

  # Full Data
  #
  # @return [Hash] Return the data of the whole parent Normal Group, all its children BC Groups, Common Group + any referenced item data.
  def full_data
    result = self.to_h
    result[:has_sub_group] = []
    result[:has_item] = []
    result[:has_common] = []
    self.has_item_objects.sort_by {|x| x.ordinal}.each do |item|
      result[:has_item] << item.full_data
    end
    self.has_sub_group_objects.sort_by {|x| x.ordinal}.each do |sg|
      result[:has_sub_group] << sg.full_data
    end
    self.has_common_objects.sort_by {|x| x.ordinal}.each do |cg|
      result[:has_common] << cg.full_data 
    end
    result
  end

  private
    
    def add_bc_group(id)
      tx = transaction_begin
      bci = BiomedicalConceptInstance.find(id)
      bc_group = Form::Group::Bc.create(label: bci.label, ordinal: next_ordinal, parent_uri: self.uri, transaction: tx)
      bc_reference = OperationalReferenceV3.create({reference: bci.uri, transaction: tx}, bc_group)
      bc_reference.save
      bc_group.has_biomedical_concept = bc_reference
      bc_group.save
      ordinal = 1
      bci.has_item_objects.sort_by {|x| x.ordinal}.each do |item|
        next unless item.enabled && item.collect
        item.has_complex_datatype_objects.each do |cdt|
          cdt.has_property_objects.sort_by {|x| x.label}.reverse.each do |property|
            bc_property = Form::Item::BcProperty.create(label: property.alias, parent_uri: bc_group.uri, ordinal: ordinal, transaction: tx)
            bc_group.has_item_push(bc_property)
            add_bc_property(property, bc_property)
            bc_group.add_link(:has_item, bc_property.uri)
            ordinal += 1
          end 
        end
      end
      self.add_link(:has_sub_group, bc_group.uri)
      transaction_execute
      bc_group.has_item_objects.each do |bc_property|
        check_if_common(bc_property)
      end
      bc_group = Form::Group::Bc.find_full(bc_group.uri).to_h
      bc_group[:has_item].each do |item|
        item[:has_coded_value].each do |cv|
          cv[:reference] = Thesaurus::UnmanagedConcept.find(Uri.new(uri:cv[:reference])).to_h
        end
      end
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: bc_group[:has_biomedical_concept][:reference]))
      bc_group[:has_biomedical_concept][:reference] = bci.to_h
      bc_group
    end

    def add_bc_property(property, bc_property)
      bc_property_reference = OperationalReferenceV3.create({reference: property.uri}, bc_property)
      bc_property.has_property = bc_property_reference
      bc_property.add_link(:has_property, bc_property_reference.uri)
      property.has_coded_value_objects.sort_by {|x| x.ordinal}.each_with_index do |cv_ref, indx|
        cli = Thesaurus::UnmanagedConcept.find_full(cv_ref.reference)
        cl = Thesaurus::ManagedConcept.find_with_properties(cv_ref.context)
        coded_value_reference = OperationalReferenceV3::TucReference.create({local_label: cli.label, reference: cli.uri, context: cl.uri, ordinal: indx+1}, bc_property)
        bc_property.has_coded_value_push(coded_value_reference)
      end
      bc_property.save
    end

    def add_normal_group
      child = Form::Group::Normal.create(label: "Not set", ordinal: next_ordinal, parent_uri: self.uri)
      self.add_link(:has_sub_group, child.uri)
      child
    end

    def add_common_group
      unless common_group?
        child = Form::Group::Common.create(label: "Not set", ordinal: 1, parent_uri: self.uri)
        self.add_link(:has_common, child.uri)
        self.reset_ordinals
        child
      else
        self.errors.add(:base, "Normal group already contains a Common Group")
      end
    end

    def common_group?
      query_string = %Q{         
        SELECT ?result WHERE {BIND ( EXISTS {#{self.uri.to_ref} bf:hasCommon ?c_g  } as ?result )}
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:result).first.to_bool
    end

    def add_item(params)
      child = type_to_class[params[:type].to_sym].create(label: "Not set", ordinal: next_ordinal, parent_uri: self.uri)
      child.save
      self.add_link(:has_item, child.uri)
      child
    end

    def check_if_common(bc_property)
      unless self.has_common.empty?
        common_group = Form::Group::Common.find(self.has_common.first)
        common_group.has_item_objects.each do |common_item|
          if common_property?(bc_property, common_item) && bc_property.has_coded_value.empty?
            make_common(common_item, common_group, bc_property)
          elsif common_property?(bc_property, common_item) && common_terminologies?(bc_property, common_item)
            make_common(common_item, common_group, bc_property) 
          end
        end
      end 
    end

    def make_common(common_item, common_group, bc_property)
      common_item.add_link(:has_common_item, bc_property.uri)
      common_item.has_common_item_push(bc_property.uri)
      common_group.save
      common_item.save
    end

    def common_property?(bc_property,common_item)
      query_string = %Q{         
        SELECT ?result WHERE
        {BIND ( EXISTS {#{bc_property.uri.to_ref} bf:hasProperty/bo:reference/bc:isA ?ref. 
                        #{common_item.uri.to_ref} bf:hasProperty/bo:reference/bc:isA ?ref } as ?result )} 
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bc])
      query_results.by_object(:result).first.to_bool
    end

    def common_terminologies?(bc_property, common_item)
      query_string = %Q{
        SELECT ?result WHERE
        {BIND ( EXISTS {#{bc_property.uri.to_ref} bf:hasCodedValue/bo:reference ?cli. 
                        #{common_item.uri.to_ref} bf:hasCodedValue/bo:reference ?cli } as ?result )} 
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo])
      query_results.by_object(:result).first.to_bool
    end 

    def type_to_class
      {question: Form::Item::Question, text_label: Form::Item::TextLabel, placeholder: Form::Item::Placeholder, mapping: Form::Item::Mapping}
    end

    def items
      items = [:text_label, :placeholder, :mapping, :question]
    end
end