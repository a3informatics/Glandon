module SparqlUtility

  C_CLASS_NAME = "SparqlUtility"

  # Method replace special characters in the query string.
  def self.replace_special_chars(text)
    #ConsoleLogger::log(C_CLASS_NAME,"replace_special_chars", "old=" + text)
    text.gsub!("\r", "<LINEFEED>")
    text.gsub!("\n", "<CARRIAGERETURN>")
    text.gsub!("&", "%26")
    #ConsoleLogger::log(C_CLASS_NAME,"replace_special_chars", "new[1]=" + text)
    text.gsub!("\\", "\\\\\\\\")
    #ConsoleLogger::log(C_CLASS_NAME,"replace_special_chars", "new[2]=" + text)
    text.gsub!("<LINEFEED>", "\\r")
    text.gsub!("<CARRIAGERETURN>", "\\n")
    text.gsub!("\"", "\\\"")
    #ConsoleLogger::log(C_CLASS_NAME,"replace_special_chars", "new[3]=" + text)
    return text
  end

end

    