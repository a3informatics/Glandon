module ApplicationHelper
	
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

	def get_current_item(items)
	  current_set = items.select{|item| item.current?}
	  if current_set.length == 1
	  	return current_set[0]
	  else
	  	return nil
	  end
	end
	  	
end
