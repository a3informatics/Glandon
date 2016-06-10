class Reports::CrfReport < Reports::PdfReport

  C_CLASS_NAME = "Report::CrfReport"

  def initialize(node, options, annotations, user)
    ConsoleLogger.log(C_CLASS_NAME, "Initialize", "Node=" + node.to_json.to_s)
    title = "#{node[:label]}\n#{node[:identifier]}"
    super('CRF', title, user)
    start_new_page(:layout => :portrait)
    # Build data    
    ci_nodes = Array.new
    note_nodes = Array.new
    table_data = crf_node(node, options, annotations, ci_nodes, note_nodes)
    # Output table
    #table(table_data, :cell_style => { :inline_format => true }, :header => true, :column_widths => [150, 150, 250])  do
    table(table_data, :cell_style => { :inline_format => true}, :header => true, :column_widths => [125])  do
      cells.padding = 5
      cells.borders = []
      row(0).background_color = "F0F0F0"
      style(row(0), :size => 14, :font_style => :bold)
    end
    # Completion instructions
    if ci_nodes.length > 0
      data = format_nodes(ci_nodes, {:form => :formCompletion, :default => :completion})
      data.insert(0, ["Index", "Element", "Completion Instruction"])
      start_new_page(:layout => :portrait)
      table(data, :cell_style => { :inline_format => true}, :header => true, :column_widths => [75])  do
        cells.padding = 5
        cells.borders = []
        row(0).background_color = "F0F0F0"
        style(row(0), :size => 14, :font_style => :bold)
      end
    end
    # Notes
    if note_nodes.length > 0 
      data = format_nodes(note_nodes, {:form => :formNote, :default => :note})
      data.insert(0, ["Index", "Element", "Note"])
      start_new_page(:layout => :portrait)
      table(data, :cell_style => { :inline_format => true}, :header => true, :column_widths => [75])  do
        cells.padding = 5
        cells.borders = []
        row(0).background_color = "F0F0F0"
        style(row(0), :size => 14, :font_style => :bold)
      end
    end
    # Footer
    footer
  end

private

  def crf_node(node, options, annotations, ci_nodes, note_nodes)
    #ConsoleLogger.log(C_CLASS_NAME, "crfNode", "Node=" + node.to_s)
    rows = Array.new
    if node[:type] == "Form"
      add_nodes(node, ci_nodes, {:form => :formCompletion, :default => :completion})
      add_nodes(node, note_nodes, {:form => :formNote, :default => :note})
      domain_annotation = ""
      if options[:annotate] 
        domains = annotations.uniq {|entry| entry[:domain] }
        domains.each do |domain|
          suffix = ""
          prefix = domain[:domain_prefix].to_s
          if domain[:domain_long_name].to_s != ""
            suffix = "=" + domain[:domain_long_name].to_s
          end
          domain_annotation += domain[:domain_prefix].to_s + suffix + "\n"
        end
      end
      rows << [{:colspan => 2, :content => node[:label].to_s}, "<color rgb='FF0000'>#{domain_annotation}</color>"]
      node[:children].each do |child|
        rows += crf_node(child, options, annotations, ci_nodes, note_nodes)
      end
    elsif node[:type] == "CommonGroup"
      rows << [{:colspan => 3, :content => node[:label].to_s}]
      node[:children].each do |child|
        rows += crf_node(child, options, annotations, ci_nodes, note_nodes)
      end
    elsif node[:type] == "Group"
      add_nodes(node, ci_nodes, {:form => :formCompletion, :default => :completion})
      add_nodes(node, note_nodes, {:form => :formNote, :default => :note})
      rows << [{:colspan => 3, :content => node[:label].to_s}]
      if node[:repeating]
        rows << [{:colspan => 3, :content => "Repeating to go here"}]
      #  html += '<tr>'
      #  html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
      #  html += '<tr>'
      #  node[:children].each do |child|
      #    html += '<th>' + child[:qText] + '</th>'
      #  end 
      #  html += '</tr>'
      #  if options[:annotate]
      #    html += '<tr>'
      #    node[:children].each do |child|
      #      html += '<td><font color="red">' + child[:mapping] + '</font></td>'
      #    end 
      #    html += '</tr>'
      #  end
      #  html += '<tr>'
      #  node[:children].each do |child|
      #    html += input_field(child, options, annotations)
      #  end 
      #  html += '</tr>'
      #  html += '</table></td>'
      #  html += '</tr>'
      else
        node[:children].each do |child|
          rows += crf_node(child, options, annotations, ci_nodes, note_nodes)
        end
      end
    elsif node[:type] == "BCGroup"
      add_nodes(node, ci_nodes, {:form => :formCompletion, :default => :completion})
      add_nodes(node, note_nodes, {:form => :formNote, :default => :note})
      rows << [{:colspan => 3, :content => node[:label].to_s}]
      node[:children].each do |child|
        rows += crf_node(child, options, annotations, ci_nodes, note_nodes)
      end
    elsif node[:type] == "Placeholder"
      add_nodes(node, ci_nodes, {:form => :formCompletion, :default => :completion})
      add_nodes(node, note_nodes, {:form => :formNote, :default => :note})
      rows << [{:colspan => 3, :content => "Placeholder Text\n#{node[:free_text].to_s}"}]
      node[:children].each do |child|
        rows += crf_node(child, options, annotations, ci_nodes, note_nodes)
      end
    elsif node[:type] == "Question"
      add_nodes(node, ci_nodes, {:form => :formCompletion, :default => :completion})
      add_nodes(node, note_nodes, {:form => :formNote, :default => :note})
      if options[:annotate]
        rows << ["#{node[:qText].to_s}","<color rgb='FF0000'>#{node[:mapping].to_s}</color>", input_field(node)]
      else
        rows << ["#{node[:qText].to_s}","", input_field(node)]
      end
    elsif node[:type] == "BCItem"
      add_nodes(node, ci_nodes, {:form => :formCompletion, :default => :completion})
      add_nodes(node, note_nodes, {:form => :formNote, :default => :note})
      if options[:annotate]
        first = true
        annotation_text = ""
        entries = annotations.select {|item| item[:id] == node[:id]}
        entries.each do |entry|
          if !first
            annotation_text += "\n"
          end
          annotation_text += entry[:sdtm_variable] + ' where ' + entry[:sdtm_topic_variable] + '=' + entry[:sdtm_topic_value]
          first = false
        end
        node[:otherCommon].each do |child|
          entries = annotations.select {|item| item[:id] == child[:id]}
          entries.each do |entry|
            if !first
              annotation_text += "\n"
            end
            annotation_text += entry[:sdtm_variable] + ' where ' + entry[:sdtm_topic_variable] + '=' + entry[:sdtm_topic_value]
            first = false
          end
        end
        rows << ["#{node[:qText].to_s}","<color rgb='FF0000'>#{annotation_text}</color>", input_field(node)]
      else
        rows << ["#{node[:qText].to_s}","", input_field(node)]
      end
    elsif node[:type] == "CL"
      # Ignore, already processed.
    else
      rows << ["Not Recognized: #{node[:type].to_s}","",""]
    end
    return rows
  end

  def input_field(node)
    table = nil
    if node[:datatype] == "CL"
      values = Array.new
      node[:children].each do |child|
        values_ref = child[:reference]
        if values_ref[:enabled]
          values << [ "", child[:label]]
          values << [ "", ""]
        end
      end
      table = cl_table(values)
    elsif node[:datatype] == "D+T"
      table = field_table(
        ["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y", "", "H", "H", ":", "M", "M"], 
        [:fill, :fill, :empty, :fill, :fill, :fill, :empty, :fill, :fill, :fill, :fill, :empty, :fill, :fill, :empty, :fill, :fill])
    elsif node[:datatype] == "D"
      table = field_table(
        ["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y"], 
        [:fill, :fill, :empty, :fill, :fill, :fill, :empty, :fill, :fill, :fill, :fill])
    elsif node[:datatype] == "T"
      table = field_table(
        ["H", "H", ":", "M", "M"], 
        [:fill, :fill, :empty, :fill, :fill])
    elsif node[:datatype] == "F"
      table = field_table(
        ["#", "#", "#", ".", "#", "#"], 
        [:fill, :fill, :fill, :empty, :fill, :fill])
    elsif node[:datatype] == "I"
      table = field_table(
        ["#", "#", "#"], 
        [:fill, :fill, :fill])
    else
      table = field_table(
        ["?", "?", "?"], 
        [:fill, :fill, :fill])
    end
    return table
  end

  def field_table(cell_content, cell_types)
    # Make our 1-dim table into a 2-dim table
    data = Array.new
    data << cell_content
    # Now create table
    my_table = make_table(data) do
      cells.padding = 2
      cells.size = 8
      style(row(0), :align => :center)
      row(0).borders = [:left, :right]
      row(0).width = 16
      row(0).height = 16
      cell_types.each_with_index do |cell_type, index|
        if cell_type == :fill
          row(0).column(index).borders = [:left, :right, :bottom]
        end
      end
    end
    return my_table
  end

  def cl_table(cell_content)
    my_table = make_table(cell_content) do
      cells.padding = 2
      cells.size = 8
      column(0).borders = []
      column(1).borders = []
      column(0).width = 12
      column(0).height = 12
      cell_content.each_with_index do |content, index|
        if index % 2 == 0
          row(index).column(0).borders = [:top, :left, :right, :bottom]
        else
          row(index).height = 5
        end
      end
    end
    return my_table
  end

  def add_nodes(node, nodes, symbols)
    text = ""
    symbol = symbols[:default]
    symbol = symbols[:form] if node[:type] == "Form"
    text = node[symbol]
    ConsoleLogger::log(C_CLASS_NAME,"add_nodes", "Text=" + text.to_s)
    nodes << node unless text.empty?
  end

  def format_nodes(nodes, symbols)
    rows = Array.new
    nodes.each_with_index do |node, index|
      text = ""
      symbol = symbols[:default]
      symbol = symbols[:form] if node[:type] == "Form"
      text = node[symbol]
      rows << [index+1, node[:label], text]
    end
    return rows
  end

end