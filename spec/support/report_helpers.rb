module ReportHelpers

  def extract_run_at(text)
    return text[/<p>Run at: \d\d\d\d\-[a-zA-Z]{3}\-\d\d, \d\d:\d\d:\d\d<\/p>/]
  end

  def extract_change(text)
    return text[/<th>Change<\/th><th>Comment<\/th><th>References<\/th><\/tr><\/thead><tbody><tr><td>\d\d\d\d\-[a-zA-Z]{3}\-\d\d<\/td>/]
  end

  def extract_path(text)
    return text[/\/Users\/\w{1,}\/\w{1,}\/\w{1,}\/\w{1,}/]
  end

end
