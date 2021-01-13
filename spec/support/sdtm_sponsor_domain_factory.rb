module SdtmSponsorDomainFactory
  
  def create_sdtm_sponsor_domain(identifier, label)
    sd = SdtmSponsorDomain.create(:identifier => identifier, :label => label)
  end

  def add_variable(variable)
    self.add_link(:includes_column, variable.uri)
  end

end