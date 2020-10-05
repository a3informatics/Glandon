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
  # @return [Hash] A hash of Common Item
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: {}}
    return self.to_h.merge!(blank_fields)
  end

  # To CRF
  #
  # @return [String] An html string of the Common Item
  def to_crf
    html = ""
    #common_item = self.has_common_item.first
    property = BiomedicalConcept::PropertyX.find(self.has_property.reference)
    html += start_row(self.optional)
    html += question_cell(property.question_text)
    if self.has_coded_value.length == 0
      html += input_field(property)
    else
      html += terminology_cell(self)
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
    normal_group = normal_group.full_data(normal_group.to_h)
  end

  private

    def terminology_cell(property)
      html = '<td>'
      property.has_coded_value_objects.each do |cv|
        op_ref = OperationalReferenceV3.find(cv.uri)
        tc = Thesaurus::UnmanagedConcept.find(op_ref.reference)
        if op_ref.enabled
          html += "<p><input type=\"radio\" name=\"#{tc.identifier}\" value=\"#{tc.identifier}\"></input>#{tc.label}</p>"
        end
      end
      html += '</td>'
    end

end