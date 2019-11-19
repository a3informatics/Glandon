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
  # @param title [String] the second-level breadcrumb link text
  # @return [Null]
  def second_level_breadcrumb(type, scope_id, identifier, text = "")
    scope_short_name = IsoNamespace.find(scope_id).short_name
    breadcrumb ([ type, 
                {link: "#", text: "#{text}#{scope_short_name}, #{identifier}"}])
  end

  # Third Level Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param second_level_text [String] the second-level breadcrumb link text
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @return [Null]
  # def third_level_breadcrumb(type, second_level_text, second_level_link, third_level_text)
  #   breadcrumb ([type,
  #               {link: second_level_link, text: "#{second_level_text}"},
  #               {link: "#", text: "#{third_level_text}"}])
  # end

  # Third Level Managed-Item Breadcrumb
  #
  # @param type [Object] the 
  # @param managed_item [Object] the managed item
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @return [Null]
  def third_level_breadcrumb(type, item, second_level_link)
    identifier = item.respond_to?(:scoped_identifier) ? item.scoped_identifier : item.identifier
    breadcrumb ([ type,
                  {link: second_level_link, text: "#{item.has_identifier.has_scope.short_name}, #{identifier}"},
                  {link: "#", text: "V#{item.semantic_version}"}])
  end

  # Fourth Level Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param type [String] type
  # @param second_level_text [String] the second-level breadcrumb link text
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @param third_level_link [String] the third-level link
  # @param fourth_level_text [String] the third-level link
  # @return [Null]
  def fourth_level_breadcrumb(type, managed_item, second_level_link, third_level_text, third_level_link, title)
    breadcrumb ([type,
      {link: second_level_link, text: "#{managed_item.has_identifier.has_scope.short_name}, #{managed_item.scoped_identifier}"},
      {link: third_level_link, text: "#{third_level_text.notation} (#{third_level_text.identifier})"},
      {link: "#", text: "#{title}"}])
  end

  # Fourth Level Managed-Item Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param second_level_link [String] the second-level link
  # @param third_level_link [String] the third-level link
  # @param fourth_level_text [String] the third-level link
  # @return [Null]
  # def fourth_level_managed_item_breadcrumb(type, managed_item, second_level_link, third_level_link, title)
  #   identifier = managed_item.respond_to?(:scoped_identifier) ? managed_item.scoped_identifier : managed_item.identifier
  #   breadcrumb ([type,
  #               {link: second_level_link, text: "#{managed_item.has_identifier.has_scope.short_name}, #{identifier}"},
  #               {link: third_level_link, text: "V#{managed_item.semantic_version}"},
  #               # {link: third_level_link, text: "#{managed_item.notation} #{managed_item.identifier}"},
  #               {link: "#", text: "#{title}"}
  #     ])
  # end

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
