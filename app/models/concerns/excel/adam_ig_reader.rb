# AdamIgReader. Class for processing ADaM IG Excel Files
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Excel::AdamIgReader < Excel::TabularReader

  C_CLASS_NAME = self.name

  # Read. Reads the excel file for ADaM IG.
  #
  # @params [Hash] params a parameter hash
  # @option [String] :version_label the version label. Will be used as the semantic version
  # @option [String] :version the version
  # @option [String] :date the data of issue
  # @return [Hash] Import hash containing the import items
  def read(params)
    super(AdamIg, {identifier: AdamIg::C_IDENTIFIER, label: "ADaM IG #{params[:date]}", semantic_version: params[:semantic_version], 
      version_label: params[:semantic_version], version: params[:version], date: params[:date],
      excel: {import: :adam_ig, sheet: :main}})
  end

end

    