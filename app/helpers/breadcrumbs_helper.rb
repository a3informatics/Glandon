module BreadcrumbsHelper

  # First Level Breadcrumb
  #
  # @param type [Hash] hash holding the text and link for the first level
  # @return [Null]
  def first_level_breadcrumb(type)
  	breadcrumb ([id_to_type(type)])
  end

  # Second Level Breadcrumb
  #
  # @param type [Hash] hash holding the text and link for the first level
  # @param scope_id [String] scope id of the item
  # @param identifier [String] identifier of the item
  # @param text [String] optional title
  # @return [Null]
  def second_level_breadcrumb(type, scope_id, identifier, text = "")
    scope_short_name = IsoNamespace.find(scope_id).short_name
    breadcrumb ([id_to_type(type), {link: "#", text: "#{text}#{scope_short_name}, #{identifier}"}])
  end

  # Third Level Managed-Item Breadcrumb
  #
  # @param type [Hash] hash holding the text and link for the first level
  # @param item [Object] the managed item
  # @param second_level_link [String] the second-level link
  # @return [Null]
  def third_level_breadcrumb(type, item, second_level_link)
    identifier = item.respond_to?(:scoped_identifier) ? item.scoped_identifier : item.identifier
    scope = item.respond_to?(:scoped_identifier) ? item.has_identifier.has_scope.short_name : item.scope.short_name
    breadcrumb ([id_to_type(type), {link: second_level_link, text: "#{scope}, #{identifier}"}, {link: "#", text: "V#{item.semantic_version}"}])
  end

  # Fourth Level Breadcrumb
  #
  # @param type [Hash] hash holding the text and link for the first level
  # @param item [Object] the managed item
  # @param second_level_link [String] the second-level link
  # @param third_level_link [String] the third-level link
  # @param title [String] the action title
  # @return [Null]
  def fourth_level_breadcrumb(type, item, second_level_link, third_level_link, title)
    identifier = item.respond_to?(:scoped_identifier) ? item.scoped_identifier : item.identifier
    scope = item.respond_to?(:scoped_identifier) ? item.has_identifier.has_scope.short_name : item.scope.short_name
    breadcrumb ([id_to_type(type), {link: second_level_link, text: "#{scope}, #{identifier}"}, {link: third_level_link, text: "V#{item.semantic_version}"}, {link: "#", text: "#{title}"}])
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
