module SdtmIgDomainHelpers
  
  def create_sdtm_ig_domain(identifier, label)
    bc = SdtmIgDomain.create(:identifier => identifier, :label => label)
  end

end