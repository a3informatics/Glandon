# Form CRF. Mixin to handle CRF actions
#
# @author Clarisa Romero
# @since 3.3.0
class Form
  
  module CRF

    def domain_count
      5
    end

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
  def repeating_question_group(annotations)
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

    unless annotations.nil?
      html += '<tr>'
      self.has_item.sort_by {|x| x.ordinal}.each do |item|
        if item.class == Form::Item::Question
          qa = item.question_annotations(annotations)
          html += mapping_cell(qa, annotations)
        else
          html += empty_cell
        end
      end
      html += '</tr>'
    end

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
      datatype = nil
      if item.class == BiomedicalConcept::PropertyX
        if item.is_complex_datatype_property.nil?
          datatype = nil
        else
          prop = ComplexDatatype::PropertyX.find(item.is_complex_datatype_property)
          datatype = XSDDatatype.new(prop.simple_datatype)
        end
      else
        datatype = XSDDatatype.new(item.datatype)
      end
      if datatype.nil?
        html += field_table(["?", "?", "?"])
      elsif datatype.datetime?
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
      item.has_coded_value_objects.sort_by {|x| x.ordinal}.each do |cv|
        tc = Thesaurus::UnmanagedConcept.find(cv.reference)
        if cv.enabled
          html += "<p><input type=\"radio\" name=\"#{tc.identifier}\" value=\"#{tc.identifier}\"></input>#{tc.label}</p>"
        end
      end
      html += '</td>'
    end

    # def terminology_cell
    #   html = '<td>'
    #   self.has_coded_value_objects.sort_by {|x| x.ordinal}.each do |cv|
    #     tc = Thesaurus::UnmanagedConcept.find(cv.reference)
    #     if cv.enabled
    #       html += "<p><input type=\"radio\" name=\"#{tc.identifier}\" value=\"#{tc.identifier}\"></input>#{tc.label}</p>"
    #     end
    #   end
    #   html += '</td>'
    # end

    def start_row(optional)
      return '<tr class="warning">' if optional
      return '<tr>'
    end

    def end_row
      return "</tr>"
    end

    def markdown_row(markdown)
      return "<tr><td colspan=\"3\"><p>#{MarkdownEngine::render(markdown)}</p></td></tr>"
    end

    def question_cell(text)
      return "<td>#{text}</td>"
    end

    def mapping_cell(text, annotations)
      return "<td>#{text}</td>" if !text.empty? && !annotations.nil?
      return empty_cell
    end

    def empty_cell
      return "<td></td>"
    end

    def text_row(text)
      return "<tr><td colspan=\"3\"><h5>#{text}</h5></td></tr>"
    end

  end

end