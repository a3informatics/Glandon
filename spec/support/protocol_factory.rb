module ProtocolFactory
  
  def create_protocol(identifier, label)
    protocol = Protocol.create(:identifier => identifier, :label => label)
  end

end