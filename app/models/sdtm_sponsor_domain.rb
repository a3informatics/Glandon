class SdtmSponsorDomain < SdtmIgDomain

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomain",
            uri_suffix: "SPD"

  include Tabulation::Ordinal

  # Clone. Clone the Sponsor SDTM Domain
  #
  # @return [SDTM Sponsor Domain] a clone of the object
  def clone
    self.based_on_class_links
    self.includes_column_links
    super
  end

  # Create a Sponsor Domain based on a specified IG domain
  #
  # @param [Hash] params the parameters to create the new sponsor domain
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

  # Create a Sponsor Domain based on a specified Class
  #
  # @param [Hash] params the parameters to create the new sponsor domain
  # @params [SdtmClass] the template class
  # @return [SdtmSponsorDomain] the new sponsor domain object
  def self.create_from_class(params, sdtm_class)
    object = SdtmSponsorDomain.new
    object.label = sdtm_class.label
    object.prefix = params[:prefix]
    object.ordinal = 1
    object.set_initial("#{params[:prefix]} Domain")
    #object.structure = ig_domain.structure
    #object.based_on_class = ig_domain.based_on_class.uri
    sdtm_class.includes_column.sort_by {|x| x.ordinal}.each do |class_variable|
      #sponsor_variable_name = sponsor_variable_name(params[:prefix], class_variable.name)
      sponsor_variable_name = SdtmVariableName.new(class_variable.name, params[:prefix]).prefixed? ? class_variable.name.gsub('--', params[:prefix]) : params[:prefix]+class_variable.name
      sponsor_variable = SdtmSponsorDomain::Var.create({parent_uri: object.uri, label: class_variable.label, name: sponsor_variable_name, ordinal: class_variable.ordinal})
      sponsor_variable.description = class_variable.description
      #sponsor_variable.format = domain_variable.format
      #sponsor_variable.ct_and_format = domain_variable.ct_and_format
      sponsor_variable.used = true
      sponsor_variable.compliance = Uri.new(uri:"http://www.assero.co.uk/CSN#f7d9d4e1-a00a-487e-89db-ebece910ba0d") #Permissible node
      sponsor_variable.typed_as = class_variable.typed_as.uri 
      sponsor_variable.classified_as = class_variable.classified_as.uri
      #sponsor_variable.ct_reference = domain_variable.ct_reference
      #sponsor_variable.based_on_ig_variable = domain_variable.uri
      sponsor_variable.based_on_class_variable = class_variable.uri
      object.includes_column << sponsor_variable
    end
    object.create_or_update(:create, true) if object.valid?(:create) && object.create_permitted?
    object
  end

  # Add non standard variable
  #
  # @return [SdtmSponsorDomain] the new sponsor domain object
  def add_non_standard_variable
    non_standard_variable = SdtmSponsorDomain::Var.new
    ordinal = next_ordinal
    non_standard_variable.set_name("#{self.prefix}XXX#{ordinal}", self)
    non_standard_variable.ordinal = ordinal
    non_standard_variable.uri = non_standard_variable.create_uri(self.uri)
    non_standard_variable.typed_as = Uri.new(uri:"http://www.assero.co.uk/CSN#d2f2bbeb-8f79-4fb1-b190-dd864d29f080") #Character node #Character, Numeric
    non_standard_variable.classified_as = Uri.new(uri:"http://www.assero.co.uk/CSN#86cd61e6-d48c-4e42-b994-bee35e2351fe") #None node
    non_standard_variable.compliance = Uri.new(uri:"http://www.assero.co.uk/CSN#f7d9d4e1-a00a-487e-89db-ebece910ba0d") #Permissible node #Permissible, required, expected
    non_standard_variable.save
    self.add_link(:includes_column, non_standard_variable.uri)
    non_standard_variable
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