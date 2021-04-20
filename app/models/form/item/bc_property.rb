# Form Bc Property. Handles the bc property item specfic actions.
# Based on earlier implementation.
#
# @author Clarisa Romero
# @since 3.2.0
class Form::Item::BcProperty < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcProperty",
            uri_suffix: "BCP",
            uri_unique: true

  object_property :has_property, cardinality: :one, model_class: "OperationalReferenceV3"
  object_property :has_coded_value, cardinality: :many, model_class: "OperationalReferenceV3::TucReference"

  # Managed Ancestors Predicate. Returns the property(ies) from this instance/class in the managed ancestor path to the child class
  #
  # @param [Class] the child klass
  # @return [Array] array of predicates (symbols)
  def managed_ancestors_predicate(child_klass)
    return [:has_property] if child_klass == OperationalReferenceV3
    [:has_coded_value]
  end

  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    [
      "<http://www.assero.co.uk/BusinessForm#hasGroup>",
      "<http://www.assero.co.uk/BusinessForm#hasSubGroup>*",
      "<http://www.assero.co.uk/BusinessForm#hasItem>"
    ]
  end

  # Get Item
  #
  # @return [Array] An array of Bc Property Item with CLI and CL references.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:""}
    item = self.to_h.merge!(blank_fields)
    item[:has_coded_value] = coded_values_to_hash(self.has_coded_value_objects)
    item[:has_property] = property_to_hash(self.has_property_objects)
    [item]
  end

  # To CRF
  #
  # @return [String] An html string of BC Property
  def to_crf(annotations)
    html = ""
    if !is_common?
      if self.has_property_objects.enabled
        property_ref = self.has_property_objects.reference
        property = BiomedicalConcept::PropertyX.find(property_ref)
        html += start_row(self.has_property_objects.optional)
        html += question_cell(property.question_text)
        pa = property_annotations(annotations)
        html += mapping_cell(pa, annotations)
        if property.has_coded_value.length == 0
          html += input_field(property)
        else
          html += terminology_cell(self)
        end
        html += end_row
      end
    end
    return html
  end

  def info_node(ci_nodes, note_nodes, terminology)
    if !is_common?
      add_nodes(self.to_h, ci_nodes, :completion)
      add_nodes(self.to_h, note_nodes, :note)
      property_ref = self.has_property_objects.reference
      property = BiomedicalConcept::PropertyX.find(property_ref)
      self.to_h.merge!(property.to_h)
      terminology << self.to_h if self.has_coded_value.count > 0
    end
  end

  def property_annotations(annotations)
    return "" if annotations.nil?
    html = ""
    html += annotation_to_html(annotations, html)
    return html
  end

  # Make Common With Clone
  #
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Void] no return
  def make_common_with_clone(managed_ancestor)
    return nil unless common_group_present?
    if multiple_managed_ancestors?
      cgs = get_common_group
      cg = cgs.count == 1 ? clone_common_group(cgs.first, managed_ancestor) : Form::Group::Common.find(locate_common_group(managed_ancestor).first)
      make_common(cg)
    else
      cg = Form::Group::Common.find(get_common_group.first)
      make_common(cg)
    end
  end

  # Common Group Present?
  #
  # @return [Boolean] true if common group present, false otherwise
  def common_group_present?
    return true if common_group?
    self.errors.add(:base, "There is no Common group")
    false
  end

  # Children Ordered
  #
  # @return [Array] array of objects ordered by ordinal
  def children_ordered
    self.has_coded_value_objects.sort_by {|x| x.ordinal}
  end

  # To H
  #
  # @return [Hash] hash representation of the instance
  def to_h
    x = super
    x[:is_common] = is_common?
    x
  end

  # Update With Clone
  #
  # @param [Hash] params a hash of properties to be updated
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Object] returns the object. Not saved if errors are returned.
  def update_with_clone(params, managed_ancestor)
    object = super(params.except(:enabled, :optional), managed_ancestor)
    return object if object.errors.any?
    return object unless params.key?(:enabled) || params.key?(:optional)
    ref_object = object.has_property_objects.update_with_clone(params.slice(:enabled, :optional), managed_ancestor)
    object.merge_errors(ref_object)
    object
  end

  # Make Common
  #
  # @param [Object] common:group the common group into which the item is to be moved
  # @return [Object] returns the normal group
  def make_common(common_group)
    common_bcp = find_common_matches
    property = BiomedicalConcept::PropertyX.find(self.has_property_objects.reference)
    common_item = Form::Item::Common.create(label: property.alias, ordinal: common_group.next_ordinal, parent_uri: common_group.uri)
    common_group.has_item_push(common_item.uri)
    common_item.has_coded_value = []
    self.has_coded_value_objects.each do |ref|
      new_reference = ref.clone
      new_reference.uri = new_reference.create_uri(common_item.uri)
      new_reference.save
      common_item.has_coded_value << new_reference
    end
    new_property = self.has_property_objects.clone
    new_property.generate_uri(common_item.uri)
    new_property.save
    common_item.has_property = new_property
    common_bcp.each do |common_uri|
      common_item.has_common_item_push(common_uri)
    end
    common_group.save
    common_item.save
    normal_group = Form::Group::Normal.find_full(get_normal_group.first)
    normal_group = normal_group.full_data
  end

private

  def annotation_to_html(annotations, html)
    annotation = annotations.annotation_for_uri(self.uri.to_s)
    annotation.each do |a|
      p_class = annotations.retrieve_domain_class(a.domain_prefix.to_sym)
      html += "<p class=\"#{p_class}\">#{a.sdtm_variable} where #{a.sdtm_topic_variable}=#{a.sdtm_topic_value}</p>"
    end
    return html
  end

  def clone_common_group(uri, managed_ancestor)
     cg = Form::Group::Common.find(uri)
     cg.replicate_with_clone(cg, managed_ancestor)
  end

  def find_common_matches
    query_string = %Q{
      SELECT ?common_bcp WHERE
      {
        #{self.uri.to_ref} bf:hasProperty/bo:reference/bc:isA ?ref .
        #{self.uri.to_ref} ^bf:hasItem/^bf:hasSubGroup/bf:hasSubGroup/bf:hasItem ?common_bcp .
        ?common_bcp bf:hasProperty/bo:reference/bc:isA ?ref
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bc])
    check_terminologies(query_results.by_object(:common_bcp))
  end

  def check_terminologies(uris)
    query_string = %Q{
    SELECT DISTINCT ?s WHERE
      {

        VALUES ?s {#{uris.map{|x| x.to_ref}.join(" ")}}
        {
        #{self.uri.to_ref} bf:hasCodedValue/bo:reference ?cli .
        ?s bf:hasCodedValue/bo:reference ?cli
        }
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo])
    return uris if query_results.empty?
    query_results.by_object(:s)
  end

  # Get the common group
  def get_common_group
    query_string = %Q{
      SELECT ?common_group WHERE
      {
        #{self.uri.to_ref} ^bf:hasItem ?bc_group.
        ?bc_group ^bf:hasSubGroup ?normal_g.
        ?normal_g bf:hasCommon ?common_group
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf])
    query_results.by_object(:common_group)
  end

  # Get the common group
  def locate_common_group(managed_ancestor)
    query_string = %Q{
      SELECT ?cg WHERE
      {
        #{self.uri.to_ref} ^bf:hasItem/^bf:hasSubGroup ?ng.
        ?g bf:hasCommon ?cg .
        ?ng ^bf:hasSubGroup*|^bf:hasSubGroup* #{managed_ancestor.uri.to_ref}
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf])
    query_results.by_object(:cg)
  end

  # Do we have a common group?
  def common_group?
    Sparql::Query.new.query("ASK {#{self.uri.to_ref} ^bf:hasItem/^bf:hasSubGroup/bf:hasCommon ?cg }", "", [:bf]).ask?
  end

  def get_normal_group
    query_string = %Q{
      SELECT ?normal_group WHERE
      {
        #{self.uri.to_ref} ^bf:hasItem ?bc_group.
        ?bc_group ^bf:hasSubGroup ?normal_group.
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf])
    query_results.by_object(:normal_group)
  end

  def is_common?
    query_string = %Q{
      SELECT ?result WHERE {BIND ( EXISTS {#{self.uri.to_ref} ^bf:hasCommonItem ?s} as ?result )}
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf])
    query_results.by_object(:result).first.to_bool
  end

  def property_to_hash(property)
    ref = property.to_h
    ref[:reference] = BiomedicalConcept::PropertyX.find(ref[:id]).to_h
    ref
  end

 end
