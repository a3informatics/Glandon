class MarkdownEngine
  
  # Constants
  C_CLASS_NAME = "MarkdownEngine" 
  
  # Convert markdown into html.
  #
  # @param markdown [string] The markdown text
  # @result [string] The resulted translated html
  def self.render(markdown)
    return "&nbsp;" if markdown.blank?
    @@renderer ||= Redcarpet::Render::HTML.new(hard_wrap: true, no_images: true, no_links: true, no_styles: true)
    @@markdown ||= Redcarpet::Markdown.new(@@renderer, space_after_headers: true, fenced_code_blocks: true, tables: true) 
    return @@markdown.render(markdown).html_safe
  end

end
