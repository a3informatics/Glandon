# Form Common. Handles the common item specfic actions.
# Based on earlier implementation.
#
# @author Clarisa Romero
# @since 3.2.0
class Form::Item::Common < Form::Item::BcProperty

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#CommonItem",
            uri_suffix: "CI",  
            uri_unique: true 

  object_property :has_common_item, cardinality: :many, model_class: "Form::Item::BcProperty"

  # Get Item
  #
  # @return [Array] An array of Common Item
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:""}
    item = self.to_h.merge!(blank_fields)
    item[:has_coded_value] = coded_values_to_hash(self.has_coded_value_objects)
    item[:has_property] = self.has_property_objects.to_h
    item[:has_common_item] = common_item_to_hash(self.has_common_item_objects)
    [item]
  end

  # To CRF
  #
  # @return [String] An html string of the Common Item
  def to_crf
    html = ""
    property = BiomedicalConcept::PropertyX.find(self.has_property.reference)
    html += start_row(self.optional)
    html += question_cell(property.question_text)
    if self.has_coded_value.length == 0
      html += input_field(property)
    else
      html += terminology_cell
    end
    html += end_row
  end

  # Children Ordered. Provides the childen ordered by ordinal
  #
  # @return [Array] the set of children ordered by ordinal
  def children_ordered
    self.has_coded_value_objects.sort_by {|x| x.ordinal}
  end

  def delete(parent)
    update_query = %Q{
      DELETE DATA
      {
        #{parent.uri.to_ref} bf:hasItem #{self.uri.to_ref} 
      };
      DELETE {?s ?p ?o} WHERE 
      { 
        { BIND (#{self.uri.to_ref} as ?s). 
          ?s ?p ?o
        }
        UNION
        { #{self.uri.to_ref} bf:hasCodedValue ?o1 . 
          BIND (?o1 as ?s) . 
          ?s ?p ?o .
        }
        UNION
        { #{self.uri.to_ref} bf:hasProperty ?o2 . 
          BIND (?o2 as ?s) . 
          ?s ?p ?o .
        }
      }
    }
    partial_update(update_query, [:bf])
    parent.reset_ordinals
    common_group = Form::Group::Common.find(parent.uri)
    normal_group = Form::Group::Normal.find_full(common_group.get_normal_group)
    normal_group = normal_group.full_data
  end

  def common_item_to_hash(common_items)
    results = []
    common_items.sort_by {|x| x.ordinal}.each do |ci|
      ref = ci.to_h
      ref[:has_property] = OperationalReferenceV3.find(Uri.new(uri:ref[:has_property])).to_h
      results << ref
    end
    results
  end

end