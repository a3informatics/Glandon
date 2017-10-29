module ViewHelpers

  def expect_table_cell_text(table, row, col, text)
    expect(rendered).to have_selector("table##{table} tbody tr:nth-of-type(#{row}) td:nth-of-type(#{col})", text: "#{text}")
  end

  def expect_table_cell_link(table, row, col, text)
  	if text.nil?
    	expect(rendered).to_not have_selector("table##{table} tbody tr:nth-of-type(#{row}) td:nth-of-type(#{col}) a")
  	else
    	expect(rendered).to have_selector("table##{table} tbody tr:nth-of-type(#{row}) td:nth-of-type(#{col}) a", text: "#{text}")
    end
  end

  def expect_link(id)
  	expect(rendered).to have_selector("a##{id}")
  end

  def expect_button(id)
  	expect(rendered).to have_selector("input##{id}")
  end
  
  def expect_submit_button(value)
  	expect(rendered).to have_selector("input[type=submit][value='#{value}']")
  end

  def page_to_s
  	puts @rendered
  end

end