class Reports::CdiscSubmissionReport < Reports::PdfReport

  TABLE_WIDTHS = [40, 40, 100]
  TABLE_HEADERS = ["Code List", "Item", "Label"]

  def initialize(results)
    super()
    
    # Header
    header 'Submission Change Report'
    
    start_new_page(:size => "A4", :layout => :landscape)
    table_data = []
    
    # Build headers
    entry = results.values[0]
    result = entry["result"]
    row = ["Code List", "Item", "Label"]
    result.each do |vKey, status|
        row << vKey
    end
    table_data << row

    results.each do |key, entry|
      row = []
      cli = entry["cli"]
      result = entry["result"]
      row << cli["parent_identifier"]
      row << cli["identifier"]
      row << cli["label"]
      result.each do |vKey, status|
        row << status
      end
      table_data << row
    end
    table(table_data, :header => true)
    
    # Footer
    footer

  end

end