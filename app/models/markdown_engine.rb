class MarkdownEngine
  
  #include ActiveModel::Naming
  #include ActiveModel::Conversion
  #include ActiveModel::Validations
      
  # Constants
  C_CLASS_NAME = "MarkdownEngine" 
  
  def self.render(markdown)
    return "" if markdown.nil?
    ConsoleLogger::log(C_CLASS_NAME,"render", "markdown(1)=" + markdown)
    return "" if markdown == ""
    ConsoleLogger::log(C_CLASS_NAME,"render", "markdown(2)=" + markdown)
    @@renderer ||= Redcarpet::Render::HTML.new(hard_wrap: true, no_images: true, no_links: true, no_styles: true)
    @@markdown ||= Redcarpet::Markdown.new(@@renderer, space_after_headers: true, fenced_code_blocks: true, tables: true) 
    return @@markdown.render(markdown).html_safe
  end

end
