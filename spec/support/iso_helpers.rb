module IsoHelpers
  
  def self.escape_id(id)
    CGI.escape(id)
  end

  def self.mark_as_used(uri)
    sparql = %Q{INSERT DATA
      { 
        <http://example/book1> <http://example/is> #{uri.to_ref} .
      }
    }
    Sparql::Update.new.sparql_update(sparql, "", []) 
  end

  def self.clear_schema_cache
    Rails.cache.delete(:schema)
  end

  def self.clear_cache
    Rails.cache.clear
  end

end