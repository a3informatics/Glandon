module ReportHelpers

  def extract_run_at(text)
    return text[/<p>Run at: \d\d\d\d\-[a-zA-Z]{3}\-\d\d, \d\d:\d\d:\d\d<\/p>/]
  end

  def extract_path(text)
    return text[/\/Users\/\w{1,}\/\w{1,}\/\w{1,}\/\w{1,}/]
  end

end
