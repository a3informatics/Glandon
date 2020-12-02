class SdtmSponsorDomain < SdtmIgDomain

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomain",
            uri_suffix: "SPD"

  # Create a Sponsor Domain based on a specified IG domain
  #
  # @params [SdtmIgDomain] the template IG domain
  # @return [SdtmSponsorDomain] the new sponsor domain object
  def self.create_from_ig(params, ig_domain)
    object = SdtmSponsorDomain.new
    object.label = params[:label]
    object.prefix = params[:prefix]
    object.ordinal = 1
    object.set_initial("#{params[:prefix]} Domain")
    object.structure = ig_domain.structure
    object.based_on_class = ig_domain.based_on_class.uri
    ig_domain.includes_column.sort_by {|x| x.ordinal}.each do |domain_variable|
      sponsor_variable = SdtmSponsorDomain::Var.create({parent_uri: object.uri, label: domain_variable.label, name: domain_variable.name, ordinal: domain_variable.ordinal})
      sponsor_variable.description = domain_variable.description
      sponsor_variable.format = domain_variable.format
      sponsor_variable.ct_and_format = domain_variable.ct_and_format
      sponsor_variable.used = true
      sponsor_variable.compliance = domain_variable.compliance.uri
      sponsor_variable.ct_reference = domain_variable.ct_reference
      sponsor_variable.based_on_ig_variable = domain_variable.uri
      object.includes_column << sponsor_variable
    end
    object.create_or_update(:create, true) if object.valid?(:create) && object.create_permitted?
    object
  end

  def add_non_standard_variable(params)
    non_standard_variable = SdtmSponsorDomain::Var.new
    var_name = "#{self.prefix}"+"#{params[:name]}" 
    non_standard_variable.set_name(var_name, self)
    non_standard_variable.ordinal = next_ordinal
    non_standard_variable.uri = non_standard_variable.create_uri(self.uri)
    #Add datatype --> should I use the typedAs property?
    #Add classification (qualifier etc) --> which attribute should be used? Because a Sponsor Variable doesn't have the classifiedAs property.
    #non_standard_variable.compliance = params[:compliance] #Permissible, required, expected
    non_standard_variable.save
    self.includes_column <<  non_standard_variable
    non_standard_variable
  end

  def delete_non_standard_variable

  end

  private

    # Next Ordinal. Get the next ordinal for a domain variable
    #
    # @param [String] name the name of the property holding the collection
    # @return [Integer] the next ordinal
    def next_ordinal
      query_string = %Q{
        SELECT (MAX(?ordinal) AS ?max)
        {
          #{self.uri.to_ref} bd:includesColumn ?var .
          ?var bd:ordinal ?ordinal
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bd])
      return 1 if query_results.empty?
      query_results.by_object(:max).first.to_i + 1
    end

end