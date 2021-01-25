module SdtmSponsorDomainFactory
  
  def create_sdtm_sponsor_domain(identifier, label, prefix)
    sd = SdtmSponsorDomain.create(identifier: identifier, label: label, prefix: prefix)
  end

end