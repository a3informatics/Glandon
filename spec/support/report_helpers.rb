module ReportHelpers
  
  def extract_run_at(text)
    return text[/<td>Run at:<\/td><td>\d\d\d\d\-[a-zA-Z]{3}\-\d\d, \d\d:\d\d:\d\d<\/td>/]
  end

end