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

  def self.clear_cache
    Fuseki::Base.class_variable_set(:@@schema, nil)
    Fuseki::Base.class_variable_set(:@@subjects, nil)
  end

end