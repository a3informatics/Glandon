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

end
