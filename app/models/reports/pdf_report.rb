class Reports::PdfReport < Prawn::Document

  # Constants
  C_CLASS_NAME = "Reports::PdfReport"

  # Often-Used Constants
  TABLE_ROW_COLORS = ["FFFFFF","DDDDDD"]
  TABLE_FONT_SIZE = 9
  TABLE_BORDER_STYLE = :grid

  def initialize(doc_type, title, user)
    # Get configuration parameters
    name = APP_CONFIG['organization_title']
    image_file = APP_CONFIG['organization_image_file']
    dir = Rails.root.join("app", "assets", "images")
    file = File.join(dir, image_file)
    # Set document metadata
    info = {
     :Title => title,
     :Author => "Application Generated",
     :Subject => doc_type,
     :Creator => "Glandon MDR",
     :Producer => "Prawn Gem",
     :CreationDate => Time.now
    }
    # Set paper size and layout
    paper_size = user.paper_size.upcase
    # Create the PDF document
    super({:page_size => paper_size, :layout => :portrait, :info => info})
    font_size 9
    # Generate the document front sheet.  
    image file, height: 75,  position: :center, position: :center
    text name, size: 18, style: :bold, align: :center
    move_down 200
    if doc_type
      text doc_type, size: 24, style: :bold, align: :center
    end
    if title
      text title, size: 24, style: :bold, align: :center
    end
    move_down 200
  end

  def header
    # ...
  end

  def footer
    # Page numbers
    string = "page <page> of <total>"
    options = { 
      :at => [bounds.right - 150, 0],
      :width => 150,
      :align => :right,
      :start_count_at => 1
    }
    number_pages string, options
  end

  # ... More helpers

end