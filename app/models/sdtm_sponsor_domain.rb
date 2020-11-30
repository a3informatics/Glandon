class SdtmSponsorDomain < SdtmIgDomain

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomain",
            uri_suffix: "SPD"

  # Create a Sponsor Domain based on a specified IG domain
  #
  # @params [SdtmIgDomain] the template IG domain
  # @return [SdtmSponsorDomain] the new sponsor domain object
  def self.create_from_ig(params, ig_domain)
    object = SdtmSponsorDomain.create(identifier: "#{params[:prefix]} Domain", label: params[:label], prefix: params[:prefix], ordinal: 1 )
    object.structure = ig_domain.structure
    object.based_on_class = ig_domain.based_on_class.uri
    ig_domain.includes_column.sort_by {|x| x.ordinal}.each do |domain_variable|
      sponsor_variable = SdtmSponsorDomain::Var.create(label: domain_variable.label, name: domain_variable.name, ordinal: domain_variable.ordinal)
      sponsor_variable.format = domain_variable.format
      sponsor_variable.ct_and_format = domain_variable.ct_and_format
      sponsor_variable.used = true
      sponsor_variable.compliance = domain_variable.compliance
      sponsor_variable.ct_reference = domain_variable.ct_reference
      sponsor_variable.based_on_ig_variable = domain_variable.uri
      object.includes_column << sponsor_variable
    end
    object
  end

end