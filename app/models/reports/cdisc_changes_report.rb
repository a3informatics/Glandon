class Reports::CdiscChangesReport < Reports::PdfReport

  TABLE_WIDTHS = [40, 40, 100]
  TABLE_HEADERS = ["Code List", "Item", "Label"]

  def initialize(results, user)
    super('Report', 'CDISC Terminology Changes', user)
    # Build header
    entry = results.values[0]
    result = entry["result"]
    title_row = ["Code List", "Label", "Submission Value"]
    result.each do |vKey, status|
        title_row << vKey
    end
    # Init
    rows = 1
    counter = 0
    table_data = main_setup(title_row)
    # Build data
    results.each do |key, entry|
      row = []
      cli = entry["cl"]
      result = entry["result"]
      row << cli["identifier"]
      row << cli["label"]
      row << cli["notation"]
      result.each do |vKey, status|
        if status == "."
          row << "."
        elsif status == "X"
          row << "X"
        elsif status == "M"
          row << "M"
        else
          row << ""
        end
        counter += 1
      end
      table_data << row
      if rows % 12 == 0
        # New page
        start_new_page(:layout => :landscape)
        # Output current content
        table(table_data, :header => true, :column_widths => [60, 150, 100])  do
          row(0).background_color = "F0F0F0"
          style(row(0), :size => 10, :font_style => :bold)
          style(columns(3..-1), :align => :center)
        end
        text "\n"
        text "\n"
        text "'.' = Unchanged, 'M' = Modified, 'X' = Deleted, ' ' = Not Defined", size: 9, align: :center, :style => :italic
        # Init again
        rows = 1
        counter = 0
        table_data = main_setup(title_row)
      else
        rows += 1
      end
    end
    if counter > 0
      # New page
      start_new_page(:layout => :landscape)
      # Output current content if anything left over
      table(table_data, :header => true, :column_widths => [60, 150, 100]) do
        row(0).background_color = "F0F0F0"
        style(row(0), :size => 10, :font_style => :bold)
        style(columns(3..-1), :align => :center)
      end
    end
    # Footer
    footer
  end

  def main_setup(headers)
    local = Array.new
    local << headers
  end

end