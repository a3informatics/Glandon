module BreadcrumbsHelper

  # First Level Breadcrumb
  #
  # @param text [String] the breadcrumb link text
  # @return [Null]
  def first_level_breadcrumb(text)
  	breadcrumb ([{link: "#", text: "#{text}"}])
  end

  # Second Level Breadcrumb
  #
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param text [String] the second-level breadcrumb link text
  # @return [Null]
  def second_level_breadcrumb(parent_text, parent_link, text)
  	breadcrumb ([ {link: parent_link, text: "#{parent_text}"}, 
                  {link: "#", text: "#{text}"}])
  end

  # Third Level Managed-Item Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @return [Null]
  def third_level_breadcrumb(type, managed_item, title)
    identifier = managed_item.respond_to?(:scoped_identifier) ? managed_item.scoped_identifier : managed_item.identifier
  	breadcrumb ([ {link: parent_link, text: "#{type}"},
  		            {link: second_level_link, text: "#{identifier}"},
  		            {link: "#", text: "#{third_level_action} V#{managed_item.semantic_version}"}])
  end

  # Fourth Level Managed-Item Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param type
  # @param title
  # @return [Null]
  def fourth_level_breadcrumb(type, managed_item, title)
    breadcrumb ([ {link: parent_link, text: "#{type}"},
                  {link: second_level_link, text: "#{managed_item.identifier}"},
                  {link: third_level_link, text: "#{third_level_action} V#{managed_item.semantic_version}"},
                  {link: "#", text: "#{title}"}
                ])
  end

  # Breadcrumb. Formats the HTML for the breadcrumb. Places into a session variable.
  #
  # @param items [Array] array of hash items holding the text and link for each level of the breadcrumb
  # @return [Null]
  def breadcrumb(items)
  	result = "<ol class=\"breadcrumb\">"
  	index = 1
  	items.each do |item|
  		result += item.equal?(items.last) ? "<li id=\"breadcrumb_#{index}\" class=\"active\">#{item[:text]}</li>" : "<li id=\"breadcrumb_#{index}\"><a href=\"#{item[:link]}\">#{item[:text]}</a></li>"
  		index += 1
  	end
  	result += "</ol>"
  	session[:breadcrumbs] = raw(result)
  end

end
