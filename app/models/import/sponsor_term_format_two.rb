# Sponsor Term Format 2 Importer. Sanofi new code list format
#
# @author Dave Iberson-Hurst
# @since 2.39.0
class Import::SponsorTermFormatTwo < Import

  include Import::Utility
  include Import::STFOClasses

  C_V1 = "01/01/1900".to_datetime 
  C_V2 = "01/01/2100".to_datetime 
  C_FORMAT_MAP = [
    {range: (C_V1...C_V2), sheet: :version_1}]
  C_DEFAULT = :version_1

  # Import. Import the rectangular structure
  #
  # @param [Hash] params a parameter hash
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    @tags = []
    @parent_set = {}
    readers = read_all_sources(params)
    merge_reader_data(readers)
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
      description: "Import of Sponsor Terminology",
      parent_klass: Import::STFOClasses::STFOThesaurus,
      reader_klass: Excel,
      import_type: :sponsor_term_format_two,
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

  # Merge the parent sets. 
  def merge_reader_data(readers)
    readers.each do |reader|
      reader.engine.parent_set.each do |k, v|
        @parent_set[k] = v
        merge_errors(@parent_set[k], self)
      end
    end
  end

  # Process the results
  def process_results(results)
    results[:managed_children].each_with_index do |child, index| 
      child.set_import(identifier: child.identifier, label: child.label, 
      semantic_version: SemanticVersion.first, version_label: "", 
      version: IsoScopedIdentifierV2.first_version, date: Time.now, ordinal: index + 1)
      filtered << child
    end
    return {parent: nil, managed_children: filtered, tags: []}
  end

end