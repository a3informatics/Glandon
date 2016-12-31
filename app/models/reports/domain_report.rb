class Reports::DomainReport

  C_CLASS_NAME = "Reports::DomainReport"

  # Create the domain report
  #
  # @param domain [Domain] the domain object
  # @param options [Hash] the options
  # @param user [User] the user
  # @return [String] the HTML
  def create(domain, options, user)
    history = build_history(domain)
    @report = Reports::WickedCore.new
    @report.open("SDTM Domain", domain, history, user) #if options[:full]
    body(domain.to_json, options)
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

  def build_history(domain)
    doc_history = []
    history = IsoManaged::history(SdtmUserDomain::C_RDF_TYPE, SdtmUserDomain::C_SCHEMA_NS, {:identifier => domain.identifier, :scope_id => domain.owner_id})
    history.each do |item|
      if domain.same_version?(item.version) || domain.later_version?(item.version)
        doc_history << item.to_json
      end
    end
    return doc_history
  end

  def body(domain, options)
    si = domain[:scoped_identifier]
    rs = domain[:registration_state]
    html = ""
    html += "<h3>Domain: #{domain[:label]} <small>#{si[:identifier]} (#{si[:version_label]}, V#{si[:version]}, #{rs[:registration_status]})</small></h3>"
    html += "<h3>Details</h3>"
    html += "<table class=\"table table-striped table-bordered table-condensed\"><thead>"
    html += "<tr><td><strong>Prefix</strong></td><td>#{domain[:prefix]}</td></tr>"
    html += "<tr><td><strong>Structure</strong></td><td>#{domain[:structure]}</td></tr>"
    html += "<tr><td><strong>Notes</strong></td><td>#{MarkdownEngine::render(domain[:notes])}</td></tr>"
    html += "</table>"
    @report.add_to_body(html)
    @report.add_page_break
    html = "<h3>Used Variables</h3>"
    html += "<table class=\"table table-striped table-bordered table-condensed\"><thead>"
    html += "<thead><tr>" +
      "<th>Ordinal</th>" +
      "<th>Name</th>" +
      "<th>Label</th>" +
      "<th>Datatype</th>" +
      "<th>Role</th>" +
      "<th>Sub Role</th>" +
      "<th>Notes</th>" +
      "<th>Core</th>" +
      "</tr></thead><tbody>"
    domain[:children].each do |child|
      if child[:used] then
        html += "<tr>"
        html += "<td>#{child[:ordinal]}</td>"
        html += "<td>#{child[:name]}</td>"
        html += "<td>#{child[:label]}</td>"
        datatype = child[:datatype]
        html += "<td>#{datatype[:label]}</td>"
        html += "<td>#{child[:label]}</td>"
        html += "<td>#{child[:label]}</td>"
        html += "<td>#{MarkdownEngine::render(child[:notes])}</td>"
        compliance = child[:compliance]
        html += "<td>#{compliance[:label]}</td>"
        html += "</tr>"
      end    
    end
    html += "</tbody></table>"
    @report.add_to_body(html)
    @report.add_page_break
    html = "<h3>Unused Variables</h3>"
    html += "<table class=\"table table-striped table-bordered table-condensed\"><thead>"
    html += "<thead><tr>" +
      "<th>Ordinal</th>" +
      "<th>Name</th>" +
      "<th>Label</th>" +
      "<th>Datatype</th>" +
      "<th>Role</th>" +
      "<th>Sub Role</th>" +
      "<th>Notes</th>" +
      "<th>Core</th>" +
      "</tr></thead><tbody>"
    domain[:children].each do |child|
      if !child[:used] then
        html += "<tr>"
        html += "<td>#{child[:ordinal]}</td>"
        html += "<td>#{child[:name]}</td>"
        html += "<td>#{child[:label]}</td>"
        datatype = child[:datatype]
        html += "<td>#{datatype[:label]}</td>"
        html += "<td>#{child[:label]}</td>"
        html += "<td>#{child[:label]}</td>"
        html += "<td>#{MarkdownEngine::render(child[:notes])}</td>"
        compliance = child[:compliance]
        html += "<td>#{compliance[:label]}</td>"
        html += "</tr>"
      end    
    end
    html += "</tbody></table>"
    @report.add_to_body(html)
  end

end