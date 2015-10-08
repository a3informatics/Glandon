module ConsoleLogger

  def ConsoleLogger.log (className,methodName,text)
    cn = className.ljust(25)
    mn = methodName.ljust(25)
    p '[' + cn + '][' + mn + '] ' + text
  end

end