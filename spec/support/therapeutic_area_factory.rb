module TherapeuticAreaFactory
  
  def create_therapeutic_area(identifier, label)
    ta = TherapeuticArea.create(:identifier => identifier, :label => label)
  end

end