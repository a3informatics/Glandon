# Manages logging of errors.
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module ConsoleLogger

	C_WIDTH = 25 # Width of class name and method names in the output

  # Log. Deprecated, see Debug below.
	#
	# @param class_name [string] The unit class name. Will be limited to a set width.
	# @param method_name [string] The method name. Will be limited to a set width.
	# @param text [string] The test to be logged.
	# @return [string] Empty string
	def self.log (class_name, method_name, text)
    self.debug(class_name, method_name, text)
  end

  # Debug. Add to log at DEBUG level
	#
	# @param class_name [string] The unit class name. Will be limited to a set width.
	# @param method_name [string] The method name. Will be limited to a set width.
	# @param text [string] The test to be logged.
	# @return [string] Empty string
	def self.debug (class_name, method_name, text)
    Rails.logger.debug format_message(class_name, method_name, text)
  end

  # Info. Add to log at INFO level
	#
	# @param class_name [string] The unit class name. Will be limited to a set width.
	# @param method_name [string] The method name. Will be limited to a set width.
	# @param text [string] The test to be logged.
	# @return [string] Empty string
	def self.info (class_name, method_name, text)
    Rails.logger.info format_message(class_name, method_name, text)
  end

  # Error. Add to log at ERROR level
  #
  # @param class_name [string] The unit class name. Will be limited to a set width.
  # @param method_name [string] The method name. Will be limited to a set width.
  # @param text [string] The test to be logged.
  # @return [string] Empty string
  def self.error (class_name, method_name, text)
    Rails.logger.error format_message(class_name, method_name, text)
  end

  # Debug On. Sets debug logging on
	#
	# @return null
	def self.debug_on
  	Rails.logger.level = 0
  end

	# Debug Off. Sets debug off and sets to info
	#
	# @return null
	def self.debug_off
  	Rails.logger.level = 1
  end

private
  
  # Format the message
  def self.format_message(class_name, method_name, text)
    return "[#{class_name.ljust(C_WIDTH)}][#{method_name.ljust(C_WIDTH)}] #{text}"
  end

end