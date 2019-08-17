module UserSettingsHelpers

  def us_expected_metadata
    result =
    {
      :edit_lock_warning => 
      {
      	:type=>"coded", 
      	:values=>{:"30s"=>30, :"1m"=>60, :"1m 30s"=>90, :"2m"=>120, :"3m"=>180, :"5m"=>300}, 
      	:default_value=>60, 
      	:label=>"Edit Lock Warning",
      	:description=>"The time at which a warning will be issued before an edit lock is lost. Half way to the lock being lost a second warning will be issued. Times are expressed in minutes and seconds."
      },
      :paper_size => 
      {
      	:type=>"enum", 
      	:values=>["A3", "A4", "Letter"], 
      	:default_value=>"A4", 
      	:label=>"Paper Size",
      	:description=>"The paper size to be used for PDF reports exported by the system."
      },
      :table_rows => 
      {
      	:type=>"coded", 
      	:values=>{'5': 5, '10': 10, '15': 15, '25': 25, '50': 50, '100': 100, All: -1}, 
      	:default_value=>10, 
      	:label=>"Table Rows",
      	:description=>"The number of rows to be used within table displays."
      },
      :user_name_display => 
      {
      	:type=>"enum", 
      	:values=>["Yes", "No"], 
      	:default_value=>"Yes", 
      	:label=>"Display User Name",
      	:description=>"Display the user name in the top navigation bar."
      },
      :user_role_display => 
      {
      	:type=>"enum", 
      	:values=>["Yes", "No"], 
      	:default_value=>"Yes", 
      	:label=>"Display User Roles",
      	:description=>"Display the user roles in the top navigation bar."
      },
      :max_term_display => 
      {
      	:type=>"coded", 
      	:values=>{'4': 4, '8': 8, '12': 12}, 
      	:default_value=>4, 
      	:label=>"Terminology Versions Displayed",
      	:description=>"Number of terminologies to be displayed in change tables."
      }
    }
  end

end