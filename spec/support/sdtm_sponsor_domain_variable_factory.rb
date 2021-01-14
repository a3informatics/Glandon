module SdtmSponsorDomainVariableFactory

  def create_sdtm_sponsor_domain_non_standard_variable(params)
    create_simple_sponsor_variable(params)
  end

  def create_sdtm_sponsor_domain_standard_variable(params)
    create_simple_sponsor_variable(params, true)
  end

  def create_and_add_non_standard_variable(sponsor_domain)
    create_sponsor_variable(sponsor_domain)
  end

  def create_and_add_standard_variable(sponsor_domain)
    create_sponsor_variable(sponsor_domain, true)
  end

  private

    def create_sponsor_variable(sponsor_domain, standard = false)
      sponsor_variable = SdtmSponsorDomain::VariableSSD.new
      ordinal = next_ordinal(sponsor_domain)
      sponsor_variable.name = "#{sponsor_domain.prefix}XXX#{ordinal.to_s.rjust(3,'0')}"
      sponsor_variable.ordinal = ordinal
      sponsor_variable.uri = sponsor_variable.create_uri(sponsor_domain.uri)
      sponsor_variable.typed_as = Uri.new(uri:"http://www.assero.co.uk/CSN#d2f2bbeb-8f79-4fb1-b190-dd864d29f080") #Character node #Character, Numeric
      sponsor_variable.classified_as = Uri.new(uri:"http://www.assero.co.uk/CSN#86cd61e6-d48c-4e42-b994-bee35e2351fe") #None node
      sponsor_variable.compliance = Uri.new(uri:"http://www.assero.co.uk/CSN#f7d9d4e1-a00a-487e-89db-ebece910ba0d") #Permissible node #Permissible, required, expected
      sponsor_variable.based_on_ig_variable = Uri.new(uri:"http://www.cdisc.org/SDTM_IG_AE/V1#IGD_STUDYID") if standard
      sponsor_variable.save
      sponsor_domain.add_link(:includes_column, sponsor_variable.uri)
      sponsor_variable
    end

    def create_simple_sponsor_variable(params, standard = false)
      var = SdtmSponsorDomain::VariableSSD.new
      var.name = params[:name].nil? ? "XXX001" : params[:name]
      var.uri = params[:uri].nil? ? Uri.new(uri: "http://www.assero.co.uk/SDV") : params[:uri]
      var.ordinal = params[:ordinal].nil? ? 1 : params[:ordinal]
      var.typed_as = params[:typed_as].nil? ? Uri.new(uri:"http://www.assero.co.uk/CSN#d2f2bbeb-8f79-4fb1-b190-dd864d29f080") : params[:typed_as]
      var.classified_as = params[:classified_as].nil? ? Uri.new(uri:"http://www.assero.co.uk/CSN#86cd61e6-d48c-4e42-b994-bee35e2351fe") : params[:classified_as]
      var.compliance = params[:compliance].nil? ? Uri.new(uri:"http://www.assero.co.uk/CSN#f7d9d4e1-a00a-487e-89db-ebece910ba0d") : params[:compliance]
      if standard
        var.based_on_ig_variable = params[:based_on_ig_variable].nil? ? Uri.new(uri:"http://www.cdisc.org/SDTM_IG_AE/V1#IGD_STUDYID") : params[:based_on_ig_variable]
      end
      var.save
      var
    end

    # Next Ordinal. Get the next ordinal for a domain variable
    #
    # @param [String] name the name of the property holding the collection
    # @return [Integer] the next ordinal
    def next_ordinal(sponsor_domain)
      query_string = %Q{
        SELECT (MAX(?ordinal) AS ?max)
        {
          #{sponsor_domain.uri.to_ref} bd:includesColumn ?var .
          ?var bd:ordinal ?ordinal
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bd])
      return 1 if query_results.empty?
      query_results.by_object(:max).first.to_i + 1
    end

end