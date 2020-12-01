class SdtmSponsorDomain < SdtmIgDomain

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomain",
            uri_suffix: "SPD"

  # Create a Sponsor Domain based on a specified IG domain
  #
  # @params [SdtmIgDomain] the template IG domain
  # @return [SdtmSponsorDomain] the new sponsor domain object
  def self.create_from_ig(params, ig_domain)
    object = SdtmSponsorDomain.create(identifier: "#{params[:prefix]} Domain", label: params[:label], prefix: params[:prefix], ordinal: 1)
    object.structure = ig_domain.structure
    object.based_on_class = ig_domain.based_on_class
    ig_domain.includes_column.sort_by {|x| x.ordinal}.each do |domain_variable|
      sponsor_variable = SdtmSponsorDomain::Var.create(parent_uri: object.uri, label: domain_variable.label, name: domain_variable.name, ordinal: domain_variable.ordinal)
      sponsor_variable.description = domain_variable.description
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

  def add_non_standard_variable(params)
    non_standard_variable = SdtmSponsorDomain::Var.create(parent_uri: self.uri)
    validate_name(params[:name]) #Validate name --> ASK query to check if name exists? If already exists return error?
    non_standard_variable.name = "#{self.prefix}"
    #Add datatype --> should I use the typedAs property?
    #Add classification (qualifier etc) --> which attribute should be used? Because a Sponsor Variable doesn't have the classifiedAs property.
    non_standard_variable.compliance = params[:compliance] #Permissible, required, expected
    self.includes_column <<  non_standard_variable
    non_standard_variable
  end

  def delete_non_standard_variable

  end

end