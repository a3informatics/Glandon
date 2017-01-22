module ValidationHelpers

  def vh_all_chars
    return "the dirty brown fox jumps over the lazy dog. " + 
    "THE DIRTY BROWN FOX JUMPS OVER THE LAZY DOG. 0123456789. !?,'\"_-/\\()[]~#*=:;&|<>"
  end

  def vh_label_error
    return "Please enter a valid label. Upper and lower case case alphanumerics, space and .!?,'\"_-/\\()[]~#*=:;&|<> special characters only."
  end

  def vh_markdown_error
    return "Please enter valid markdown. Upper and lowercase alphanumeric, space, .!?,'\"_-/\\()[]~#*=:;&|<> special characters and return only."
  end

  def vh_question_error
    return "Please enter valid question text. Upper and lower case case alphanumerics, space and .!?,'\"_-/\\()[]~#*=:;&|<> special characters only."
  end
  
  def vh_mapping_error
    return "Please enter valid question text. Upper and lower case case alphanumerics, space and .!?,'\"_-/\\()[]~#*=:;&|<> special characters only."
  end
  
end