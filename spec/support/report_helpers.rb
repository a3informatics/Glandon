module ReportHelpers
  
  def extract_run_at(text)
    return text[/<p>Run at: \d\d\d\d\-[a-zA-Z]{3}\-\d\d, \d\d:\d\d:\d\d<\/p>/]
  end

end