module DeviseHelper

  # Password Message. Message to users staing the password requirements.
  #
  # @return [String] The user message
  def password_message
    "Your password must be between #{Devise.password_length.min} and #{Devise.password_length.max} characters and must include at least #{Devise.password_complexity.map {|k, v| format_password_setting(k, v)}.to_sentence} characters."
  end

  # Format Password Setting. Formats a password setting from Devise Security
  #
  # @param name [Symbol] the setting
  # @param value [Integer] the value of the setting 1..N
  # @return [String] The user setting as a string
  def format_password_setting(name, value)
    password_map = {digit: "digit", lower: "lowercase", upper: "uppercase", symbol: "special"}
    "#{value} #{password_map[name]}"
  end

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
