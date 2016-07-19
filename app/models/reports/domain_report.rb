class Reports::DomainReport

  C_CLASS_NAME = "Report::DomainReport"

  def self.create(domain, options, history, user)
    @report = Reports::WickedCore.new
    @report.open("Domain", options, domain, history, user)
    html = body(domain)
    @report.html_body(html)
    pdf = @report.save
    return pdf
  end

  def self.body(domain)
    si = domain[:scoped_identifier]
    rs = domain[:registration_state]
    html = ""
    #ConsoleLogger::log(C_CLASS_NAME,"body","html1=#{html}" )    
    html += "<h3>Domain: #{domain[:label]} <small>#{si[:identifier]} (#{si[:version_label]}, V#{si[:version]}, #{rs[:registration_status]})</small></h3>"
    #ConsoleLogger::log(C_CLASS_NAME,"body","html2=#{html}" )    
    html += "<h3>Details</h3>"
    #ConsoleLogger::log(C_CLASS_NAME,"body","html3=#{html}" )    
    html += "<table class=\"ci\">"
    #ConsoleLogger::log(C_CLASS_NAME,"body","html4=#{html}" )    
    html += "<tr><td><strong>Prefix</strong></td><td>#{domain[:prefix]}</td></tr>"
    html += "<tr><td><strong>Structure</strong></td><td>#{domain[:structure]}</td></tr>"
    html += "<tr><td><strong>Notes</strong></td><td>#{MarkdownEngine::render(domain[:notes])}</td></tr>"
    html += "</table>"
    html += @report.page_break
    html += "<h3>Used Variables</h3>"
    html += "<table class=\"simple\">"
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
    #ConsoleLogger::log(C_CLASS_NAME,"body","html5=#{html}" )    
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
    html += @report.page_break
    html += "<h3>Unused Variables</h3>"
    html += "<table class=\"simple\">"
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
    #ConsoleLogger::log(C_CLASS_NAME,"body","html9=#{html}" )    
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
    #ConsoleLogger::log(C_CLASS_NAME,"body","html10=#{html}" )    
    return html
  end

end