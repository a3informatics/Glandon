module DataHelpers

	def clear_triple_store
		sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "DELETE { ?a ?b ?c } WHERE { ?a ?b ?c }"
  	CRUD.update(sparql_query)
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

end