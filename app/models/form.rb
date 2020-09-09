# require 'odm'
class Form < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Form",
            uri_suffix: "F"

  data_property :note
  data_property :completion

  object_property :has_group, cardinality: :many, model_class: "Form::Group::Normal", children: true

  # Get Items. 
  #
  # @return [Array] Array of hashes, one per group, sub group and item. Ordered by ordinal.
  def get_items
    results = []
    form = self.class.find_full(self.uri)
    form.has_group.sort_by {|x| x.ordinal}.each do |group|
      results += group.get_item
    end
    return results
  end

  # To CRF. 
  #
  # @return [String] String of HTML form representation
  def to_crf
    form = self.class.find_full(self.uri)
    html = ''
    html += get_css
    html += '<table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    html += '<td colspan="2"><h4>' + form.label + '</h4></td>'
    html += '</tr>'
    form.has_group.sort_by {|x| x.ordinal}.each do |group|
      html += group.to_crf
    end
    html += '</table>'
  end

  # Get Referenced Items. 
  #
  # @return [Array] Array of hashes, 
  def get_referenced_items
    items = []
    results = []
    form = self.class.find_full(self.uri)
    form.has_group.sort_by {|x| x.ordinal}.each do |group|
      items += group.get_item
    end
    items = items.each do |item|
      if item[:rdf_type] == "http://www.assero.co.uk/BusinessForm#Question" || item[:rdf_type] == "http://www.assero.co.uk/BusinessForm#BcProperty"
        item[:has_coded_value].each do |cv|
          results << cv[:reference].reverse_merge!({reference_id: cv[:id]})
        end
      end
    end
    return results
  end

  private
    def get_css
      html = "<style>"
      html += "table.crf-input-field { border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black;}\n"
      html += "table.crf-input-field tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 8pt; text-align: center; " 
      html += "vertical-align: center; padding: 5px; }\n"
      html += "table.crf-input-field td:not(:last-child){border-right: 1px dashed}\n"
      html += "h4.domain-1 {border-radius: 5px; background: #A3E4D7; padding: 5px; }\n"
      html += "p.domain-1 {border-radius: 5px; background: #A3E4D7; padding: 5px; }\n"
      html += "h4.domain-2 {border-radius: 5px; background: #AED6F1; padding: 5px; }\n"
      html += "p.domain-2 {border-radius: 5px; background: #AED6F1; padding: 5px; }\n"
      html += "h4.domain-3 {border-radius: 5px; background: #D2B4DE; padding: 5px; }\n"
      html += "p.domain-3 {border-radius: 5px; background: #D2B4DE; padding: 5px; }\n"
      html += "h4.domain-4 {border-radius: 5px; background: #FAD7A0; padding: 5px; }\n"
      html += "p.domain-4 {border-radius: 5px; background: #FAD7A0; padding: 5px; }\n"
      html += "h4.domain-5 {border-radius: 5px; background: #F5B7B1; padding: 5px; }\n"
      html += "p.domain-5 {border-radius: 5px; background: #F5B7B1; padding: 5px; }\n"
      html += "h4.domain-other {border-radius: 5px; background: #BDC3C7; padding: 5px; }\n"
      html += "p.domain-other {border-radius: 5px; background: #BDC3C7; padding: 5px; }\n"
      html += "</style>"
    end

end
