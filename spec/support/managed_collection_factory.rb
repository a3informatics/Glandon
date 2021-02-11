module ManagedCollectionFactory
  
  def create_managed_collection(identifier, label)
    mc = ManagedCollection.create(:identifier => identifier, :label => label)
  end

end