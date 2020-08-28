# SDTM IG Importer
#
# @author Dave Iberson-Hurst
# @since 3.2.0
class Import::SdtmIg < Import

  include Import::Utility
  
  C_V1 = "01/01/1900".to_datetime 
  C_V2 = "01/01/2018".to_datetime 
  C_FORMAT_MAP = [
    {range: (C_V1...C_V2), sheet: :version_1}, 
    {range: (C_V2...DateTime.now.to_date+1), sheet: :version_2}]
  C_DEFAULT = :version_2

  # Import. Import the rectangular structure
  #
  # @param [Hash] params a parameter hash
  # @option params [String] :semantic_version the semantic version
  # @option params [String] :version_label the version label
  # @option params [String] :version the version
  # @option params [String] :date the date of issue
  # @option params [Array] :files
  # @option params [URI] :ct the CDISC CT uri to be used for CT references
  # @option params [URI] :model the CDISC SDTM Model uri to be used for references
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    @tags = []
    @parent_set = {}
    @ct = ::CdiscTerm.find_minimum(params[:ct])
    @model = ::SdtmModel.find_minimum(params[:model])
    params[:identifier] = ::SdtmIg.identifier
    results = read_and_process(params) if self.errors.empty?
    objects = self.errors.empty? ? process_results(results) : {parent: self, managed_children: []}
    object_errors?(objects) ? save_error_file(objects) : save_load_file(objects) 
    # @todo we need to unlock the import.
    params[:job].end("Complete")   
  rescue => e
    msg = "An exception was detected during the import processes."
    save_exception(e, msg)
    params[:job].exception(msg, e)
  end 
  handle_asynchronously :import unless Rails.env.test?

  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def configuration
    {
      description: "Import of CDISC SDTM Implementation Guide",
      parent_klass: ::SdtmIg,
      reader_klass: Excel,
      import_type: :cdisc_sdtm_ig,
      format: :format,
      version_label: :semantic_version,
      label: "CDISC SDTM Implementation Guide"
    }
  end

  # Format. Returns the key for the sheet info
  # 
  # @return [Symbol] the key
  def format(params)
    result = C_FORMAT_MAP.select{|x| x[:range].cover?(params[:date].to_datetime)}
    return C_DEFAULT if result.empty?
    return result.first[:sheet]
  end

private 

  # Read and process the sources
  def read_and_process(params)
    readers = read_all_sources(params)
    @parent_set = readers.first.engine.parent_set
    results = add_parent(params)
    add_managed_children(results)
    results[:tags] = []
    results
  end

  # Process Results. Process the results structure to convert to objects
  def process_results(results)
    parent = results[:parent]
    latest = ::SdtmIg.latest({scope: parent.scope, identifier: parent.scoped_identifier})
    parent.has_previous_version = latest.nil? ? nil : latest.uri

    # Check for differences. If no change then use previous version.
    filtered = []
    results[:managed_children].each_with_index do |child, index| 
      previous_info = SdtmIgDomain.latest({scope: child.scope, identifier: child.scoped_identifier})
      previous = previous_info.nil? ? nil : SdtmIgDomain.find_full(previous_info.id) 
      actual = child.replace_if_no_change(previous)
      parent.add_no_save(actual, index + 1) # Parent needs ref to child whatever new or previous
      next if actual.uri != child.uri # No changes if actual = previous, so skip next
      filtered << child 
      child.has_previous_version = previous.nil? ? nil : previous.uri
    end

    # Add terminology
    filtered.each_with_index do |domain, index| 
puts colourize("Domain: #{domain.prefix}, Class: #{get_temporary(domain,"referenced_class")}", "green")
      domain.based_on_class = find_base_class(domain)
puts colourize("Domain: #{domain.prefix}, No class found.", "red") if domain.based_on_class.nil?
      domain.children.each do |variable|
#        variable.based_on_class_variable = find_base_class_variable(domain.based_on_class)
#        variable.is_a = variable.based_on_class_variable.is_a
        next if variable.ct_and_format.empty?
        notations = extract_notations(variable.ct_and_format) 
        notations.each do |notation|
          cl = @ct.find_notation(notation)
puts colourize("***** Error finding CT Ref: #{notation} *****", "red") if cl.empty?
          next if cl.empty?
          ref = OperationalReferenceV3::TmcReference.new(context: @ct.uri, reference: cl.first[:uri], label: notation)
          ref.uri = ref.create_uri(variable.uri)
          variable.ct_reference << ref
        end
      end
    end
    {parent: parent, managed_children: filtered, tags: []}
  end

  def find_base_class(domain)
    @model.find_class(class_identifier(get_temporary(domain, "referenced_class"), domain.prefix))
  end

#  def find_base_class_variable(the_class, variable)
#    return nil if class.nil?
#    result = the_class.find_variable(variable.name)
#    SdtmModel::Variable.find(result)
#  end

  def extract_notations(value)
    temp = value.scan(/\(\w+\)*/)
    temp.map {|x| x.gsub(/[()]/, "")}
  end

  def get_temporary(object, name)
    object.instance_variable_get("@#{name}")
  end

  def class_identifier(the_class, prefix)
    return "#{SdtmModel.identifier} #{prefix}" if the_class == "SDTM SPECIAL PURPOSE"
    return "#{SdtmModel.identifier} #{prefix}" if the_class == "SDTM TRIAL DESIGN"
    return "#{SdtmModel.identifier} #{prefix}" if the_class == "SDTM RELATIONSHIPS"
    return "#{SdtmModel.identifier} #{prefix}" if the_class == "SDTM STUDY REFERENCE"
    the_class
  end

end