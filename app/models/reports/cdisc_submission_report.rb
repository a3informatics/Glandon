# Report CDISC Submission Report
#
# @author Dave Iberson-Hurst
# @since 2.20.0
class Reports::CdiscSubmissionReport

  C_CLASS_NAME = "Report::CdiscChangesReport"
  C_PER_PAGE = 5
  C_DELETED = "[ *** Submission Value Deleted *** ]"

  # Create the domain report
  #
  # @param [Hash] results the submission changes report
  # @param [User] user the current user
  # @return [String] the HTML
  def create(results, user)
    @report = Reports::WickedCore.new
    @report.open("CDISC Submission Value Change Report", "", [], user)
    body(results)
    @report.close
    return @report.html
  end

  # ---------
  # Test Only
  # ---------
  if Rails.env == "test"
  
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
    html += "<h3>Conventions</h3>"
    html += "<p>In the following table each page contains two tables. The first table indicates when a change took "
    html += "place while the second table details the change. The changes are releated by the index thus [n].</p>"
    html += "<h3>Changes</h3>"
    results[:items].each do |key, entry|
      if index % C_PER_PAGE == 0
        # Output existing
        main_table += close_table
        secondary_table += close_table
        html += main_table + "<br/><br/>"
        html += secondary_table
        @report.add_to_body(html)
        @report.add_page_break
        #restart
        html = ""
        @ref = 1
        page += 1
        main_table = main_header_row(results[:versions])
        secondary_table = secondary_header_row
      end
      main_table += main_data_row(entry)
      secondary_table += secondary_data_row(entry)
      index += 1
    end
    if @ref > 1
      main_table += close_table
      secondary_table += close_table
      html += main_table 
      html += secondary_table
    end
    @report.add_to_body(html)
  end

  def main_header_row(versions)
    html = "<table class=\"table table-striped table-bordered table-condensed\"><thead><tr>"
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
    html = "<table class=\"table table-striped table-bordered table-condensed\"><thead><tr>"
    html += "<th>Index</th>"
    html += "<th>From</th>"
    html += "<th>To</th>"
    html += "</tr></thead><tbody>"
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
    entry[:status].each do |result|
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
    entry[:status].each do |result|
      html += "<tr>"
      status = result[:status]
      if status == :updated
        current = result[:notation].empty? ? C_DELETED : result[:notation]
        html += "<td>[#{result[:ref]}]</td>"
        html += "<td>#{result[:previous]}</td>"
        html += "<td>#{current}</td>"
      end
      html += "</tr>"
    end
    return html
  end

end