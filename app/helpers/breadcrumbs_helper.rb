module BreadcrumbsHelper

  # First Level Breadcrumb
  #
  # @param type [String] the breadcrumb type
  # @return [Null]
  def first_level_breadcrumb(type)
  	breadcrumb ([type])
  end

  # Second Level Breadcrumb
  #
  # @param type [String] the parent-level breadcrumb link tex
  # @param text [String] the second-level breadcrumb link text
  # @return [Null]
  def second_level_breadcrumb(type, text)
  	breadcrumb ([ type, {link: "#", text: "#{text}"}])
  end

  # Third Level Managed-Item Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @return [Null]
  def third_level_breadcrumb(type, managed_item, second_level_link, third_level_action)
    identifier = managed_item.respond_to?(:scoped_identifier) ? managed_item.scoped_identifier : managed_item.identifier
    breadcrumb ([type,
      {link: second_level_link, text: "#{identifier}"},
      {link: "#", text: "#{third_level_action} V#{managed_item.semantic_version}"}])
  end

  # Fourth Level Managed-Item Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param second_level_link [String] the second-level link
  # @param third_level_link [String] the third-level link
  # @param fourth_level_text [String] the third-level link
  # @return [Null]
  def fourth_level_breadcrumb(type, managed_item, second_level_link, third_level_action, third_level_link, fourth_level_action)
    breadcrumb ([type,
                {link: second_level_link, text: "#{managed_item.has_identifier.identifier}"},
                {link: third_level_link, text: "#{third_level_action} V#{managed_item.semantic_version}"},
                {link: "#", text: "#{fourth_level_action} #{@tc.notation} #{@tc.identifier}"}
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
