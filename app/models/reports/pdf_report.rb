class Reports::PdfReport < Prawn::Document

  # Often-Used Constants

  TABLE_ROW_COLORS = ["FFFFFF","DDDDDD"]
  TABLE_FONT_SIZE = 9
  TABLE_BORDER_STYLE = :grid

  def initialize(default_prawn_options={})
    super(default_prawn_options)
    font_size 10
  end

  def header(doc_type=nil, title=nil)
    #image 'app/assets/images/favicon.gif', height: 30
    text "ACME Pharmaceuticals", size: 18, style: :bold, align: :center
    move_down 200
    if doc_type
      text doc_type, size: 24, style: :bold, align: :center
    end
    if title
      text title, size: 24, style: :bold, align: :center
    end
    move_down 200
  end

  def footer
    # ...
  end

  # ... More helpers

end