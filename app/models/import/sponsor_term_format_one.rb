# Sponsor Term Format 1 Importer
#
# @author Dave Iberson-Hurst
# @since 2.25.0
class Import::SponsorTermFormatOne < Import

  include Import::Utility
  include Import::STFOClasses

  C_V2 = "01/01/1900".to_datetime 
  C_V3 = "01/06/2019".to_datetime 
  C_FORMAT_MAP = [
    {range: (C_V2...C_V3), sheet: :version_2}, 
    {range: (C_V3...DateTime.now.to_date+1), sheet: :version_3}]
  C_DEFAULT = :version_3

  # Import. Import the rectangular structure
  #
  # @param [Hash] params a parameter hash
  # @option params [String] :identifier the identifier
  # @option params [String] :semantic_version the semantic version
  # @option params [String] :version_label the version label
  # @option params [String] :version the version
  # @option params [String] :date the date of issue
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @option params [Uri] :term the uri for the reference term to be used
  # @return [Void] no return value
  def import(params)
    @tags = []
    @parent_set = {}
    @th = Thesaurus.find_minimum(params[:uri])
    readers = read_all_sources(params)
    merge_reader_data(readers)
    results = add_parent(params)
    add_managed_children(results) if managed?(configuration[:parent_klass].child_klass)
  # objects = self.errors.empty? ? process_results(results) : {parent: self, managed_children: []}
  # object_errors?(objects) ? save_error_file(objects) : save_load_file(objects)
    objects = process_results(results)
    save_error_file(objects)
    save_load_file(objects) 
    
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
      description: "Import of Sponsor Terminology",
      parent_klass: Import::STFOClasses::STFOThesaurus,
      reader_klass: Excel,
      import_type: :sponsor_term_format_one,
      format: :format,
      version_label: :date,
      label: "Controlled Terminology"
    }
  end

  # Get the format
  #
  # @param [Hash] params a set of parameters
  # @option [String] :date a day date as a string
  # @return [Symbol] the format as a symbol. Default to C_DEFAULT if non found.
  def format(params)
    result = C_FORMAT_MAP.select{|x| x[:range].cover?(params[:date].to_datetime)}
    return C_DEFAULT if result.empty?
    return result.first[:sheet]
  end

private

  # Merge the parent sets. Error if they dont match!
  def merge_reader_data(readers)
    readers.each do |reader|
      reader.engine.parent_set.each do |k, v| 
        @parent_set[k] = v
        merge_errors(@parent_set[k], self)
      end
      @tags += reader.engine.tags
    end
  end

  # Process the results
  def process_results(results)
    extensions = {}
    filtered = []
    klass = configuration[:parent_klass]
    child_klass = klass.child_klass
    return results if !managed?(child_klass)
    parent = results[:parent]
    results[:managed_children].each_with_index do |child, index| 
      # Order of the checks is important
      if child.referenced?(@th)
        add_log("Reference Sponsor detected: #{child.identifier}")
        ref = child.reference(@th)
        next if ref.nil?
        parent.add(ref, index + 1)
        filtered << ref
      elsif child.subset_of_extension?(extensions)
        add_log("Subset of extension detected: #{child.identifier}")
        ref = child.to_subset_of_extension(extensions)
        next if ref.nil?
        parent.add(ref, index + 1) 
        filtered << ref
      elsif child.subset?
        add_log("Subset detected: #{child.identifier}")
        ref = child.to_cdisc_subset(@th)
        ref = child.to_sponsor_subset(filtered) if ref.nil? # Note using previously processed sponsor CLs.
        if ref.nil?
          add_error(child, "Code list subset cannot be aligned, identifier '#{child.identifier}'.")
        else
          parent.add(ref, index + 1) 
          filtered << ref
        end
      elsif child.extension?(@th)
        add_log("Extension detected: #{child.identifier}")
        ref = child.to_extension(@th)
        next if ref.nil?
        parent.add(ref, index + 1) 
        filtered << ref
        extensions[ref.identifier] = ref
      elsif child.sponsor?
        add_log("Sponsor detected: #{child.identifier}")
        parent.add(child, index + 1) 
        filtered << child
      elsif child.hybrid_sponsor?
        add_log("Hybrid Sponsor detected: #{child.identifier}")
        ref = child.to_hybrid_sponsor(@th)
        parent.add(ref, index + 1) 
        filtered << ref
      else
        add_error(child, "Code list type not detected, identifier '#{child.identifier}'.")
        filtered << child
      end
    end
    return {parent: parent, managed_children: filtered, tags: []}
  end

private

  # Add error
  def add_error(object, msg)
    puts colourize("#{msg}", "red")
    object.errors.add(:base, msg)
  end

  # Add error
  def add_log(msg)
    puts colourize("#{msg}", "blue")
    ConsoleLogger.info(self.class.name, "add_log", msg)
  end

end