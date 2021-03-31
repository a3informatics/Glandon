module IndicationFactory
  
  def create_indication(identifier, label)
    ind = Indication.create(:identifier => identifier, :label => label)
  end

end