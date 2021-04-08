module ObjectiveFactory
  
  def create_objective(identifier, label)
    ob = Objective.create(:identifier => identifier, :label => label)
  end

end