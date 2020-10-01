class Form::Group::Bc < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcGroup",
            uri_suffix: "BCG",
            uri_unique: true

  object_property :has_biomedical_concept, cardinality: :one, model_class: "OperationalReferenceV3"

  object_property_class :has_item, model_classes: 
    [ 
      Form::Item::BcProperty, Form::Item::Common
    ]

  # Get Item
  #
  # @return [Array] Array of hashes, one per group, sub group and item.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: {}}
    group = self.to_h.merge!(blank_fields)
    begin
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: group[:has_biomedical_concept][:reference]))
    rescue => e
      group.delete(:has_biomedical_concept)
    else
      group[:has_biomedical_concept][:reference] = bci.to_h
    end
    #bci = BiomedicalConceptInstance.find(Uri.new(uri: group[:has_biomedical_concept][:reference]))
    #group[:has_biomedical_concept][:reference] = bci.to_h
    group.delete(:has_item)
    results = [group]
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      results << item.get_item
    end
    results
  end

  # To CRF
  #
  # @return [String] An html string of BC Group
  def to_crf
    html = ""
    html += text_row(self.label)
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.to_crf
    end
    return html
  end

  def delete(parent)
    unless parent.has_common.empty?
      common_group = Form::Group::Common.find(parent.has_common.first)
      string_uris = ""
      common_group.has_item_objects.each do |common_item|
        self.has_item_objects.each do |item|
          string_uris += "#{common_item.uri.to_ref} bf:hasCommonItem #{item.uri.to_ref} . "
        end
      end
    end 
    update_query = %Q{
      DELETE DATA
      {
        #{string_uris} 
      };
      DELETE {?s ?p ?o} WHERE 
      { 
        { #{self.uri.to_ref} bf:hasItem/bf:hasProperty ?o1 . 
          BIND (?o1 as ?s) . 
          ?s ?p ?o .
        }
        UNION
        { #{self.uri.to_ref} bf:hasItem/bf:hasCodedValue ?o2 . 
          BIND (?o2 as ?s) . 
          ?s ?p ?o .
        }
      }
    }
    partial_update(update_query, [:bf])
    super
  end

  def children_ordered
    self.has_item_objects.sort_by {|x| x.ordinal}
  end

  def items_classes
    items_classes = [Form::Item::BcProperty, Form::Item::Common]
  end

end