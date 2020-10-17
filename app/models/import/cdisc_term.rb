# CDISC Terminology Excel Importer
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::CdiscTerm < Import

  include Import::Utility

  C_V1 = "01/01/1900".to_datetime 
  C_V2 = "01/05/2007".to_datetime 
  C_V3 = "01/09/2008".to_datetime 
  C_V4 = "01/05/2009".to_datetime 
  C_V5 = "01/04/2010".to_datetime 
  C_FORMAT_MAP = [
    {range: (C_V1...C_V2), sheet: :version_1}, 
    {range: (C_V2...C_V3), sheet: :version_2}, 
    {range: (C_V3...C_V4), sheet: :version_3}, 
    {range: (C_V4...C_V5), sheet: :version_4}, 
    {range: (C_V5...DateTime.now.to_date+1), sheet: :version_5}]
  C_DEFAULT = :version_5

  # Import. Import the rectangular structure
  #
  # @param [Hash] params a parameter hash
  # @option params [String] :semantic_version the semantic version
  # @option params [String] :version_label the version label
  # @option params [String] :version the version
  # @option params [String] :date the date of issue
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    @tags = []
    @parent_set = {}
    params[:identifier] = ::CdiscTerm.identifier
    check_date_and_sources(params)
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
      description: "Import of CDISC Terminology",
      parent_klass: Import::CdiscClasses::CdiscThesaurus,
      reader_klass: self.api? ? CDISCLibraryAPIReader : Excel,
      import_type: :cdisc_term,
      format: self.api? ? :api_format : :excel_format,
      version_label: :date,
      label: "Controlled Terminology"
    }
  end

  # API Format. Get the API format
  #
  # @param [Hash] params empty, ignored
  # @return [Object] nil
  def api_format(params)
    nil
  end

  # Excel Format. Get the excel format
  #
  # @param [Hash] params a set of parameters
  # @option [String] :date a day date as a string
  # @return [Symbol] the sheet as a symbol. Default to C_DEFAULT if non found.
  def excel_format(params)
    result = C_FORMAT_MAP.select{|x| x[:range].cover?(params[:date].to_datetime)}
    return C_DEFAULT if result.empty?
    return result.first[:sheet]
  end

private

  # Check date (not implemented) and sources. If API need to fins the hrefs
  def check_date_and_sources(params)
    check_date(params)
    return if !self.api? 
    api_sources(params)
  end

  # Check the date to see if we already have a version
  def check_date(params)
    return if !::CdiscTerm.creation_date_exists?(identifier: ::CdiscTerm.identifier, scope: IsoRegistrationAuthority.cdisc_scope, date: params[:date])
    self.errors.add(:base, "There is already a version of #{::CdiscTerm.identifier} dated #{params[:date]} in the system.")
  end
    
  # Find the href sources for the API read.
  def api_sources(params)
    params[:files] = CDISCLibraryAPI.new.ct_packages_by_date(params[:date]).values
  rescue => e
    self.errors.add(:base, e.message)    
  end

  # Read and process the sources
  def read_and_process(params)
    readers = read_all_sources(params)
    merge_reader_data(readers)
    results = add_parent(params)
    add_managed_children(results) if managed?(configuration[:parent_klass].child_klass)
    results
  end

  # Merge the parent sets. Error if they dont match!
  def merge_reader_data(readers)
    dup_count = 0
    readers.each do |reader|
      reader.engine.parent_set.each do |k, v| 
        if @parent_set.key?(k)
          next if @parent_set[k].merge(v)
          msg =  "Duplicate identifier #{k} detected during import of #{reader.full_path} and cannot merge as a difference has been detected"
          self.errors.add(:base, msg)
          merge_errors(@parent_set[k], self)
          ConsoleLogger.info(self.class.name, __method__.to_s, msg)
          dup_count += 1
        else
          @parent_set[k] = v
        end
      end
      @tags += reader.engine.sheet_tags
    end
    ConsoleLogger.info(self.class.name, __method__.to_s, "Duplicate identifier count #{dup_count}.")
  end

  # Process Results. Process the results structure to convert to objects
  def process_results(results)
    filtered = []
    tag_set = []
    klass = configuration[:parent_klass]
    child_klass = klass.child_klass
    return results if !managed?(child_klass)
    parent = results[:parent]
    parent.add_additional_tags(tag_set) 
    scope = klass.owner.ra_namespace
    results[:managed_children].each_with_index do |child, index| 
      previous_info = child_klass.latest({scope: scope, identifier: child.identifier})
      previous = previous_info.nil? ? nil : child_klass.find_full(previous_info.id) 
      actual = child.replace_if_no_change(previous)
      parent.add(actual, index + 1) # Parent needs ref to child whatever new or previous
      next if actual.uri != child.uri # No changes if actual = previous, so skip next
      child.add_additional_tags(previous, tag_set) 
      filtered << child 
    end
    return {parent: parent, managed_children: filtered, tags: tag_set}
  end

end