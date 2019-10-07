module DataHelpers

  def schema_files
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", 
      "BusinessOperational.ttl", "thesaurus.ttl", "cross_reference.ttl",
      "BusinessForm.ttl", "CDISCBiomedicalConcept.ttl"
    ]
  end

  def load_files(schema_files, test_files)
    ConsoleLogger.debug("DataHelpers", "load_files", "***** Next Test ***** #{self.class.metadata[:location]}")
    clear_triple_store
    schema_files.each {|f| load_schema_file_into_triple_store(f)}
    test_files.each {|f| load_test_file_into_triple_store(f)}
    test_query # Make sure any loading has finished.
    load_schema
  end
  
  def load_schema
    Fuseki::Base.instance_variable_set(:@schema, nil)
    Fuseki::Base.class_variable_set(:@@subjects, nil)
    Fuseki::Base.set_schema
  end
  
  def test_query
    # Query to just check the triple store.
    i = 0
    begin
      i += 1
      query_string = "SELECT ?o WHERE {<http://www.assero.co.uk/ISO11179Identification#Namespace> <http://www.w3.org/2000/01/rdf-schema#label> ?o}"
      triples = Sparql::Query.new.query(query_string, "", []) 
      raise if triples.results.empty?
      raise if triples.results.first.column(:o).value != "Namespace"
      #raise if triples.results.first[:o] != "Namespace"
    rescue
      sleep 1
      puts colourize("***** !!!!! DB Check Failed, Attempt #{i} !!!!! *****", "red")
      retry if i < 5 
    end
  end

  def colourize(text, color = "default", bgColor = "default")
    colors = {"default" => "38","black" => "30","red" => "31","green" => "32","brown" => "33", "blue" => "34", "purple" => "35",
     "cyan" => "36", "gray" => "37", "dark gray" => "1;30", "light red" => "1;31", "light green" => "1;32", "yellow" => "1;33",
      "light blue" => "1;34", "light purple" => "1;35", "light cyan" => "1;36", "white" => "1;37"}
    bgColors = {"default" => "0", "black" => "40", "red" => "41", "green" => "42", "brown" => "43", "blue" => "44",
     "purple" => "45", "cyan" => "46", "gray" => "47", "dark gray" => "100", "light red" => "101", "light green" => "102",
     "yellow" => "103", "light blue" => "104", "light purple" => "105", "light cyan" => "106", "white" => "107"}
    color_code = colors[color]
    bgColor_code = bgColors[bgColor]
    return "\033[#{bgColor_code};#{color_code}m#{text}\033[0m"
  end

  def clear_triple_store
		#sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
    #  "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
    #  "DELETE { ?a ?b ?c } WHERE { ?a ?b ?c }"
    sparql_query = "CLEAR DEFAULT"
  	CRUD.update(sparql_query)
  end

  def load_local_file_into_triple_store(sub_dir, filename)
    full_path = set_path(sub_dir, filename)
    load_file_into_triple_store(full_path)
  end

  def load_test_file_into_triple_store(filename)
		full_path = Rails.root.join "db/load/test/#{filename}"
  	load_file_into_triple_store(full_path)
  end

  def load_test_temp_file_into_triple_store(filename)
		full_path = Rails.root.join "db/load/tmp/#{filename}"
  	load_file_into_triple_store(full_path)
  end

  def load_schema_file_into_triple_store(filename)
    full_path = Rails.root.join "db/load/schema/#{filename}"
    load_file_into_triple_store(full_path)
  end

  def load_data_file_into_triple_store(filename)
    full_path = Rails.root.join "db/load/data/#{filename}"
    load_file_into_triple_store(full_path)
  end

  def load_cdisc_term_versions(range)
    range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
  end

  def load_file_into_triple_store(full_path)
    i = 0
    begin
      i += 1
      response = CRUD.file(full_path)
      raise if !response.success?
    rescue
      sleep 1
      puts colourize("***** File load failed #{full_path} *****", "red")
      retry if i < 3
    end
  end

  def check_file_actual_expected(actual, sub_dir, filename, args={})
    write_file = args[:write_file] ? args[:write_file] : false
    equate_method = args[:equate_method] ? args[:equate_method] : :eq
    if args[:write_file]
      puts colourize("***** WARNING: Writing Results File *****", "red")
      write_yaml_file(actual, sub_dir, filename)
    end
    expected = read_yaml_file(sub_dir, filename)
    expect(actual).to self.send(equate_method, expected)   
  end

  def read_yaml_file_to_hash(filename)
    full_path = Rails.root.join "db/load/test/#{filename}"
    return YAML.load_file(full_path)
  end

  def read_yaml_file_to_hash_2(sub_dir, filename)
    read_yaml_file(sub_dir, filename)
  end

  def read_yaml_file(sub_dir, filename)
    full_path = set_path(sub_dir, filename)
    return YAML.load_file(full_path)
  end

  def write_hash_to_yaml_file(item, filename)
    full_path = Rails.root.join "db/load/test/#{filename}"
    File.open(full_path, "w+") do |f|
      f.write(item.to_yaml)
    end
  end

  def write_hash_to_yaml_file_2(item, sub_dir, filename)
    write_yaml_file(item, sub_dir, filename)
  end

  def write_yaml_file(item, sub_dir, filename)
    full_path = set_path(sub_dir, filename)
    File.open(full_path, "w+") do |f|
      f.write(item.to_yaml)
    end
  end

  def read_text_file(filename)
    text = ""
    full_path = Rails.root.join "db/load/test/#{filename}"
    File.open(full_path, "r") do |f|
      text = f.read
    end
    return text
  end

  def read_text_file_2(sub_dir, filename)
    text = ""
    full_path = set_path(sub_dir, filename)
    File.open(full_path, "r") do |f|
      text = f.read
    end
    return text
  end

  def read_text_file_full_path(full_path)
    text = ""
    File.open(full_path, "r") do |f|
      text = f.read
    end
    return text
  end

  def write_text_file(item, filename)
    full_path = Rails.root.join "db/load/test/#{filename}"
    File.open(full_path, "w+") do |f|
      f.write(item)
    end
  end

  def write_text_file_2(item, sub_dir, filename)
    full_path = set_path(sub_dir, filename)
    File.open(full_path, "w+") do |f|
      f.write(item)
    end
  end

  def read_public_text_file(sub_dir, filename)
    text = ""
    full_path = Rails.root.join "public/#{sub_dir}/#{filename}"
    File.open(full_path, "r") do |f|
      text = f.read
    end
    return text
  end

  def delete_data_file(sub_dir, filename)
    full_path = set_path(sub_dir, filename)
		File.delete(full_path)
  rescue => e
  end

  def date_check_now(item, within=2)
    expect(item).to be_within(within.second).of Time.now
    return item
	end

  def clear_iso_concept_object
    IsoConcept.class_variable_set(:@@property_attributes, nil)
    IsoConcept.class_variable_set(:@@extension_attributes, nil) 
    IsoConcept.class_variable_set(:@@link_attributes, nil)
  end

  def clear_iso_namespace_object
    IsoNamespace.class_variable_set(:@@idMap, Hash.new)
    IsoNamespace.class_variable_set(:@@nameMap, Hash.new) 
  end

  def clear_iso_registration_authority_object
    IsoRegistrationAuthority.class_variable_set(:@@id_map, Hash.new)
    IsoRegistrationAuthority.class_variable_set(:@@name_map, Hash.new) 
    IsoRegistrationAuthority.class_variable_set(:@@repositoryOwner, nil) 
  end

  def clear_iso_registration_state_object
    IsoRegistrationState.class_variable_set(:@@owner, nil)
  end
  
  def clear_enumerated_label_object
    EnumeratedLabel.class_variable_set(:@@uri_cache, {})
  end
  
  def clear_token_object
    Token.class_variable_set(:@@token_timeout, nil)
  end

  def clear_cdisc_term_object
    CdiscTerm.class_variable_set(:@@cdisc_namespace, nil)
  end

  def clear_all_edit_locks
    Token.delete_all
  end

  def test_file_path(sub_dir, filename)
    return set_path(sub_dir, filename)
  end

  def db_load_file_path(sub_dir, filename)
    return Rails.root.join "db/load/#{sub_dir}/#{filename}"
  end
  
private

  def set_path(sub_dir, filename)
    return Rails.root.join "spec/fixtures/files/#{sub_dir}/#{filename}"
  end

end