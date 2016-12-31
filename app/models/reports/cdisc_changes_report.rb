class Reports::CdiscChangesReport

  C_CLASS_NAME = "Report::CdiscChangesReport"

  # Create the CDISC changes report
  #
  # @param results [Hash] the results hash
  # @param cls [Hash] the code lists
  # @param user [User] the user
  # @return [String] the HTML
  def create(results, cls, user)
    @report = Reports::WickedCore.new
    @report.open("CDISC Terminology Change Report", "", [], user)
    body(results, cls)
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

  def body(results, cls)
    html = ""
    html += "<h3>Conventions</h3>"
    html += "<p>In the following table for a code list entry:<ul><li><p>C = Code List was created in the CDISC Terminology</p></li>"
    html += "<li><p>U = Code List was updated in some way</p></li>"
    html += "<li><p>'-' = There was no change to the Code List</p></li>"
    html += "<li><p>X = The Code List was deleted from teh CDISC Terminology</p></li></ul></p>"
    html += "<h3>Changes</h3>"
    html += "<table class=\"table table-striped table-bordered table-condensed\"><thead>"
    html += "<th>Identifier</th>"
    html += "<th>Label</th>"
    html += "<th>Submission Value</th>"
    results.each do |result|
      r = result[:results]
      html += "<th>" + result[:date] + "</th>"
    end
    html += "</tr></thead><tbody>"
    cls.each do |key, cl|
      s = cl[:status]
      html += "<tr>"
      html += "<td>#{key}</td>"
      html += "<td>#{cl[:preferred_term]}</td>"
      html += "<td>#{cl[:notation]}</td>"
      s.each do |status|
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
    end
    html += "</tbody></table>"
    @report.add_to_body(html)
  end

end