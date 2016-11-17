module DataHelpers

		def clear_triple_store
		sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "DELETE { ?a ?b ?c } WHERE { ?a ?b ?c }"
  	CRUD.update(sparql_query)
    #sleep 1.5
  end

  def load_test_file_into_triple_store(filename)
		full_path = Rails.root.join "db/load/test/#{filename}"
  	CRUD.file(full_path)
  end

  def load_schema_file_into_triple_store(filename)
    full_path = Rails.root.join "db/load/schema/#{filename}"
    CRUD.file(full_path)
  end

  def load_data_file_into_triple_store(filename)
    full_path = Rails.root.join "db/load/data/#{filename}"
    CRUD.file(full_path)
  end

  def read_yaml_file_to_hash(filename)
    full_path = Rails.root.join "db/load/test/#{filename}"
    return YAML.load_file(full_path)
  end

  def write_yaml_file_to_hash(item, filename)
    full_path = Rails.root.join "db/load/test/#{filename}"
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

  def write_text_file(item, filename)
    full_path = Rails.root.join "db/load/test/#{filename}"
    File.open(full_path, "w+") do |f|
      f.write(item)
    end
  end

  def date_check_now(item)
    expect(item).to be_within(2.second).of Time.now
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
    IsoRegistrationAuthority.class_variable_set(:@@idMap, Hash.new)
    IsoRegistrationAuthority.class_variable_set(:@@nameMap, Hash.new) 
    IsoRegistrationAuthority.class_variable_set(:@@repositoryOwner, nil) 
  end

  def clear_iso_registration_state_object
    IsoRegistrationState.class_variable_set(:@@owner, nil)
  end
  
end