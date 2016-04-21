class Reports::CdiscImpactReport < Reports::PdfReport

  TABLE_HEADERS = ["Code List", "Item", "Old Submission Value", "New Submission Value", "Biomedical Concept", "Operational"]

  def initialize(results, user)
    super('Report', 'CDISC Submission Changes Impact', user)
    start_new_page(:layout => :landscape)
    table_data = Array.new
    table_data << TABLE_HEADERS
    results.each do |cli|
      bcs = cli["bcs"]
      bcs.each do |bc|
        forms = bc["forms"]
        domains = bc["domains"]
        if forms.length > 0
          forms.each do |form|
            row = []
            row << cli["parent_identifier"]
            row << cli["identifier"]
            row << cli["old_notation"]
            row << cli["new_notation"]
            row << bc["label"] + "\n(" + bc["identifier"] + ")"
            row << form["label"] + "\n(" + form["identifier"] + ")"
            table_data << row
          end
        end
        if domains.length > 0
          domains.each do |domain|
            row = []
            row << cli["parent_identifier"]
            row << cli["identifier"]
            row << cli["old_notation"]
            row << cli["new_notation"]
            row << bc["label"] + "\n(" + bc["identifier"] + ")"
            row << domain["label"] + "\n(" + domain["identifier"] + ")"
            table_data << row
          end
        end
        if forms.length == 0 && domains.length == 0
          row = []
          row << cli["parent_identifier"]
          row << cli["identifier"]
          row << cli["old_notation"]
          row << cli["new_notation"]
          row << ""
          row << ""
          table_data << row
        end
      end
    end
    table(table_data, :header => true, :column_widths => [60, 60, 150, 150, 150, 150])  do
      row(0).background_color = "F0F0F0"
      style(row(0), :size => 10, :font_style => :bold)
    end
    # Footer
    footer
  end

end