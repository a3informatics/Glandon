class Reports::CdiscSubmissionReport

  C_CLASS_NAME = "Report::CdiscChangesReport"

  def self.create(results, user)
    @report = Reports::WickedCore.new
    @report.open("CDISC Submission Value Change Report", {}, nil, nil, user)
    html = body(results)
    @report.html_body(html)
    pdf = @report.save
    return pdf
  end

private

  def self.body(results)
    html = ""
    html += "<h3>Conventions</h3><p>In the following table for a code list entry:<ul><li><p>C = Code List was created in the CDISC Terminology</p></li><li><p>U = Code List was updated in some way</p></li>"
    html += "<li><p>'-' = There was no change to the Code List</p></li><li><p>X = The Code List was deleted from teh CDISC Terminology</p></li></ul></p><h3>Changes</h3>"
    html += "<table class=\"general\"><thead>"
    html += "<th>Code</th>"
    html += "<th>Item</th>"
    html += "<th>Label</th>"
    html += "<th>Original Submission Value</th>"
    results[:versions].each do |label|
      html += "<th>#{label}</th>"
    end
    html += "</tr></thead><tbody>"
    results[:children].each do |key, entry|
      html += "<tr>"
      html += "<td>#{entry[:parent_identifier]}</td>"
      html += "<td>#{entry[:identifier]}</td>"
      html += "<td>#{entry[:label]}</td>"
      html += "<td>#{entry[:notation]}</td>"
      entry[:result].each do |result|
        status = result[:status]
        if status == :updated
          html += "<td>U</td>"
        else
          html += "<td>-</td>"
        end
      end
      html += "</tr>"
    end
    html += "</tbody></table>"
    return html
  end

end