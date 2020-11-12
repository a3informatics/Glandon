# Sparql Utility Module
#
# @author Dave Iberson-Hurst
# @since 0.0.1
module SparqlUtility

  C_CLASS_NAME = self.name

  # Replace Special Characters. Replace special characters in the query string.
  #
  # @param text [string] The query string
  # @return [stirng] Updated string
  def self.replace_special_chars(text)    
    text.gsub!("\r", "<LINEFEED>")
    text.gsub!("\n", "<CARRIAGERETURN>")
    #text.gsub!("%", "%25")
    text.gsub!("&", "%26")
    text.gsub!("+", "%2B")
    text.gsub!("\\", "\\\\\\\\")
    text.gsub!("<LINEFEED>", "\\r")
    text.gsub!("<CARRIAGERETURN>", "\\n")
    text.gsub!("\"", "\\\"")
    return text
=begin
    text.gsub!("\n", "\\n")
    text.gsub!("\r", "\\r")
    text.gsub!("\t", "\\t")
    text.gsub!("\"", "\\\"")
    #return CGI.escape(text)
    return URI.escape(text, "&+%")
=end
  end
  
end