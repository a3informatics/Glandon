# AdamModel. Class for processing ADaM Model Excel Files
#
# @author Dave Iberson-Hurst
# @since 2.20.3
class AdamIg

  C_CLASS_NAME = self.name

  attr_reader :excel

  # Initialize. Opens the workbook ready for processing.
  #
  # @param [Pathname] full_path the Pathname object for the file to be opened.
  # @return [Void] no return value
  def initialize(full_path)
    @excel = Excel.new(full_path)
  end

  # Reads the excel file for SDTM Model.
  def read(params)
    reasults = []
    object = AdamIg.new
    instance = operation_hash(object, identifier: AdamIg::C_IDENTIFIER, label: "ADaM IG #{params[:date]}", 
      semantic_version[:version_label], version_label: params[:version_label], version: params[:version], date: params[:date], ordinal: 1)
    results << {:type => "ADAM_IG", :order => 1, :instance => instance}
    @workbook.default_sheet = @workbook.sheets[0]
    check_sheet(sheet_info)
    maps = map_info
    ((@workbook.first_row + 1) .. @workbook.last_row).each do |row|
      dataset = parent(row, 1, AdamIgDataset, maps[0])
      variable = variable(row, 4)
      variable.label = check_cell(row, 5)
      variable.datatype = datatype_classification(row, 6, maps[5])
      variable.ct = ct_reference(row, 7)
      variable.ct_notes = ct_other(row, 7)
      variable.compliance = core_classification(row, 8, maps[7])
      variable.notes = check_cell(row, 5, false)
    end
    @excel.parent_set.each do |d|
      results << {type: "ADAM_IG", order: 1, instance: dataset(d,"XXX", instance)}
    end
    return results
  end

private

  def dataset(dataset, identifier, parent)
    # Create the instance for the model
    instance = operation_hash(dataset, identifier: AdamIg::C_IDENTIFIER, label: "ADaM IG #{params[:date]}", 
      semantic_version[:version_label], version_label: parent[:managed_item][:scoped_identifier][:version_label], 
      version: parent[:operation][:new_version], date: parent[:managed_item][:creation_date], ordinal: 1)
    ordinal = 1
    dataset.each {|v| children << variable.to_hash}
    return operation
  end        
  
end

    