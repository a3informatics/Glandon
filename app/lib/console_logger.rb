module ConsoleLogger

  def ConsoleLogger.log (class_name, method_name, text)
    cn = class_name.ljust(25)
    mn = method_name.ljust(25)
    Rails.logger.debug {'[' + cn + '][' + mn + '] ' + text}
  end

end