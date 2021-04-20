module StudyFactory
  
  def create_study(identifier, label)
    study = Study.create(:identifier => identifier, :label => label)
  end

end