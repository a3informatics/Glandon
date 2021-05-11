  TIMEOUT = 10
  PATH    = Rails.root.join("cucumber-report/downloads")

  def downloads2
    Dir[PATH.join("*")]
  end

   def download2
    downloads2.first
  end

  def downloaded2?
    b = downloads2.any? # Do this check first. Think there may have been a race condition.
    a = downloading2? 
  log("Downloading: #{a}. Downloads: #{b}. File: #{downloads2.first}")
    return !a && b
  end
  
  def wait_for_download2
    max = TIMEOUT * 10
    (1..max).each do
      break if downloaded2?
      sleep 0.1 
    end
  log("Download complete.")
  end

  def download_content2
    clear_downloads2
    wait_for_download2
    File.read(download2)
  end

  def downloading2?
    downloads2.grep(/\.crdownload$/).any?
  end

  def download_contains?(filename)
    files = Dir.entries(PATH)
    files.include?(filename)
  end

  def clear_downloads2
    FileUtils.rm_f(downloads2)
  end

 def set_path_2(sub_dir, filename)
    return Rails.root.join "#{sub_dir}/#{filename}"
  end

  def read_text_file_3(sub_dir, filename)
    text = ""
    full_path = set_path_2(sub_dir, filename)
    File.open(full_path, "r") do |f|
      text = f.read
    end
    return text
  end
##################### When statements 

When('I click Run in the context menu for the {string} report') do |string|
	context_menu_element_v2("main", string, :run)
	  wait_for_ajax(20)
end

When('I select {string} version {string} in the Item Picker') do |string1,string2|
	ip_pick_managed_items(:thesauri, [
        { identifier: string1, version: string2 }
        ], 'report-param')
	 sleep 10
end

When('I export the report in csv') do
	click_link "Export CSV"
end


##################### Then statements #####################


Then('I see Ad Hoc Reports Index page is displayed') do
	expect(page).to have_content 'Ad-Hoc Reports'
	wait_for_ajax(20)
	save_screen(TYPE)
end

Then('I see the change note {string} made by user {string}') do |string1,string2|
	ui_check_table_cell("results", 1, 6, string1)
	ui_check_table_cell("results", 1, 4, string2)
	wait_for_ajax(20)
	save_screen(TYPE)
	end


Then('I see the report {string} downloaded') do |string|
      file = download_content2
      wait_for_ajax(20)
      expected = read_text_file_3('cucumber-report/downloads', string)
      expect(file).to eq(expected)
      wait_for_ajax(20)
	  save_screen(TYPE)
    attach(expected, 'text/plain')
	end
