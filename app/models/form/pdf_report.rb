# Form PDF report. Mixin to handle report actions
#
# @author Clarisa Romero
# @since 4.1.0
class Form

  module PDFReport

    # Create the CRF report
    #
    # @param [Form] form the form object
    # @param [Hash] options the options for the report
    # @param [User] user the user running the report
    # @return [String] the HTML
    def create(form, html, user, base_url)
      history = build_history(form)
      @report = Reports::WickedCore.new
      @report.open("Case Report Form", "", history, user, base_url)
      crf_title(form)
      crf_body(html)
      completion_notes_and_term(form)
      @report.close
      return @report.html
    end

    if Rails.env.test?
      # Return the current HTML. Only available for testing.
      #
      # @return [String] the HTML
      def html
        return @report.html
      end
    end

  private

    def build_history(form)
      history_results = []
      history = Form.history(identifier: form.has_identifier.identifier, scope: form.scope)
      history.each do |item|
        #if form.same_version?(item) || form.later_version?(item)
          history_results << item.to_h
        #end
      end
      return history_results
    end

    def crf_title(form)
      html = "<h3>Form: #{form.label} <small>#{form.has_identifier.identifier} (#{form.semantic_version})</small></h3>"
      @report.add_to_body(html)
    end

    def crf_body(html)
      @report.add_to_body(html)
      @report.add_page_break
    end

    def completion_notes_and_term(form)
      html = ""
      ci_nodes = []
      note_nodes = []
      terminology = []
      form.info_node(ci_nodes, note_nodes, terminology)
      # Completion instructions
      if ci_nodes.length > 0
        html += "<h3>Completion Instructions</h3>"
        html += "<table class=\"table table-striped table-bordered table-condensed\">"
        ci_nodes.each do |item|
          node = item[:node]
          if node[:optional]
            html += "<tr class=\"warning\">"
          else
            html += "<tr>"
          end
          html += "<td><strong>#{node[:label]}</strong></td><td>#{item[:html]}</td></tr>"
        end
        html += "</table>"
      end
      @report.add_to_body(html)
      # Notes
      html = ""
      if note_nodes.length > 0
        @report.add_page_break
        html += "<h3>Notes</h3>"
        html += "<table class=\"table table-striped table-bordered table-condensed\">"
        note_nodes.each do |item|
          node = item[:node]
          if node[:optional]
            html += "<tr class=\"warning\">"
          else
            html += "<tr>"
          end
          html += "<td><strong>#{node[:label]}</strong></td><td>#{item[:html]}</td></tr>"
        end
        html += "</table>"
      end
      @report.add_to_body(html)
      # Terminology
      html = ""
      if terminology.length > 0
        @report.add_page_break
        html += "<h3>Terminology</h3>"
        html += "<table class=\"table table-striped table-bordered table-condensed\">"
        html += "<thead><tr><th>Question</th><th>Identifier</th><th>Submission Value</th><th>Preferred Term</th></tr></thead>"
        terminology.each do |node|
          class_text = ""
          class_text = " class=\"warning\"" if node[:optional]
          node[:has_coded_value].each do |child|
            tuc = OperationalReferenceV3::TucReference.find(Uri.new(uri:child))
            if tuc.enabled
              html += "<tr#{class_text}>"
              if node[:has_coded_value].first == child
                html += "<td rowspan=\"#{node[:has_coded_value].count}\">#{node[:question_text]}</td>"
              end
              tc = Thesaurus::UnmanagedConcept.find(tuc.reference)
              html += "<td>#{tc.identifier}</td><td>#{tc.notation}</td><td>#{tc.preferred_term_objects.label}</td>"
              html += "</tr>"
            end
          end
        end
        html += "</table>"
        @report.add_to_body(html)
      end
    end

    def add_nodes(node, nodes, field)
      text = node[field]
      nodes << {:node => node, :html => MarkdownEngine::render(text)} unless text.empty?
    end

  end

end
