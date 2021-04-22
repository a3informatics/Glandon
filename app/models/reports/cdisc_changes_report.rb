# Report CDISC Changes Report
#
# @author Dave Iberson-Hurst
# @since 2.20.0
class Reports::CdiscChangesReport

  C_CLASS_NAME = "Report::CdiscChangesReport"
  C_FIRST_PAGE = 5
  C_PER_PAGE = 9

  # Create the CDISC changes report
  #
  # @param [Hash] results the results hash
  # @param [User] user the current user
  # @return [String] the HTML for the report
  def create(results, user, base_url)
    @report = Reports::WickedCore.new
    @report.open("CDISC Terminology Change Report", "", [], user, base_url)
    body(results)
    @report.close
    return @report.html
  end

  if Rails.env == "test"
    # Return the current HTML. Only available for testing.
    #
    # @return [String] The HTML
    def html
      return @report.html
    end
  end

private

  def body(results)
    html = ""
    html += "<h3>Conventions</h3>"
    html += "<p>In the following table for a code list entry:<ul><li><p>C = Code List was created in the CDISC Terminology</p></li>"
    html += "<li><p>U = Code List was updated in some way</p></li>"
    html += "<li><p>'-' = There was no change to the Code List</p></li>"
    html += "<li><p>X = The Code List was deleted from the CDISC Terminology</p></li></ul></p>"
    index = 0
    page_count = C_FIRST_PAGE
    results[:items].each do |key, cl|
      if index % page_count == 0
        if index == 0
          html += "<h3>Changes</h3>"
        else
          html += "</tbody></table>"
          @report.add_to_body(html)
          @report.add_page_break
          page_count = C_PER_PAGE
          html = ""
          index = 1
        end
        html += "<table class=\"table table-striped table-bordered table-condensed\"><thead>"
        html += "<th>Identifier</th>"
        html += "<th>Label</th>"
        html += "<th>Submission Value</th>"
        results[:versions].each do |version|
          html += "<th>" + version + "</th>"
        end
        html += "</tr></thead><tbody>"
      end
      html += "<tr>"
      html += "<td>#{key}</td>"
      html += "<td>#{cl[:label]}</td>"
      html += "<td>#{cl[:notation]}</td>"
      cl[:status].each do |entry|
        status = entry[:status]
        if status == :created
          html += "<td>C</td>"
        elsif status == :no_change
          html += "<td>-</td>"
        elsif status == :updated
          html += "<td>U</td>"
        elsif status == :deleted
          html += "<td>X</td>"
        elsif status == :not_present
          html += "<td>&nbsp;</td>"
        else
          html += "<td>[#{status}]></td>"
        end
      end
      html += "</tr>"
      index += 1
    end
    @report.add_to_body(html)
  end

end
