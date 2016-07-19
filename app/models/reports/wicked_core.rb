class Reports::WickedCore

  C_CLASS_NAME = "Report::WickedCore"

  def initialize
    @html = ""
    @paper_size = ""
  end
    
  def open(doc_title, options, managed_item, history, user)
    @paper_size = user.paper_size
    @html = page_header
    @html += title_page(doc_title, managed_item, user)
    if options[:full] 
      @html += history_page(history)
    end
  end

  def html_body(html)
    @html += html
  end
  
  def page_break
    return "<p style='page-break-after:always;'></p>"
  end

def save
    @html += page_footer
    ConsoleLogger::log(C_CLASS_NAME,"save","html=#{@html}" )    
    pdf = WickedPdf.new.pdf_from_string(@html, :page_size => @paper_size, :footer => {:font_size => "10", :font_name => "Arial, \"Helvetica Neue\", Helvetica, sans-serif", :left => "", :center => "", :right => "[page] of [topage]"} )
    return pdf
  end

private

  def page_header
    html = "<html><head>"
    html += "<style>"
    html += "h1 { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 24pt; line-height: 34pt; }\n"
    html += "h1.title { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 24pt; line-height: 30pt; text-align: center; margin-top: 0; }\n"
    html += "h2 { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 18pt; line-height: 28pt; }\n"
    html += "h2.title { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 18pt; line-height: 24pt; text-align: center; margin-top: 0; }\n"
    html += "h3 { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 16pt; }\n"
    html += "h4 { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 14pt; }\n"
    html += "h5 { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 12pt; }\n"
    html += "p { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; }\n"
    html += "table tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; padding: 5px;}\n"
    html += "table.simple { border: 1px solid black; border-collapse: collapse; width: 100%;}\n"
    html += "table.simple tr td { border: 1px solid black; font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; padding: 5px;}\n"
    html += "table.simple tr th { border: 1px solid black; font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; padding: 5px;}\n"
    html += "table.form_table { border: 1px solid black; width: 100%;}\n"
    html += "table.form_table tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; padding: 5px;}\n"
    html += "table.form_table h4 { vertical-align: middle;}\n"
    html += "table.form_table td:first-child{ font: bold; }\n"
    html += "table.form_repeat { border: 1px solid black; width: 100%;}\n"
    html += "table.form_repeat th { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; }\n"
    html += "table.form_repeat tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top;}\n"
    html += "table.details tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 11pt; text-align: left; vertical-align: top; padding: 1px; }\n"
    html += "table.ci { border: 1px solid black; width: 100%; border-collapse: collapse;}\n"
    html += "table.ci tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; padding: 5px; border-bottom: 1pt solid black; }\n"
    html += ".ci td table, .ci td table tbody, .ci td table td { border:none; }\n" # Stops inheritence into markdown
    html += "table.note { border: 1px solid black; width: 100%;}\n"
    html += "table.note tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; font: bold; text-align: left; vertical-align: top; }\n"
    html += "table.input_field { border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black;}\n"
    html += "table.input_field tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 8pt; text-align: center; vertical-align: center; padding: 5px; }\n"
    html += "table.input_field td:not(:last-child){border-right: 1px dashed}\n"
    html += "table.cl_field tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: center; padding: 2px; }\n"
    html += "table.cl_field td:first-child{ border: 1px solid black; }\n"
    html += "tr.warning { background-color: #fcf8e3 !important; }\n"
    html += "table, tr, td, th, tbody, thead, tfoot {page-break-inside: avoid !important;}"
    html += "</style>"
    html += "</head><body>"
    return html
  end

  def page_footer
    html = "</body></html>"
    return html
  end

  def title_page(doc_type, managed_item, user)
    html = ""
    name = APP_CONFIG['organization_title']
    title = "#{managed_item[:label]}<br>#{managed_item[:identifier]}"
    image_file = APP_CONFIG['organization_image_file']
    dir = Rails.root.join("app", "assets", "images")
    file = File.join(dir, image_file)
    time_generated = Time.now
    # Generate HTML
    html = "<br><br><div style=\"text-align: center;\"><img src=\"#{file}\" style=\"height:75px;\"></div>"
    html += "<h2 class=\"title\">#{name}</h2>"
    html += "<br>" * 10
    html += "<h1 class=\"title\">#{doc_type}<br>#{title}</h1>"
    html += "<br>" * 23
    html += "<table class=\"details\" align=\"right\"><tr><td>Run at:</td><td>#{time_generated.strftime("%Y-%b-%d, %H:%M:%S")}</td></tr><tr><td>Run by:</td><td>#{user.email}</td></tr></table>"
    html += self.page_break
    return html
  end

  def history_page(history)
    html = ""
    if history.length > 0 
      html += page_break
      html += "<h3>Item History</h3>"
      html += "<table class=\"simple\">"
      html += "<thead><tr><th>Date</th><th>Change</th><th>Comment</th><th>References</th></tr></thead>"
      history.each do |item|
        changed_date = Timestamp.new(item[:last_changed_date]).to_date
        description = MarkdownEngine::render(item[:change_description])
        comment = MarkdownEngine::render(item[:explanatory_comment])
        refs = MarkdownEngine::render(item[:origin])
        html += "<td>#{changed_date}</td><td>#{description}</td><td>#{comment}</td><td>#{refs}</td></tr>"
      end 
      html += "</table>"
      html += page_break
    end
    return html
  end

  end