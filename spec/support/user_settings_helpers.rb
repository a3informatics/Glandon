module UserSettingsHelpers

  def us_expected_metadata
    result =
    {
      :edit_lock_warning => 
      {
      	:type=>"coded", 
      	:values=>{:"30s"=>30, :"1m"=>60, :"1m 30s"=>90, :"2m"=>120, :"3m"=>180, :"5m"=>300}, 
      	:default_value=>60, 
      	:label=>"Edit Lock Warning"
      },
      :paper_size => {:type=>"enum", :values=>["A3", "A4", "Letter"], :default_value=>"A4", :label=>"Paper Size"},
      :table_rows => 
      {
      	:type=>"coded", 
      	:values=>{'5': 5, '10': 10, '15': 15, '25': 25, '50': 50, '100': 100, All: -1}, 
      	:default_value=>10, 
      	:label=>"Table Rows"
      },
      :user_name_display => {:type=>"enum", :values=>["Yes", "No"], :default_value=>"Yes", :label=>"Display User Name"},
      :user_role_display => {:type=>"enum", :values=>["Yes", "No"], :default_value=>"Yes", :label=>"Display User Roles"},
      :max_term_display => 
      {
      	:type=>"coded", 
      	:values=>{'4': 4, '8': 8, '12': 12}, 
      	:default_value=>8, 
      	:label=>"Terminology Versions Displayed"
      }
    }
  end

end