module ValidationHelpers

  def vh_all_chars
    return "the dirty brown fox jumps over the lazy dog. " + 
    "THE DIRTY BROWN FOX JUMPS OVER THE LAZY DOG. 0123456789. !?,'\"_-/\\()[]~#*+@=:;&|<>%^"
  end

  def vh_label_error
    return "Please enter a valid label. Upper and lower case case alphanumerics, space and .!?,'\"_-/\\()[]~#*+@=:;&|<>%^ special characters only."
  end

  def vh_markdown_error
    return "Please enter valid markdown. Upper and lowercase alphanumeric, space, .!?,'\"_-/\\()[]~#*+@=:;&|<>%^ special characters and return only."
  end

  def vh_question_error
    return "Please enter valid question text. Upper and lower case case alphanumerics, space and .!?,'\"_-/\\()[]~#*+@=:;&|<>%^ special characters only."
  end
  
  def vh_mapping_error
    return "Please enter valid question text. Upper and lower case case alphanumerics, space and .!?,'\"_-/\\()[]~#*+@=:;&|<>%^ special characters only."
  end
  
  def si(uri, identifier)
    x = FusekiBaseHelpers::TestScopedIdentifier.new
    x.uri = uri
    x.identifier = identifier
    x.by_authority = IsoRegistrationAuthority.new
    x.by_authority.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    x.by_authority.organization_identifier = "123456777"
    x.by_authority.ra_namespace = IsoNamespace.find_by_short_name("BBB")
    x.save
    x
  end

end