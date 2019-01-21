module OdmHelpers
  
  def add_root
    odm_document = Odm.new("O-TEST", "Assero", "Glandon", Version::VERSION)
  end

  def add_study(odm)
    study = odm.add_study("S-TEST")
  end

  def add_mdv(study)
    metadata_version = study.add_metadata_version("MDV-TEST", "Metadata for test", "Not applicable.")
  end

  def add_form(mdv)
    form_def = mdv.add_form_def("F-TEST", "test form", "No")
  end

  def odm_fix_datetimes(results, expected)
  	run_at_1 = extract_file_oid(expected)
    run_at_2 = extract_file_oid(results)
   	results.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
    run_at_1 = extract_creation_datetime(expected)
    run_at_2 = extract_creation_datetime(results)
   	results.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
  end

  def odm_fix_system_version(results, expected)
  	expected_system_version = extract_system_version(expected)
  	results_system_version = extract_system_version(results)
  	expect(results_system_version).to eq("SourceSystemVersion=\"#{Version::VERSION}\"")
   	results.sub!(results_system_version, expected_system_version) # Need to fix the system version. Set to current version
	end    

  def extract_file_oid(text)
    return text[/FileOID=\"\d\d\d\d\-\d\d-\d\dT\d\d:\d\d:\d\d[+|-]\d\d:\d\d\"/]
  end

  def extract_creation_datetime(text)
    return text[/CreationDateTime=\"\d\d\d\d\-\d\d-\d\dT\d\d:\d\d:\d\d[+|-]\d\d:\d\d\"/]
  end

  def extract_system_version(text)
    return text[/SourceSystemVersion=\"\d+.\d+.\d+( \[[a-zA-Z]*\])?\"/]
  end

end