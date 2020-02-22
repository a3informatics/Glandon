# Sponsor Term Format 1 Importer
#
# @author Dave Iberson-Hurst
# @since 2.25.0
class Import::SponsorTermFormatOne < Import

  include Import::Utility
  include Import::STFOClasses

  C_V2 = "01/01/1900".to_datetime 
  C_V3 = "01/09/2019".to_datetime 
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
  # @option params [String] :fixes filename for import fixes
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @option params [Uri] :term the uri for the reference term to be used
  # @return [Void] no return value
  def import(params)
    @tags = []
    @parent_set = {}
    set_thesarus(params)
    @fixes = Fixes.new(params[:fixes])
    readers = read_all_sources(params)
    merge_reader_data(readers)
    
    # Temp code
    puts colourize("Errors on read: #{self.errors.full_messages}", "red") if self.errors.any?

    # Correct code
    results = add_parent(params)
    add_managed_children(results) if managed?(configuration[:parent_klass].child_klass)
    
    # Correct code
    # objects = self.errors.empty? ? process_results(results) : {parent: self, managed_children: []}
    # object_errors?(objects) ? save_error_file(objects) : save_load_file(objects)
    
    # Temp code for getting it working
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

  # Set future  
  def set_thesarus(params)
    @th = Thesaurus.find_minimum(params[:uri])
    uri = Thesaurus.history_uris(identifier: ::CdiscTerm::C_IDENTIFIER, scope: ::IsoRegistrationAuthority.cdisc_scope).first
    @future_th = Thesaurus.find_minimum(uri)
  end

  # Merge the parent sets. Error if they dont match!
  def merge_reader_data(readers)
    readers.each do |reader|
      reader.engine.parent_set.each do |k, v|
        v.add_tags_no_save(reader.engine.tags) 
        @parent_set[k] = v
        merge_errors(@parent_set[k], self)
      end
    end
  end

  # Process the results
  def process_results(results)
    setup(results)
    ref = OperationalReferenceV3.new(reference: @th)
    ref.uri = ref.create_uri(@th.uri)
    @parent.reference = ref
    results[:managed_children].each_with_index do |child, index| 
      # Order of the checks is important
      existing_ref = false
      if child.referenced?(@th)
        add_log("Reference Sponsor detected: #{child.identifier}")
        ref = child.reference(@th)
        existing_ref = true
      elsif child.future_referenced?(@future_th)
        add_log("Future Reference Sponsor detected: #{child.identifier}")
        ref = child
      elsif child.subset_of_extension?(@extensions)
        add_log("Subset of extension detected: #{child.identifier}")
        ref = child.to_subset_of_extension(@extensions)
      elsif child.subset?
        add_log("Subset detected: #{child.identifier}")
        ref = child.to_cdisc_subset(@th)
        ref = child.to_sponsor_subset(@filtered) if ref.nil? # Note using previously processed sponsor CLs.
        add_error(child, "Code list subset cannot be aligned, identifier '#{child.identifier}'.") if ref.nil?
      elsif child.extension?(@th)
        add_log("Extension detected: #{child.identifier}")
        ref = child.to_extension(@th, @fixes)
        @extensions[ref.identifier] = ref if !ref.nil?
      elsif child.sponsor?
        add_log("Sponsor detected: #{child.identifier}")
        ref = child
      elsif child.hybrid_sponsor?
        add_log("Hybrid Sponsor detected: #{child.identifier}")
        ref = child.to_hybrid_sponsor(@th, @fixes)
      elsif child.future_hybrid_sponsor?  
        add_log("Future Hybrid Sponsor detected: #{child.identifier}")
        ref = child
      else
        add_error(@parent, "Code list type not detected, identifier '#{child.identifier}'.")
        ref = nil
      end
      next if ref.nil?
      check_and_add(ref, index, existing_ref)
    end
    return {parent: @parent, managed_children: @filtered, tags: []}
  end

  # Setup data for processing of results
  def setup(results)
    klass = configuration[:parent_klass]
    @child_klass = klass.child_klass
    @parent = results[:parent]
    @scope = klass.owner.ra_namespace
    @filtered = []
    @extensions = {}
  end

  # Check for a change in an item
  def check_and_add(ref, index, existing_ref)
    existing_ref ? @parent.add(ref, index + 1) : check_against_previous(ref, index)
  end

  def check_against_previous(ref, index)
    previous_info = @child_klass.latest({scope: @scope, identifier: ref.identifier})
    if previous_info.nil?
      add_to_data(ref, index, true)
      add_log("No previous, new item: #{ref.uri}")
    else
      previous = @child_klass.find_full(previous_info.id) 
      update_version(ref, previous.version + 1)
      item = check_for_change(ref, previous) 
      add_log("New item: #{item.uri}, previous item: #{previous.uri}")
      add_to_data(item, index, item.uri != previous.uri) # No changes if item = previous
    end
  end

  def update_version(ref, new_version)
    add_log("Pre narrower: #{ref.narrower.map{|x| x.uri.to_s}}")
    stack = Stack.new
    ref.extends = stack.push(ref.extends)
    ref.subsets = stack.push(ref.subsets)
    ref.is_ordered = stack.push(ref.is_ordered)
    ref.update_version(new_version)
    ref.is_ordered = stack.pop
    ref.subsets = stack.pop
    ref.extends = stack.pop
    add_log("Post narrower: #{ref.narrower.map{|x| x.uri.to_s}}")
  end

  def check_for_change(current, previous)
    return current if !subset_match?(current, previous)
    current.replace_if_no_change(previous)
  end

  def add_to_data(item, index, new_item)
    @parent.add(item, index + 1) 
    return if !new_item
    @filtered << item 
  end

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

  # Check subset item sets match.
  def subset_match?(ref, previous)
    return true if !ref.subset?
    add_log("Checking subset detected: #{ref.identifier}, #{previous.identifier}")
    ref.subset_list_equal?(previous.is_ordered)
  end

  # Simple stack class
  class Stack

    def initialize
      @stack = []
    end

    def push(item)
      @stack << item
      nil
    end

    def pop
      @stack.pop
    end

  end

  # Class to access fixes
  class Fixes

    def initialize(file_path)
      @config = file_path.blank? ? nil : YAML.load(File.read(file_path)).deep_symbolize_keys
    end

    def fix(cl, cli)
      return nil if @config.nil?
      uri = @config.dig(:fixes, cl.to_sym, cli.to_sym)
    puts colourize("Checking fix #{cl}, #{cli}, uri=#{uri}", "blue")
      return nil if uri.nil?
      Uri.new(uri: uri)
    end

  end

end