class Reports::WickedCore

  C_CLASS_NAME = "Report::WickedCore"

  def initialize
    @html = ""
    @paper_size = ""
  end
    
  # Open the document
  #
  # @param doc_type [String] The document type, a title string
  # @param managed_item [Hash] Managed item. Can be empty
  # @param user [Object] The user creating the report
  # @return [Null]
  def open(doc_type, title, history, user)
    @paper_size = user.paper_size
    @html = page_header
    @html += title_page(doc_type, title, user)
    @html += history_page(history) if !history.empty?
  end

  # Add to the body
  #
  # @return [Null]
  def add_to_body(html)
    @html += html
  end
  
  # Insert page break
  #
  # @return [Null]
  def add_page_break
    @html += page_break
  end

  # Close up the HTML
  #
  # @return [Null] 
  def close
    @html += page_footer
  end

  # Get the PDF
  #
  # @return [Object] The PDF document
  def pdf
    footer = 
    {
      :font_size => "8", 
      :font_name => "Arial, \"Helvetica Neue\", Helvetica, sans-serif", 
      :left => "", 
      :center => "", 
      :right => "[page] of [topage]"
    }
    pdf = WickedPdf.new.pdf_from_string(@html, :page_size => @paper_size, :footer => footer )
    return pdf
  end

  # Return the current HTML.
  #
  # @return [String] The HTML
  def html
    return @html
  end
  
private

  def page_header
    html = "<html><head>"
    html += "</head><body>"
    return html
  end

  def page_footer
    html = "</body></html>"
    return html
  end

  def title_page(doc_type, title,  user)
    html = ""
    #title = ""
    #name = APP_CONFIG['organization_title']
    #image_file = APP_CONFIG['organization_image_file']
    name = ENV['organization_title']
    image_file = ENV['organization_image_file']
    dir = Rails.root.join("app", "assets", "images")
    file = File.join(dir, image_file)
    time_generated = Time.now
    # Generate HTML
    html = "<div style=\"vertical-align:middle; text-align:center\"><img height=\"75\" src=\"#{file}\"></div>"
    html += "<h3 class=\"text-center col-md-12\">#{name}</h3>"
    html += "<br>" * 10
    html += "<div class=\"text-center col-md-12\"><h1>#{doc_type}<h1><h3>#{title}</h3></div>"
    html += "<br>" * 5
    html += "<div class=\"text-center col-md-12\"><p>Run at: #{time_generated.strftime("%Y-%b-%d, %H:%M:%S")}</p></div>"
    html += "<div class=\"text-center col-md-12\"><p>Run by: #{user.email}</p></div>"
    html += page_break
    return html
  end

  def history_page(history)
    html = ""
    if history.length > 0 
      html += "<h3>Item History</h3>"
      html += "<table class=\"table table-striped table-bordered table-condensed\">"
      html += "<thead><tr><th>Date</th><th>Change</th><th>Comment</th><th>References</th></tr></thead><tbody>"
      history.each do |item|
        changed_date = Timestamp.new(item[:last_changed_date]).to_date
        description = MarkdownEngine::render(item[:change_description])
        comment = MarkdownEngine::render(item[:explanatory_comment])
        refs = MarkdownEngine::render(item[:origin])
        html += "<tr><td>#{changed_date}</td><td>#{description}</td><td>#{comment}</td><td>#{refs}</td></tr>"
      end 
      html += "</tbody></table>"
      html += page_break
    end
    return html
  end

  def page_break
    return "<div style='page-break-after:always;'></div>"
  end
  
end