module IsoHelpers
  
  def self.escape_id(id)
    CGI.escape(id)
  end

end