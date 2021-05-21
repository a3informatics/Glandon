module EndpointFactory
  
  def create_endpoint(identifier, label)
    ep = Endpoint.create(:identifier => identifier, :label => label)
  end

end