module ApplicationHelper
	
	# Bootstrap Class
  #
  # @param flash_type [String] the flash type
  # @return [String] the bootstrap class required
	def bootstrap_class_for(flash_type)
	  case flash_type
	    when "success"
	      "alert-success"   # Green
	    when "error"
	      "alert-danger"    # Red
	    when "alert"
	      "alert-warning"   # Yellow
	    when "notice"
	      "alert-info"      # Blue
	    else
	      flash_type.to_s
	  end
	end

	# Get Current Item
  #
  # @param items [Array] array of items one of which is the current item
  # @return [Object] the current item or nil if none
	def get_current_item(items)
	  current_set = items.select{|item| item.current?}
	  if current_set.length == 1
	  	return current_set[0]
	  else
	  	return nil
	  end
	end

	# Difference Glyphicon
  #
  # @param data [Hash] the data
  # @return [String] contains the HTML for the setting
	def diff_glyphicon(data)
		if data[:status] == :no_change
			return raw("<td class=\"text-center\"><span class=\"glyphicon glyphicon-arrow-down text-success\"/></td>")
		else
			return raw("<td>#{data[:difference]}</td>")
		end
	end

	# True/False Glyphicon in Table Cell
  #
  # @param data [Boolean] the desired setting
  # @return [String] contains the HTML for the setting
  def true_false_glyphicon(data)
		if data
			return raw("<td class=\"text-center\"><span class=\"glyphicon glyphicon-ok text-success\"/></td>")
		else
			return raw("<td class=\"text-center\"><span class=\"glyphicon glyphicon-remove text-danger\"/></td>")
		end
	end

	# Return the datatable settings for column ordering
  #
  # @return [String] contains settings for the column ordering
  def column_order(column, order)
    return "[[#{column}, 'asc']]" if order == :asc
    return "[[#{column}, 'desc']]" if order == :desc
    return "[[#{column}, 'asc']]"
  end

  # Top Level Breadcrumb
  #
  # @param text [String] the breadcrumb link text
  # @return [Null]
  def top_level_breadcrumb(text)
  	breadcrumb ([{link: "#", text: "#{text}"}])
  end

  # Second Level Breadcrumb
  #
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param text [String] the second-level breadcrumb link text
  # @return [Null]
  def second_level_breadcrumb(parent_text, parent_link, text)
  	breadcrumb ([{link: parent_link, text: "#{parent_text}"}, {link: "#", text: "#{text}"}])
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
  def third_level_breadcrumb(parent_text, parent_link, second_level_text, second_level_link, third_level_text)
    breadcrumb ([{link: parent_link, text: "#{parent_text}"}, 
      {link: second_level_link, text: "#{second_level_text}"}, 
      {link: "#", text: "#{third_level_text}"}])
  end

  # Third Level Managed-Item Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @return [Null]
  def third_level_managed_item_breadcrumb(managed_item, parent_text, parent_link, second_level_link, third_level_action)
  	breadcrumb ([{link: parent_link, text: "#{parent_text}"}, 
  		{link: second_level_link, text: "#{managed_item.identifier}"}, 
  		{link: "#", text: "#{third_level_action} V#{managed_item.semantic_version}"}])
  end

  # Fourth Level Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param second_level_text [String] the second-level breadcrumb link text
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @param third_level_link [String] the third-level link
  # @param fourth_level_text [String] the third-level link
  # @return [Null]
  def fourth_level_breadcrumb(parent_text, parent_link, second_level_text, second_level_link, third_level_text, third_level_link, fourth_level_text)
    breadcrumb ([{link: parent_link, text: "#{parent_text}"}, 
      {link: second_level_link, text: "#{second_level_text}"}, 
      {link: third_level_link, text: "#{third_level_text}"},
      {link: "#", text: "#{fourth_level_text}"}])
  end

  # Fourth Level Managed-Item Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @param third_level_link [String] the third-level link
  # @param fourth_level_text [String] the third-level link
  # @return [Null]
  def fourth_level_managed_item_breadcrumb(managed_item, parent_text, parent_link, second_level_link, third_level_action, third_level_link, fourth_level_text)
    breadcrumb ([{link: parent_link, text: "#{parent_text}"}, 
      {link: second_level_link, text: "#{managed_item.identifier}"}, 
      {link: third_level_link, text: "#{third_level_action} V#{managed_item.semantic_version}"},
      {link: "#", text: "#{fourth_level_text}"},
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
