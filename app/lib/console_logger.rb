module ConsoleLogger

	C_WIDTH = 25

  # Log. Deprecated, see Debug below.
	#
	# @param class_name [string] The unit class name. Will be limited to a set width.
	# @param method_name [string] The method name. Will be limited to a set width.
	# @param text [string] The test to be logged.
	# @return [string] Empty string
	def ConsoleLogger.log (class_name, method_name, text)
    ConsoleLogger.debug(class_name, method_name, text)
  end

  # Debug. Add to log at DEBUG level
	#
	# @param class_name [string] The unit class name. Will be limited to a set width.
	# @param method_name [string] The method name. Will be limited to a set width.
	# @param text [string] The test to be logged.
	# @return [string] Empty string
	def ConsoleLogger.debug (class_name, method_name, text)
    cn = class_name.ljust(C_WIDTH)
    mn = method_name.ljust(C_WIDTH)
    Rails.logger.debug {'[' + cn + '][' + mn + '] ' + text}
  end

  # Info. Add to log at INFO level
	#
	# @param class_name [string] The unit class name. Will be limited to a set width.
	# @param method_name [string] The method name. Will be limited to a set width.
	# @param text [string] The test to be logged.
	# @return [string] Empty string
	def ConsoleLogger.info (class_name, method_name, text)
    cn = class_name.ljust(C_WIDTH)
    mn = method_name.ljust(C_WIDTH)
    Rails.logger.info {'[' + cn + '][' + mn + '] ' + text}
  end

  # Debug On. Sets debug logging on
	#
	# @return null
	def ConsoleLogger.debug_on
  	Rails.logger.level = 0
  end

	# Debug Off. Sets debug off and sets to info
	#
	# @return null
	def ConsoleLogger.debug_off
  	Rails.logger.level = 1
  end

end