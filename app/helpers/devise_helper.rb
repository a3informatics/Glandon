module DeviseHelper

	# Devise Error Messages 
	# Overwrites the devise implementation to convert error messages into flash error messages
	#
	# @return [string] Empty string
	def devise_error_messages!
    if resource.errors.full_messages.any?
        flash.now[:error] = resource.errors.full_messages.join(' & ')
    end
    return ''
  end

end