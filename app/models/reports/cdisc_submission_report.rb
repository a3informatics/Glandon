class Reports::CdiscSubmissionReport < Reports::PdfReport

  TABLE_WIDTHS = [40, 40, 100]
  TABLE_HEADERS = ["Code List", "Item", "Label"]

  def initialize(results, user)
    super('Report', 'CDISC Submission Value Changes', user)
    # Build header
    entry = results.values[0]
    result = entry["result"]
    title_row = ["Code List", "Item", "Label"]
    result.each do |vKey, status|
        title_row << vKey
    end
    # Init
    rows = 1
    counter = 0
    table_data = main_setup(title_row)
    detail_data = detail_setup
    # Build data
    results.each do |key, entry|
      row = []
      cli = entry["cli"]
      result = entry["result"]
      row << cli["parent_identifier"]
      row << cli["identifier"]
      row << cli["label"]
      result.each do |vKey, status|
        if status == ""
          row << status
        else
          counter += 1
          row << "[#{counter}]"
          amendment = status.split('->')
          from = amendment[0]
          to = amendment[1].blank? ? "[***DELETED***]" : amendment[1]
          detail_data << ["[#{counter}]", "#{from}", "#{to}"]
        end
      end
      table_data << row
      if rows % 7 == 0
        # New page
        start_new_page(:layout => :landscape)
        # Output current content
        table(table_data, :header => true, :column_widths => [60, 60, 150])  do
          row(0).background_color = "F0F0F0"
          style(row(0), :size => 10, :font_style => :bold)
          style(columns(3..-1), :align => :center)
        end
        text "\n"
        table(detail_data, :column_widths => [40]) do
          row(0).background_color = "F0F0F0"
          style(row(0), :size => 10, :font_style => :bold)
        end
        # Init again
        rows = 1
        counter = 0
        table_data = main_setup(title_row)
        detail_data = detail_setup
      else
        rows += 1
      end
    end
    if counter > 0
      # New page
      start_new_page(:layout => :landscape)
      # Output current content if anything left over
      table(table_data, :header => true, :column_widths => [50, 50, 150])  do
        row(0).background_color = "F0F0F0"
        style(row(0), :size => 10, :font_style => :bold)
        style(columns(3..-1), :align => :center)
      end
      text "\n"
      table(detail_data, :column_widths => [40])  do
        row(0).background_color = "F0F0F0"
        style(row(0), :size => 10, :font_style => :bold)
      end
    end
    # Footer
    footer
  end

  def detail_setup
    local = Array.new
    local << ["Index", "From", "To"]
  end

  def main_setup(headers)
    local = Array.new
    local << headers
  end

end