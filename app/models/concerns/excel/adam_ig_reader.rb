# AdamModel. Class for processing ADaM Model Excel Files
#
# @author Dave Iberson-Hurst
# @since 2.20.3
class Excel::AdamIgReader < Excel

  C_CLASS_NAME = self.name

  # Read. Reads the excel file for SDTM Model.
  #
  # @params [Hash] params a parameter hash
  # @option [String] :version_label the version label. Will be used as the semantic version
  # @option [String] :version the version
  # @option [String] :date the data of issue
  # @return [Hash] Import hash containing the import items
  def read(params)
    results = []
    object = AdamIg.new
    ig_instance = object.import_operation(identifier: AdamIg::C_IDENTIFIER, label: "ADaM IG #{params[:date]}", semantic_version: params[:version_label], 
      version_label: params[:version_label], version: params[:version], date: params[:date], ordinal: 1)
    results << {:type => "ADAM_IG", :order => 1, :instance => instance}
    check_sheet(:adam_ig, :main)
    process_sheet(:adam_ig, :main)
    self.engine.parent_set.each {|d| results << {type: "ADAM_IG", order: 1, instance: dataset(d, ig_instance)}}
    return results
  end

private

  # Build the associated datasets
  def dataset(dataset, parent)
    # Create the instance for the model
    instance = dataset.import_operation(identifier: dataset.identifier, label: "ADaM IG #{params[:date]}", 
      semantic_version: params[:version_label], version_label: parent[:managed_item][:scoped_identifier][:version_label], 
      version: parent[:operation][:new_version], date: parent[:managed_item][:creation_date], ordinal: 1)
    ordinal = 1
    dataset.each {|v| children << variable.to_hash}
    return operation
  end        
  
end

    