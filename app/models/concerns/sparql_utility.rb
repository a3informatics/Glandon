module SparqlUtility

  C_CLASS_NAME = "SparqlUtility"

  # Method replace special characters in the query string.
  def self.replace_special_chars(text)
    # TODO: Compare with ApplicationController::to_turtle 
    text.gsub!("\r", "<LINEFEED>")
    text.gsub!("\n", "<CARRIAGERETURN>")
    text.gsub!("&", "%26")
    text.gsub!("\\", "\\\\\\\\")
    text.gsub!("<LINEFEED>", "\\r")
    text.gsub!("<CARRIAGERETURN>", "\\n")
    text.gsub!("\"", "\\\"")
    return text
  end

end

    