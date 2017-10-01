module OdmHelpers
  
  def extract_file_oid(text)
    return text[/FileOID=\"\d\d\d\d\-\d\d-\d\dT\d\d:\d\d:\d\d[+|-]\d\d:\d\d\"/]
  end

  def extract_creation_datetime(text)
    return text[/CreationDateTime=\"\d\d\d\d\-\d\d-\d\dT\d\d:\d\d:\d\d[+|-]\d\d:\d\d\"/]
  end

end