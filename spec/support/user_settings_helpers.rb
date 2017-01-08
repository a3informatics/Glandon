module UserSettingsHelpers

  def us_expected_metadata
    result =
    {
      :paper_size => {:type=>"enum", :values=>["A3", "A4", "Letter"], :default_value=>"A4", :label=>"Paper Size"},
      :table_rows => {:type=>"coded", :values=>{'5': 5, '10': 10, '15': 15, '25': 25, '50': 50, '100': 100, All: -1}, :default_value=>10, :label=>"Table Rows"}
    }
  end

end