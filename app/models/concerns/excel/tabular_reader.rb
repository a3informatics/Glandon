# AdamModel. Class for processing ADaM Model Excel Files
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Excel::TabularReader < Excel

  C_CLASS_NAME = self.name

  # Read. Reads the excel file for SDTM Model.
  #
  # @params [Hash] params a parameter hash
  # @option [String] :label the label
  # @option [String] :identifier the identifier
  # @option [String] :semantic_version the semantic version
  # @option [String] :version_label the version label
  # @option [String] :version the version
  # @option [String] :date the date of issue
  # @option [Hash] :extra set of extra information including the keys for the parent and child records and the 
  #  import and sheet names
  # @return [Hash] hash of result structures
  def read(klass, params)
    ordinal = 1
    results = []
    parent = klass.new
    instance = parent.import_operation(identifier: params[:identifier], label: params[:label], semantic_version: params[:semantic_version], 
      version_label: params[:version_label], version: params[:version], date: params[:date], ordinal: 1)
    results << {:type => params[:extra][:parent], :order => 1, :instance => instance}
    check_sheet(params[:extra][:import], params[:extra][:sheet])
    process_sheet(params[:extra][:import], params[:extra][:sheet])
    self.engine.parent_set.each do |key, item| 
      results << {type: params[:extra][:child], order: ordinal, instance: child(item, instance, ordinal)}
      ordinal += 1
    end
    return results
  end

private

  # Build the associated datasets
  def child(dataset, parent, ordinal)
    instance = dataset.import_operation(identifier: dataset.identifier, label: parent[:managed_item][:label], 
      semantic_version: parent[:operation][:new_semantic_version], version_label: parent[:managed_item][:version_label], 
      version: parent[:operation][:new_version], date: parent[:managed_item][:creation_date], ordinal: ordinal)
    instance[:managed_item][:children] = []
    dataset.children.each {|v| instance[:managed_item][:children] << v.to_hash}
    return instance
  end        
  
end

    