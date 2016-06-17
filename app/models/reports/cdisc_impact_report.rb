class Reports::CdiscImpactReport < Reports::PdfReport

  TABLE_HEADERS = ["Code List", "Item", "Label", "Old Submission Value", "New Submission Value", "Impact Item Type", "Item Label", "Item identifier" , "Via"]
  C_CLASS_NAME = "Reports::CdiscImpactReport"

  def initialize(results, user)
    super('Report', 'CDISC Submission Changes Impact', user)
    start_new_page(:layout => :landscape)
    table_data = Array.new
    table_data << TABLE_HEADERS
    results.each do |result|
      row = Array.new
      ConsoleLogger::log(C_CLASS_NAME,"impact_flatten", "Result=#{result.to_json}")  
      row << result[:parent_identifier]
      row << result[:identifier]
      row << result[:label]
      row << result[:old_notation]
      row << result[:new_notation]
      row << result[:item_type]
      row << result[:item_label]
      row << result[:item_identifier]
      row << result[:item_via]
      table_data << row
    end
    table(table_data, :header => true, :column_widths => [60, 60, 100, 100, 100])  do
      row(0).background_color = "F0F0F0"
      style(row(0), :size => 10, :font_style => :bold)
    end
    # Footer
    footer
  end

end