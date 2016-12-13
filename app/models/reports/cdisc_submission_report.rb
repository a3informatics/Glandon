class Reports::CdiscSubmissionReport

  C_CLASS_NAME = "Report::CdiscChangesReport"
  C_PER_PAGE = 10
  C_DELETED = "[ *** Submission Value Deleted *** ]"

  def create(results, user)
    @report = Reports::WickedCore.new
    @report.open("CDISC Submission Value Change Report", {}, nil, nil, user)
    html = body(results)
    @report.html_body(html)
    pdf = @report.save
    return pdf
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
    @ref = 1
    page = 1
    index = 1
    html = ""
    main_table = main_header_row(results[:versions])
    secondary_table = secondary_header_row
    html += "<h3>Conventions</h3><p>In the following table each page contains two tables. The first table indicates when a change took " +
    html += "place while the second table details the change. The changes are releated by the index thus [n].</p>"
    results[:children].each do |key, entry|
      if index % C_PER_PAGE == 0
        # Output existing
        html += "<h3>Changes</h3>" if page == 1  
        main_table += close_table
        secondary_table += close_table
        html += main_table + "<br/><br/>"
        html += secondary_table
        html += @report.page_break
        #restart
        @ref = 1
        page += 1
        main_table = main_header_row(results[:versions])
        secondary_table = secondary_header_row
      end
      main_table += main_data_row(entry)
      secondary_table += secondary_data_row(entry)
      index += 1
    end
    if index % C_PER_PAGE != 0
      main_table += close_table
      secondary_table += close_table
      html += main_table 
      html += secondary_table
    end
    return html
  end

  def main_header_row(versions)
    html = "<table class=\"general\"><thead>"
    html += "<th>Code</th>"
    html += "<th>Item</th>"
    html += "<th>Label</th>"
    html += "<th>Original Submission Value</th>"
    versions.each do |label|
      html += "<th>#{label}</th>"
    end
    html += "</tr></thead><tbody>"
    return html
  end

  def secondary_header_row
    html = "<table class=\"general-left\"><thead>"
    html += "<th>Index</th>"
    html += "<th>From</th>"
    html += "<th>To</th>"
    return html
  end

  def close_table
    return "</tbody></table>"
  end

  def main_data_row(entry)
    html = "<tr>"
    html += "<td>#{entry[:parent_identifier]}</td>"
    html += "<td>#{entry[:identifier]}</td>"
    html += "<td>#{entry[:label]}</td>"
    html += "<td>#{entry[:notation]}</td>"
    entry[:result].each do |result|
      status = result[:status]
      if status == :updated
        html += "<td>[#{@ref}]</td>"
        result[:ref] = @ref
        @ref += 1;
      else
        html += "<td>&nbsp;</td>"
      end
    end
    html += "</tr>"
    return html
  end

  def secondary_data_row(entry)
    html = ""
    entry[:result].each do |result|
      html += "<tr>"
      status = result[:status]
      if status == :updated
        current = result[:current].empty? ? C_DELETED : result[:current]
        html += "<td>[#{result[:ref]}]</td>"
        html += "<td>#{result[:previous]}</td>"
        html += "<td>#{current}</td>"
      end
      html += "</tr>"
    end
    return html
  end

end